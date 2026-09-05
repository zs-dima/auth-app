// Octopus.showDialog is the router's route-aware dialog API (marked @experimental upstream);
// there is no stable alternative that keeps dialogs in the navigation state.
// ignore_for_file: experimental_member_use
import 'dart:async';
import 'dart:convert';

import 'package:auth_app/_core/database/database.dart' as db;
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

/// {@template logs_dialog}
/// The journal, as the dev menu shows it.
/// {@endtemplate}
class LogsDialog extends StatelessWidget {
  /// {@macro logs_dialog}
  const LogsDialog({super.key});

  /// Shows the logs screen.
  ///
  /// Flushes first: the journal writes in five-second batches, and the line the
  /// reader opened this for is almost always the one that has not landed yet —
  /// which is what made "Details" on an error toast open a screen without it.
  static Future<void> show(BuildContext context) async {
    final router = Octopus.of(context);
    final journal = context.dependencies.journal;
    await journal.flush();
    await router.showDialog<void>((context) => const LogsDialog());
  }

  @override
  Widget build(BuildContext context) => const Dialog(
    elevation: 8,
    insetPadding: .all(36.0),
    shape: RoundedRectangleBorder(borderRadius: .vertical(bottom: .circular(16.0))),
    child: _LogsList(),
  );
}

/// One row of the screen, from either source.
///
/// A journal row is a stored [LogEvent] minus what only mattered live; a live
/// row is an event straight from the pipeline's ring buffer. They render
/// identically on purpose — the reader should not have to know which table a
/// line came from, only when it happened.
@immutable
class _JournalRow {
  const _JournalRow({
    required this.level,
    required this.body,
    required this.timestamp,
    this.id = 0,
    this.stackTrace,
    this.runId,
    this.verbosity = 0,
    this.meta = const <String, Object?>{},
  });

  factory _JournalRow.fromData(db.LogTblData data) => _JournalRow(
    id: data.id,
    level: LogLevel.fromValue(data.level),
    body: data.message,
    timestamp: DateTime.fromMillisecondsSinceEpoch(data.time * 1000),
    stackTrace: data.stack,
    runId: data.runId,
    meta: _decodeMeta(data.meta),
  );

  /// A line that is in memory and will never be in the database: `trace` is
  /// below the journal's floor, so the only place those tiers exist is the ring
  /// buffer of the current launch.
  factory _JournalRow.fromEvent(LogEvent event, int index) => _JournalRow(
    // Above every journal id, so a buffered line sorts after the stored rows of
    // the same second rather than into the middle of them — and offset by its
    // position in the ring, so the buffer's own order survives the re-sort
    // (`List.sort` is not stable, and `time` is SECONDS).
    id: (1 << 62) + index,
    level: event.level,
    body: event.body,
    timestamp: event.timestamp.toLocal(),
    stackTrace: event.stackTrace?.toString(),
    runId: event.runId,
    verbosity: event.verbosity,
    meta: event.attributes,
  );

  /// Row id, or `1 << 62` for a line that is only in memory.
  ///
  /// The tie-breaker: `log_tbl.time` is SECONDS, so a burst inside one second is
  /// one sort key for ten rows — and `List.sort` is not stable, so the order the
  /// database returned was discarded.
  final int id;

  final LogLevel level;
  final String body;
  final DateTime timestamp;
  final String? stackTrace;
  final String? runId;

  /// Trace tier, 1 loud … 6 whisper; 0 for everything else.
  final int verbosity;

  final Map<String, Object?> meta;

  /// What a search box matches against: the line AND its values, because half
  /// of what a reader looks for now lives in the attributes.
  String get searchable => meta.isEmpty ? body : '$body ${meta.entries.map((e) => '${e.key}=${e.value}').join(' ')}';

  /// Everything about this row, for the clipboard.
  String get full => <String>[
    // UTC in the CLIPBOARD, local on screen: what is copied travels off the device
    '${timestamp.toUtc().toIso8601String()} [${level.prefix}] $body',
    if (meta.isNotEmpty) meta.entries.map((e) => '${e.key}=${e.value}').join(' '),
    if (runId case final String id) 'run_id=$id',
    if (stackTrace case final String trace) trace,
  ].join('\n');

  /// One unreadable `meta` cell used to take the whole screen down with it: the
  /// dialog is what a developer opens when things are already wrong.
  static Map<String, Object?> _decodeMeta(String? json) {
    if (json == null) return const <String, Object?>{};
    try {
      return switch (jsonDecode(json)) {
        final Map<String, Object?> map => map,
        _ => const <String, Object?>{},
      };
    } on Object {
      return <String, Object?>{'meta.unreadable': json};
    }
  }
}

/// Newest first, with the row id breaking a tie.
///
/// `log_tbl.time` is stored in SECONDS, so a burst inside one second is one sort
/// key for every row in it — and `List.sort` is not stable, so re-sorting after
/// the query threw away the order the database had already given. The id is
/// monotonic, which is exactly the missing precision.
int _newestFirst(_JournalRow a, _JournalRow b) {
  final byTime = b.timestamp.compareTo(a.timestamp);
  return byTime != 0 ? byTime : b.id.compareTo(a.id);
}

class _LogsList extends StatefulWidget {
  const _LogsList();

  @override
  State<_LogsList> createState() => _LogsListState();
}

/// State for widget _LogsList.
class _LogsListState extends State<_LogsList> {
  final _controller = TextEditingController();

  List<_JournalRow> _logs = const <_JournalRow>[];
  List<_JournalRow> _filteredLogs = const <_JournalRow>[];

  /// Debug lines are now journaled — every controller transition among them —
  /// so the screen opens on what a human reads and offers the rest.
  LogLevel _minLevel = .info;

