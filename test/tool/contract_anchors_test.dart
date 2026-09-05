import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Contract-anchor gate (line pattern, 2026-09-02): every `INVARIANT (tag)` declared in
/// `packages/model/auth_model/refresh_token.md` must be anchored by at least one occurrence of
/// the tag in code or tests — a code comment carrying the tag, or a test name asserting it.
///
/// This is the mechanical answer to doc drift: the two known drifts (F6 without a marker, a
/// §16.7 claim that the MFA UI "does not exist" while it was wired) lived precisely because no
/// gate connected the doc's normative tags to the tree. An invariant nothing anchors is either
/// unimplemented or untagged — both are failures to fix in the same change that touches the doc.
void main() {
  const docPath = 'packages/model/auth_model/refresh_token.md';

  // Named (prose) invariants are anchored by their `id` marker rules in the doc itself; the doc's
  // reading guide says short tags match code verbatim while descriptive names may exist only as
  // the symbol they describe. `id` is the marker-legend entry, not an invariant.
  const proseTagAnchors = <String, String>{
    // descriptive tag -> the symbol/string that anchors it in the tree
    'architecture': 'ConnectAuthenticationMiddleware',
    'fail-closed': 'fails closed',
    'logout-availability': 'logout-availability',
    'redact-at-source': 'redact-at-source',
    'refresh-token-masking': 'refreshToken=***',
    'repair-without-replay': 'repair-without-replay',
    'sessionEndingPaths': 'sessionEndingPaths',
  };

  late final String docText;
  late final List<File> treeFiles;
  late final String treeText;

  setUpAll(() {
    docText = File(docPath).readAsStringSync();
    treeFiles = [
      // `http_kit` (was `packages/model/http_client`) is a git dependency now, outside this tree;
      // every INVARIANT tag it used to anchor is anchored here as well.
      for (final dir in ['lib', 'test', 'packages/model/auth_model'])
        ...Directory(dir)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart') && !f.path.endsWith('.freezed.dart')),
    ];
    treeText = treeFiles.map((f) => f.readAsStringSync()).join('\n');
  });

  test('every short INVARIANT tag in refresh_token.md is anchored in code or tests', () {
    final tags = RegExp(r'INVARIANT \(([A-Za-z0-9-]+)')
        .allMatches(docText)
        .map((m) => m.group(1)!)
        .where((t) => t != 'id') // the marker legend, not an invariant
        .toSet();
    expect(tags, isNotEmpty, reason: 'the doc lost its INVARIANT markers?');

    final missing = <String>[];
    for (final tag in tags) {
      final probe = proseTagAnchors[tag] ?? tag;
      // Word-boundary match so A2 does not count A22/A27 hits.
      final hit = RegExp('(?<![A-Za-z0-9])${RegExp.escape(probe)}(?![A-Za-z0-9])').hasMatch(treeText);
      if (!hit) missing.add(tag);
    }
    expect(
      missing,
      isEmpty,
      reason:
          'INVARIANT tags with no anchor in code/tests: $missing — tag the implementing code or '
          'the pinning test with the id (refresh_token.md reading guide), or retire the invariant '
          'in the doc in the same change.',
    );
  });

  test('the doc itself still exists and carries the maintenance rule', () {
    expect(docText, contains('Last verified against the code'));
    expect(docText, contains('MUST update this document in the same PR'));
  });
}
