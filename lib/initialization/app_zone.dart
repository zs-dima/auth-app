import 'dart:async';

import 'package:auth_app/_core/log/console.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:flutter/foundation.dart';

/// Runs the whole app inside the telemetry zone.
///
/// Two nested guards, in this order on purpose: the telemetry zone installs the
/// `print` interceptor and the console options, and `runZonedGuarded` inside it
/// catches every asynchronous error that no `try` claimed — including the ones
/// thrown after an `await` that never had a listener, which a plain try/catch
/// cannot see.
void appZone(AsyncCallback fn) => log.zoned(
  () => runZonedGuarded<void>(() => fn(), logZoneError),
  options: kConsoleOptions,
);
