import 'dart:async';

import 'package:auth_app/app/log/logger.dart';
import 'package:flutter/foundation.dart';

/// Catch all application errors and logs.
void appZone(FutureOr<void> Function() fn) => logger.runLogging(
      () => runZonedGuarded<void>(
        () => fn(),
        logger.logZoneError,
      ),
      const LogOptions(
        logInRelease: true,
        printColors: kDebugMode,
      ),
    );
