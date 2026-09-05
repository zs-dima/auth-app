import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:ui/ui.dart';

/// {@template crash_reports_switch}
/// "Send crash reports" toggle. Persists the choice and (de)activates the crash-reporting sink
/// immediately, so the change takes effect without a restart. Debug builds never report
/// regardless of this switch (see the 'Error tracking' init step).
/// {@endtemplate}
class CrashReportsSwitch extends StatefulWidget {
  /// {@macro crash_reports_switch}
  const CrashReportsSwitch({super.key});

  @override
  State<CrashReportsSwitch> createState() => _CrashReportsSwitchState();
}

class _CrashReportsSwitchState extends State<CrashReportsSwitch> {
  bool? _enabled;
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    if (_busy) return;
    final dependencies = InheritedDependencies.of(context);
    setState(() {
      _busy = true;
      _enabled = value;
    });
    try {
      await dependencies.settings.setSendCrashReports(value);
      // Live (de)activation; best-effort — the persisted switch governs the next start anyway.
      if (value) {
        await dependencies.crashReporting.enableReporting();
      } else {
        await dependencies.crashReporting.disableReporting();
      }
    } on Object catch (error, stackTrace) {
      // Without this the failure escaped as an unhandled async error, became
      // `Zone | uncaught | error` and filed a crash-reporter issue — for a
      // settings write. And the switch stayed where the user put it, showing a
      // preference that is not stored.
      reportFailure(
        'Settings | crashReports | failed',
        error,
        stackTrace: stackTrace,
        caption: 'Could not save your settings.',
        level: .warn,
      );
      if (mounted) setState(() => _enabled = !value);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled ?? InheritedDependencies.of(context).settings.sendCrashReports;
    return SwitchListTile.adaptive(
      title: const AppText.titleMedium('Send crash reports'),
      value: enabled,
      onChanged: _busy ? null : _toggle,
    );
  }
}
