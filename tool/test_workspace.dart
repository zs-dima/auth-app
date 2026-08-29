import 'dart:convert';
import 'dart:io';

/// Runs `flutter test` in every workspace member that has a `test/` directory,
/// writing a machine-readable report per package into `reports/<package>.json`
/// (the layout the CI test-reporter workflow consumes).
///
/// Extra arguments are forwarded to every `flutter test` invocation.
Future<void> main(List<String> args) async {
  final root = Directory.current.path;

  final list = await Process.run('dart', const ['pub', 'workspace', 'list', '--json'], runInShell: true);
  if (list.exitCode != 0) {
    stderr.write(list.stderr);
    exit(list.exitCode);
  }

  final json = jsonDecode(list.stdout as String) as Map<String, Object?>;
  final packages = (json['packages']! as List<Object?>).cast<Map<String, Object?>>();

  // Fresh report set: stale JSON from a removed/renamed package must not reach the reporter.
  final reports = Directory('$root/reports');
  if (reports.existsSync()) reports.deleteSync(recursive: true);
  reports.createSync(recursive: true);

  // Run every package even after a failure so the reporter gets the complete picture,
  // then fail the whole run.
  var failed = false;
  for (final package in packages) {
    final name = package['name']! as String;
    final path = package['path']! as String;
    if (!Directory('$path/test').existsSync()) continue;

    stdout.writeln('--- Testing $name ---');
    final test = await Process.start(
      'flutter',
      [
        'test',
        '--coverage',
        '--test-randomize-ordering-seed=random',
        '--file-reporter',
        'json:$root/reports/$name.json',
        ...args,
      ],
      workingDirectory: path,
      runInShell: true,
      mode: .inheritStdio,
    );
    if (await test.exitCode != 0) failed = true;
  }
  if (failed) exit(1);
}