  /// Which filter pass owns the result; see [_filter].
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    final database = context.dependencies.database;
    // Guarded, and not just for tidiness: an unhandled failure here becomes an uncaught zone error,
    // which the pipeline files as a crash-report ISSUE — for a developer screen reading a database
    // that shutdown may already have closed.
    unawaited(
      Future<void>(() async {
        final logTbl = database.logTbl;
        final rows = await (database.select(
          logTbl,
        )..orderBy([(tbl) => db.OrderingTerm(expression: tbl.time, mode: db.OrderingMode.desc)])).get();
        if (!mounted) return;
        // The two sources, newest first. The buffer contributes only what the journal cannot have.
        _logs = <_JournalRow>[
          ...rows.map(_JournalRow.fromData),
          for (final (index, event) in log.buffer.events.indexed)
            if (event.level == LogLevel.trace) _JournalRow.fromEvent(event, index),
        ]..sort(_newestFirst);
        await _filter();
      }).catchError((Object error, StackTrace stackTrace) {
        log.w('Journal | read | failed', error: error, stackTrace: stackTrace);
      }),
    );
    _controller.addListener(() => _filter().ignore());
  }

  Future<void> _filter() async {
    // Two passes can be in flight at once — the search box and the level chips
    // both start one, and each yields every 8 ms — and the loser used to finish
    // last and win. A generation counter makes the newest pass the only writer.
    final generation = ++_generation;
    final search = _controller.text.toLowerCase();
    final stopwatch = Stopwatch()..start();
    final buffer = _logs.toList();
    try {
      var pos = 0;
      for (var i = 0; i < buffer.length; i++) {
        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(.zero);
          if (generation != _generation) return;
          stopwatch.reset();
        }
        final row = buffer[i];
        if (row.level < _minLevel) continue;
        if (search.isNotEmpty && !row.searchable.toLowerCase().contains(search)) continue;
        buffer[pos] = row;
        pos++;
      }
      _filteredLogs = buffer..length = pos;
    } finally {
      stopwatch.stop();
    }
    if (mounted) setState(() {});
  }

  void _setLevel(LogLevel level) {
    _minLevel = level;
    _filter().ignore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .only(bottom: 8.0),
    child: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Logs (${_filteredLogs.length})'),
          floating: true,
          pinned: MediaQuery.heightOf(context) > 600,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120.0),
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: .min,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search message or attribute',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: Row(
                      spacing: 8.0,
                      children: <Widget>[
                        for (final level in LogLevel.values)
                          ChoiceChip(
                            label: Text(level.name),
                            selected: _minLevel == level,
                            onSelected: (_) => _setLevel(level),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_filteredLogs.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('No logs found'),
            ),
          )
        else
          SliverPadding(
            padding: const .symmetric(horizontal: 24.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _LogTile(
                  _filteredLogs[index],
                  // The journal spans launches. Without a boundary, the last line of one run and
                  // the first line of the previous one read as cause and effect.
                  newRun: index > 0 && _filteredLogs[index - 1].runId != _filteredLogs[index].runId,
                  key: ObjectKey(_filteredLogs[index]),
                ),
                childCount: _filteredLogs.length,
              ),
            ),
          ),
      ],
    ),
  );
}

/// {@template logs_screen}
/// _LogTile widget.
/// {@endtemplate}
class _LogTile extends StatelessWidget {
  /// {@macro logs_screen}
  const _LogTile(this.row, {this.newRun = false, super.key});

  final _JournalRow row;

  /// Whether this row starts a different app launch than the one above it.
  final bool newRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (newRun)
          Padding(
            padding: const .symmetric(vertical: 4.0),
            child: Row(
              children: <Widget>[
                const Expanded(child: Divider(endIndent: 8.0)),
                Text(
                  'run ${row.runId ?? 'unknown'}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
                const Expanded(child: Divider(indent: 8.0)),
              ],
            ),
          ),
        ListTile(
          title: Text(row.body),
          subtitle: Column(
            crossAxisAlignment: .start,
            children: <Widget>[
              Text(row.timestamp.toIso8601String()),
              if (row.meta.isNotEmpty)
                Text(
                  row.meta.entries.map((e) => '${e.key}=${e.value}').join('  '),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                ),
            ],
          ),
          leading: _LogIcon(row.level, verbosity: row.verbosity),
          dense: true,
          isThreeLine: row.meta.isNotEmpty,
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => Clipboard.setData(ClipboardData(text: row.full)),
          ),
        ),
        const Divider(height: 1.0),
      ],
    );
  }
}

/// The severity glyph.
///
/// Semantic for the levels — a warning triangle says at a glance what a digit
/// never will — and NUMBERED for the six trace tiers, where the number is the
/// whole meaning: how deep into the noise this line lives.
class _LogIcon extends StatelessWidget {
  const _LogIcon(this.level, {this.verbosity = 0});

  final LogLevel level;
  final int verbosity;

  static IconData _tier(int verbosity) => switch (verbosity) {
    1 => Icons.looks_one,
    2 => Icons.looks_two,
    3 => Icons.looks_3,
    4 => Icons.looks_4,
    5 => Icons.looks_5,
    6 => Icons.looks_6,
    _ => Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) => switch (level) {
    .trace => Icon(_tier(verbosity), color: Colors.grey),
    .debug => const Icon(Icons.bug_report, color: Colors.indigo),
    .info => const Icon(Icons.info, color: Colors.blue),
    .warn => const Icon(Icons.warning, color: Colors.orange),
    .error => const Icon(Icons.error, color: Colors.red),
    .fatal => const Icon(Icons.campaign, color: Colors.red),
  };
}
