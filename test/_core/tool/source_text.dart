/// What the source-reading tests share.
///
/// Four tests in this suite read `lib/` as text — the `handle()` contract, the
/// attribute-key spelling, the capture ownership and the canonical body. Each
/// had grown its own file walk, and only one of them stripped comments, so
/// prose that mentions a pattern read as a call site. One place, one behaviour.
library;

import 'dart:io';

/// Every hand-written Dart file under [root].
///
/// Generated code is skipped: it has its own `handle`-shaped calls (drift's
/// query builders), its own string literals, and no owner to fix them.
Iterable<File> dartFiles([String root = 'lib']) sync* {
  for (final entity in Directory(root).listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path.replaceAll(r'\', '/');
    if (!path.endsWith('.dart')) continue;
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) continue;
    if (path.contains('/generated/')) continue;
    yield entity;
  }
}

/// [file]'s path with `\` normalised, so a reported position is clickable.
String pathOf(File file) => file.path.replaceAll(r'\', '/');

/// Blanks out comments, keeping the line count so reported positions stay true.
///
/// Prose mentioning `handle()` is not a call site — the observer's own comment
/// about the messenger emitting "outside handle()" was the first false positive
/// this produced. String literals are KEPT: the canonical-body test reads them.
String withoutComments(String source) {
  final out = StringBuffer();
  var inBlock = false;
  var inString = false;
  String? quote;

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    final next = i + 1 < source.length ? source[i + 1] : '';

    if (inBlock) {
      if (char == '*' && next == '/') {
        inBlock = false;
        i++;
      } else if (char == '\n') {
        out.write(char);
      }
      continue;
    }

    if (inString) {
      if (char == r'\') {
        i++;
      } else if (char == quote) {
        inString = false;
        quote = null;
      }
      out.write(char);
      continue;
    }

    if (char == "'" || char == '"') {
      inString = true;
      quote = char;
      out.write(char);
      continue;
    }
    if (char == '/' && next == '/') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      out.write('\n');
      continue;
    }
    if (char == '/' && next == '*') {
      inBlock = true;
      i++;
      continue;
    }
    out.write(char);
  }
  return out.toString();
}

/// The 1-based line number of [offset] in [source].
int lineAt(String source, int offset) => '\n'.allMatches(source.substring(0, offset)).length + 1;
