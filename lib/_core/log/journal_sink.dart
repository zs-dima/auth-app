import 'dart:async';
import 'dart:convert';

import 'package:auth_app/_core/database/database.dart';
import 'package:telemetry/telemetry.dart';

/// {@template journal_sink}
/// Writes events into the drift journal that the dev menu reads.
///
/// Batched on purpose: a burst of scoped lines is one transaction, not one per
/// line. Two things that batching cannot be allowed to lose are handled
/// explicitly — a failure is written through immediately (the line before a
/// native crash is the one worth having), and [drain] adopts the events logged
/// before this sink existed, which is the whole boot sequence.
/// {@endtemplate}
final class JournalSink implements TelemetrySink, Flushable {
  /// {@macro journal_sink}
  JournalSink(this._database, {Duration flushInterval = const Duration(seconds: 5), this.minLevel = .debug}) {
    _timer = Timer.periodic(flushInterval, (_) => flush().ignore());
  }

  final Database _database;

  final List<LogEvent> _pending = <LogEvent>[];
  Timer? _timer;

  /// The write chain. Batches are written in order, and a caller that awaits
  /// [flush] waits for its own batch rather than for a snapshot of the queue.
  Future<void> _writing = Future<void>.value();

  /// Lowest level stored. Everything from `debug` up by default: the quiet
  /// lines are what answer "what led to this".
  final LogLevel minLevel;

  @override
  bool enabled(LogLevel level, int verbosity) => level >= minLevel;

  @override
  void handle(LogEvent event) {
    _pending.add(event);
    // Write-through for failures. Five seconds is a fine trade for a state
    // transition and a bad one for the last line before a native crash takes
    // the process with it — and that line is exactly the one being looked for.
    if (event.level >= .error) flush().ignore();
  }

  /// Adopts events logged before this sink was registered.
  ///
  /// The pipeline's ring buffer records from the first line of `main`, while
  /// this sink cannot exist until the database is open — about ten init steps
  /// later. Without this, the environment, the migration and the crash-reporter
  /// decision were console-only, and a bug report from a tester began with the
  /// app already running.
  void drain(Iterable<LogEvent> events) {
    for (final event in events) {
      if (event.level >= minLevel) _pending.add(event);
    }
  }

  /// Writes everything buffered so far; completes when it is on disk.
  ///
  /// `Flushable`, so `log.flush()` reaches it: the app going to the background
  /// and the database about to close are both moments this debt has to be paid.
  @override
  ///
  /// A failure is swallowed — a journal that cannot write must not break the
  /// app it watches, and must not report through the pipeline it just failed
  /// inside.
  Future<void> flush() {
    if (_pending.isEmpty) return _writing;
    final batch = List<LogEvent>.of(_pending);
    _pending.clear();
    return _writing = _writing
        .then((_) => _write(batch))
        .onError<Object>((error, stackTrace) => Zone.root.print('Journal | write | failed | $error'));
  }

  /// Stops the timer after one last write, and waits for it.
  ///
  /// Awaited by the init step's `dispose`, because the database is closed by a
  /// step that tears down after this one: without the await, the tail of the
  /// journal was still in this list when the connection went away.
  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    await flush();
  }

  Future<void> _write(List<LogEvent> batch) => _database.batch(
    (writer) => writer.insertAll(_database.logTbl, <LogTblCompanion>[
      for (final event in batch)
        LogTblCompanion.insert(
          level: event.level.severityNumber,
          message: event.body,
          time: Value<int>(event.timestamp.millisecondsSinceEpoch ~/ 1000),
          stack: Value<String?>(event.stackTrace?.toString()),
          runId: Value<String?>(event.runId),
          meta: Value<String?>(_encodeMeta(event)),
        ),
    ]),
  );

  /// Attributes as JSON, or null when there are none to store.
  ///
  /// Errors from an unencodable value are caught here rather than at the call
  /// site: a log line must never be the thing that throws.
  static String? _encodeMeta(LogEvent event) {
    final attributes = event.attributes;
    if (attributes.isEmpty) return null;
    try {
      return jsonEncode(attributes, toEncodable: (value) => value?.toString());
    } on Object {
      return null;
    }
  }
}
