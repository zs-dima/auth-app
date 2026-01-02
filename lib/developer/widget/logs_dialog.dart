import 'package:auth_app/_core/database/database.dart' as db;
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l/l.dart';
import 'package:octopus/octopus.dart';

/// {@template logs_dialog}
/// LogsDialog widget.
/// {@endtemplate}
class LogsDialog extends StatelessWidget {
  /// {@macro logs_dialog}
  const LogsDialog({super.key});

  /// Show the logs screen
  static Future<void> show(BuildContext context) =>
      Octopus.of(context).showDialog<void>((context) => const LogsDialog());

  @override
  Widget build(BuildContext context) => const Dialog(
    elevation: 8,
    insetPadding: .all(36.0),
    shape: RoundedRectangleBorder(borderRadius: .vertical(bottom: .circular(16.0))),
    child: _LogsList(),
  );
}

class _LogsList extends StatefulWidget {
  const _LogsList();

  @override
  State<_LogsList> createState() => _LogsListState();
}

/// State for widget _LogsList.
class _LogsListState extends State<_LogsList> {
  final _controller = TextEditingController();
  late List<LogMessage> _logs = <LogMessage>[];
  late List<LogMessage> _filteredLogs = <LogMessage>[];

  @override
  void initState() {
    super.initState();
    final database = context.dependencies.database;
    Future<void>(() async {
      final logTbl = database.logTbl;
      final rows = await (database.select(
        logTbl,
      )..orderBy([(tbl) => db.OrderingTerm(expression: tbl.time, mode: db.OrderingMode.desc)])).get();
      _logs = rows
          .map(
            (l) => l.stack == null
                ? LogMessage.verbose(
                    timestamp: DateTime.fromMillisecondsSinceEpoch(l.time * 1000),
                    level: LogLevel.fromValue(l.level),
                    message: l.message,
                  )
                : LogMessage.error(
                    timestamp: DateTime.fromMillisecondsSinceEpoch(l.time * 1000),
                    level: LogLevel.fromValue(l.level),
                    message: l.message,
                    stackTrace: StackTrace.fromString(l.stack!),
                  ),
          )
          .toList();
      await _filter();
    });
    _controller.addListener(_filter);
  }

  Future<void> _filter() async {
    final search = _controller.text.toLowerCase();
    final stopwatch = Stopwatch()..start();
    final buffer = _logs.toList();
    try {
      LogMessage log;
      var pos = 0;
      for (var i = 0; i < buffer.length; i++) {
        if (stopwatch.elapsedMilliseconds > 8) await Future<void>.delayed(.zero);
        log = _logs[i];
        if (log.message.toString().toLowerCase().contains(search)) {
          buffer[pos] = log;
          pos++;
        }
      }
      _filteredLogs = buffer..length = pos;
    } finally {
      stopwatch.stop();
    }
    if (mounted) setState(() {});
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
          /* actions: <Widget>[
                IconButton(icon: const Icon(Icons.delete), onPressed: () => buffer.clear()),
                const SizedBox(width: 16.0),
              ], */
          floating: true,
          pinned: MediaQuery.sizeOf(context).height > 600,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72.0),
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
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
                (context, index) => _LogTile(_filteredLogs[index], key: ObjectKey(_filteredLogs[index])),
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
  const _LogTile(this.log, {super.key});

  final LogMessage log;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        title: Text(log.message.toString()),
        subtitle: Text(log.timestamp.format()),
        leading: _LogIcon(log.level),
        dense: true,
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => Clipboard.setData(
            ClipboardData(
              text: switch (log) {
                final LogMessageError err => '${err.message}\n${err.stackTrace}',
                _ => '${log.message}',
              },
            ),
          ),
        ),
      ),
      const Divider(height: 1.0),
    ],
  );
}

class _LogIcon extends StatelessWidget {
  const _LogIcon(this.level);

  final LogLevel level;

  @override
  Widget build(BuildContext context) => level.when<Widget>(
    debug: () => const Icon(Icons.bug_report, color: Colors.indigo),
    info: () => const Icon(Icons.info, color: Colors.blue),
    warning: () => const Icon(Icons.warning, color: Colors.orange),
    error: () => const Icon(Icons.error, color: Colors.red),
    shout: () => const Icon(Icons.campaign, color: Colors.red),
    v: () => const Icon(Icons.looks_one, color: Colors.grey),
    vv: () => const Icon(Icons.looks_two, color: Colors.grey),
    vvv: () => const Icon(Icons.looks_3, color: Colors.grey),
    vvvv: () => const Icon(Icons.looks_4, color: Colors.grey),
    vvvvv: () => const Icon(Icons.looks_5, color: Colors.grey),
    vvvvvv: () => const Icon(Icons.looks_6, color: Colors.grey),
  );
}
