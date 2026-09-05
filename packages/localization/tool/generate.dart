// Pulls the sheet into ARBs and generated Dart, then runs the round-trip gate.
//
//   dart run tool/generate.dart                 # pull, generate, verify
//   dart run tool/generate.dart --translate     # AI-fill EMPTY sheet cells first
//   dart run tool/generate.dart --translate --model=gpt-5.5
//
// Run from `packages/localization`. The shape (sheet id, locales, buckets, prefix) comes from
// `l10n_tool.json`, the same file the offline gate reads, so no command repeats it.
//
// `l10n_tool:generate` does this in one step, and this app moves to it once its rows carry
// descriptions: `l10n_tool:pull_baseline` refuses a row without one, and its round-trip check
// needs the baseline that command writes. Until then the round trip is `tool/verify_l10n.dart`,
// which measures against the frozen pre-migration catalog this app actually has.
//
// Requires `credentials.json` (service account), and `openai.key` for `--translate`. Both are
// gitignored and never leave this machine.
library;

import 'dart:io';

import 'package:l10n_tool/l10n_tool.dart';

Future<void> main(List<String> args) async {
  var translate = false;
  var model = 'gpt-5.5';

  for (final arg in args) {
    switch (arg) {
      case '--translate':
        translate = true;

      case final flag when flag.startsWith('--model='):
        model = flag.split('=').last;

      case final unknown:
        _fail('unknown argument: $unknown\n\nusage: dart run tool/generate.dart [--translate] [--model=<name>]');
    }
  }

  final config = L10nConfig.read('l10n_tool.json');
  _require('credentials.json', 'the service account shared on the sheet');

  if (translate) {
    _require('openai.key', 'the API key used to fill empty cells');
    await _run('dart', <String>[
      'run',
      'sheety_localization:localize',
      '-c',
      'credentials.json',
      '-s',
      config.sheetId,
      '-f',
      'openai.key',
      '--model=$model',
    ]);
  }

  await _run('dart', <String>[
    'run',
    'sheety_localization:generate',
    '-c',
    'credentials.json',
    '-s',
    config.sheetId,
    '--prefix=${config.prefix}',
    '--format',
    // Without it a row with blank trailing cells is dropped entirely, source text included.
    '--include-empty',
  ]);

  await _run('dart', <String>['run', 'tool/verify_l10n.dart']);
}

Future<void> _run(String executable, List<String> args) async {
  stdout.writeln('\$ $executable ${args.join(' ')}');
  final result = await Process.run(executable, args, runInShell: true);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) exit(result.exitCode);
}

void _require(String path, String what) {
  if (File(path).existsSync()) return;
  _fail('$path is missing: $what. See README (Localization).');
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
