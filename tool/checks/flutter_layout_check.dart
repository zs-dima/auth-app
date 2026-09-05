import 'dart:convert';
import 'dart:io';

/// Fails a build on the two structural layout laws, and on the perf mistakes no lint can express.
///
/// ```sh
/// dart <path>/flutter_layout_check.dart            # in the project root
/// dart <path>/flutter_layout_check.dart --json     # machine-readable
/// ```
///
/// **What this is NOT.** It does not duplicate DCM: `avoid-shrink-wrap-in-lists`,
/// `avoid-returning-widgets`, `prefer-dedicated-media-query-methods`, `prefer-const-*` and
/// `avoid-wrapping-in-padding` all exist there and should be raised to `severity: error` rather
/// than re-implemented here — `avoid-returning-widgets` covers the widget-returning method, so
/// there is no rule for it below. What is here is what a rule engine over one expression cannot
/// see: a scrollable behind a kit wrapper, a subtree that changes SHAPE between two builds, a
/// getter that mints a new stream every time it is read.
///
/// Regex over source, deliberately. An analyzer plugin would be more precise and would not run
/// where this has to run — as one step of a shell gate, on any machine, with no package resolution
/// and no DCM licence. The cost is false positives, so every rule is silenceable ON THE LINE:
///
/// ```dart
/// SafeArea(child: ListView(...)) // layout-check: ignore wrapped-scrollable
/// ```
///
/// Configure per project in `.claude/flutter-layout-check.json`:
/// `{"paths": ["lib", "packages"], "boxWrappers": ["ContentPane", "GlassCard"], "disable": []}`
/// Scans a project and returns everything worth stopping a build for.
///
/// Public so a repository can enforce this from its own test suite — `expect(scanProject(),
/// isEmpty)` — instead of spawning `dart run` from a test. That subprocess costs a compile and a
/// full tree walk in a process already competing with the suite for cores, and it is what pushed
/// a neighbouring subprocess test past its own 30 s timeout the first time this was wired up.
/// [root] defaults to the current directory, which is the package root under `flutter test`.
List<Finding> scanProject([Directory? root]) {
  final base = root ?? Directory.current;
  final config = _Config.load(base);
  final findings = <Finding>[];

  for (final path in config.paths) {
    final directory = Directory('${base.path}/$path');
    if (!directory.existsSync()) continue;
    for (final file in directory.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final relative = file.path.replaceAll(r'\', '/').substring(base.path.length + 1);
      if (config.excludes.any(relative.contains)) continue;
      findings.addAll(_scan(relative, file.readAsStringSync(), config));
    }
  }
  return findings;
}

Future<void> main(List<String> args) async {
  final findings = scanProject();

  if (args.contains('--json')) {
    stdout.writeln(
      jsonEncode(<String, Object?>{
        'findings': <Object?>[
          for (final finding in findings)
            <String, Object?>{'file': finding.file, 'line': finding.line, 'rule': finding.rule, 'text': finding.text},
        ],
      }),
    );
  } else {
    for (final finding in findings) {
      stdout.writeln('${finding.file}:${finding.line}: ${finding.rule} — ${finding.text.trim()}');
    }
    stdout.writeln(
      findings.isEmpty
          ? 'layout check: clean'
          : '\nlayout check: ${findings.length} finding(s). '
                'The rules and their fixes: the `flutter-layout-perf` skill. '
                'A false positive is silenced with `// layout-check: ignore <rule>` on the line.',
    );
  }

  if (findings.isNotEmpty) exit(1);
}

/// One thing worth stopping a build for: where it is, which rule, and the line that tripped it.
typedef Finding = ({String file, int line, String rule, String text});

/// Everything scrollable, by the name it is constructed with.
const _kScrollables = <String>[
  'ListView',
  'GridView',
  'CustomScrollView',
  'SingleChildScrollView',
  'ReorderableListView',
  'NestedScrollView',
  'PageView',
  'ListWheelScrollView',
  'Scrollbar',
];

/// Stream methods that return a NEW object with no `==`.
///
/// `StreamController.stream` is deliberately absent: `_ControllerStream` overrides `==` on the
/// controller, so two reads of the same getter compare equal and nothing resubscribes.
const _kTransformers =
    'map|where|expand|asyncMap|asyncExpand|distinct|handleError|asBroadcastStream|timeout|transform|cast';

/// Box widgets that shrink whatever they contain. A scrollable inside one of these has a viewport
/// smaller than the space it was given.
const _kWrappers = <String>['Padding', 'SafeArea', 'Center', 'Align', 'ConstrainedBox', 'SizedBox', 'FittedBox'];

class _Config {
  const _Config({required this.paths, required this.wrappers, required this.disabled, required this.excludes});

  factory _Config.load(Directory root) {
    final file = File('${root.path}/.claude/flutter-layout-check.json');
    if (!file.existsSync()) return const _Config.defaults();
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    List<String> list(String key, List<String> fallback) => (json[key] as List<Object?>?)?.cast<String>() ?? fallback;
    return _Config(
      paths: list('paths', const <String>['lib', 'packages']),
      // A project's own kit wrappers: `ContentPane(child: ListView(...))` is the same mistake with
      // a local name on it, and only the project knows those names.
      wrappers: <String>[..._kWrappers, ...list('boxWrappers', const <String>[])],
      disabled: list('disable', const <String>[]).toSet(),
      excludes: list('exclude', const <String>['.dart_tool/', 'build/', '/generated/']),
    );
  }

  const _Config.defaults()
    : paths = const <String>['lib', 'packages'],
      wrappers = _kWrappers,
      disabled = const <String>{},
      excludes = const <String>['.dart_tool/', 'build/', '/generated/'];

  final List<String> paths;
  final List<String> wrappers;
  final Set<String> disabled;
  final List<String> excludes;
}

/// Every rule, applied line by line.
///
/// Line-based on purpose: `dart format` in this estate breaks a wrapper and its child across lines,
/// so `Wrapper(` on one line and the scrollable on the next is the shape that actually occurs, and
/// a two-line window catches it without parsing.
List<Finding> _scan(String file, String source, _Config config) {
  final lines = source.split('\n');
  final findings = <Finding>[];
  final generated = source.startsWith('// GENERATED') || source.contains('// coverage:ignore-file');
  if (generated) return findings;

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final next = index + 1 < lines.length ? lines[index + 1] : '';
    // The ignore may sit on the line ABOVE — where Dart's own `// ignore:` goes, and where a
    // formatter pushes a long one anyway.
    final previous = index > 0 ? lines[index - 1] : '';
    final window = '$previous\n$line\n$next';
    if (line.trimLeft().startsWith('//') || line.trimLeft().startsWith('///')) continue;

    void report(String rule, [String? text]) {
      if (config.disabled.contains(rule)) return;
      if (window.contains('layout-check: ignore $rule')) return;
      findings.add((file: file, line: index + 1, rule: rule, text: text ?? line));
    }

    // 1. A box wrapper whose child is a scrollable.
    for (final wrapper in config.wrappers) {
      final opens = RegExp('(^|[^A-Za-z0-9_])$wrapper\\(').hasMatch(line);
      if (!opens) continue;
      final rest = '${line.substring(line.indexOf('$wrapper('))}\n$next';
      if (_kScrollables.any((s) => RegExp('child:\\s*(const\\s+)?$s[.(]').hasMatch(rest))) {
        report('wrapped-scrollable');
      }
    }

    // 2. Reshaping: the same child at two different depths.
    if (RegExp(r'^\s*\w+\s*=\s*\w+\(\s*$').hasMatch(line) && RegExp(r'child:\s*\w+\s*[,)]').hasMatch(next)) {
      report('reshape');
    }
    if (RegExp(r'\?\s*\w+\(\s*child:\s*(\w+)\s*\)\s*:\s*\1\b').hasMatch(line)) report('reshape');
    if (RegExp(r'\?\s*\w+\(\s*child:\s*(\w+)\s*\)\s*:\s*\w+\(\s*child:\s*\1\s*\)').hasMatch(line)) report('reshape');

    // 3. A TRANSFORMED stream built where it is read.
    //
    //    NOT `controller.stream`: that hands back a new `_ControllerStream` per access, but the
    //    class overrides `==` to compare controllers, so `StreamBuilder.didUpdateWidget` sees the
    //    same stream and keeps its subscription. (Measured 2026-09-04; an earlier version of this
    //    rule claimed the opposite and was simply wrong.) What has NO `==` is whatever the
    //    transformers below return: a builder handed one of those cancels, resets its snapshot to
    //    `ConnectionState.none` and resubscribes on every rebuild of its parent.
    if (line.contains('Builder') && RegExp('stream:\\s*[^,]*\\.($_kTransformers)\\(').hasMatch(line)) {
      report('stream-transform');
    }
    if (RegExp('Stream<[^>]+>\\s+get\\s+\\w+\\s*=>[^;]*\\.($_kTransformers)\\(').hasMatch(line)) {
      report('stream-transform');
    }

    // 4. A Paint inside a TextStyle: TextStyle compares `foreground` by identity, so the text
    //    re-shapes on every build.
    if (line.contains('foreground:') && window.contains('Paint()')) report('paint-in-style');

    // 5. Wall-clock reads inside a builder.
    if (line.contains('DateTime.now()') &&
        _within(lines, index, RegExp(r'(Widget\s+build\(|itemBuilder:|builder:\s*\()'))) {
      report('clock-in-build');
    }

    // 6. Things with a dedicated, cheaper form.
    if (line.contains('MediaQuery.of(')) report('media-query-of');
    if (RegExp(r'\bshrinkWrap:\s*true').hasMatch(line)) report('shrink-wrap');
    if (RegExp(r'\bIntrinsic(Height|Width)\(').hasMatch(line)) report('intrinsic');
    if (RegExp(r'key:\s*UniqueKey\(\)').hasMatch(line)) report('unique-key-in-build');
  }

  return findings;
}

/// Whether one of the last few lines before [index] opens a build-like scope.
bool _within(List<String> lines, int index, RegExp opener) {
  for (var back = index; back >= 0 && back > index - 40; back--) {
    // A callback between here and the builder means this line runs on a TAP, not on a build.
    // Without this the date pickers of a shipping app were reported for reading the clock inside
    // `onTap` — and a check whose findings have to be argued with is a check somebody switches
    // off. Checked first, so the nearest opener wins.
    if (_kCallbackOpener.hasMatch(lines[back])) return false;
    if (opener.hasMatch(lines[back])) return true;
  }
  return false;
}

/// The start of a callback body. Code below one of these runs on a gesture, not on a build.
final _kCallbackOpener = RegExp(
  r'on[A-Z]\w*:\s*\(|\bonTap:|\bonPressed:|\bonLongPress:|\bonSubmitted:|\bonSelected:',
);
