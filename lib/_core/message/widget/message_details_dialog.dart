import 'package:auth_app/_core/log/telemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template message_details_dialog}
/// Everything recorded about the failure behind a toast.
///
/// Reachable outside production only (`app_message_scope.dart` decides): the
/// user reads one sentence, whoever is debugging reads the rest.
/// {@endtemplate}
class MessageDetailsDialog extends StatelessWidget {
  /// {@macro message_details_dialog}
  const MessageDetailsDialog(this.event, {super.key});

  /// Shows the dialog for [event].
  static Future<void> show(BuildContext context, LogEvent event) =>
      showDialog<void>(context: context, builder: (context) => MessageDetailsDialog(event));

  /// The event behind the message.
  final LogEvent event;

  /// Everything about the failure, as one block for the clipboard.
  String get _full => <String>[
    '${event.timestamp.toIso8601String()} [${event.level.prefix}] ${event.body}',
    for (final MapEntry(:key, :value) in event.attributes.entries) '$key=$value',
    'run_id=${event.runId}',
    if (event.stackTrace case final StackTrace trace) '$trace',
  ].join('\n');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(event.body, style: theme.textTheme.titleSmall),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 8,
              children: <Widget>[
                for (final MapEntry(:key, :value) in event.attributes.entries)
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(text: '$key: ', style: theme.textTheme.labelMedium),
                        TextSpan(text: '$value', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                if (event.stackTrace case final StackTrace trace)
                  Text(trace.toString(), style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: _full)),
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
