import 'dart:ui';

import 'package:auth_app/_core/generated/constant/pubspec.yaml.g.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:meta/meta.dart';
import 'package:platform_info/platform_info.dart';

/// {@template app_metadata}
/// App metadata
/// {@endtemplate}
@immutable
class AppMetadata {
  /// {@macro app_metadata}
  const AppMetadata({
    required this.appName,
    required this.appVersion,
    required this.appVersionMajor,
    required this.appVersionMinor,
    required this.appVersionPatch,
    required this.appBuildTimestamp,
    required this.appLaunchedTimestamp,
    required this.deviceScreenSize,
    required this.operatingSystem,
    required this.processorsCount,
    required this.isWeb,
    required this.isRelease,
    required this.locale,
    required this.deviceVersion,
  });

  /// Platform factory
  ///
  /// {@macro app_metadata}
  factory AppMetadata.platform() => AppMetadata(
    appName: 'Auth app', // TODO: Pubspec.name,
    appVersion: Pubspec.version.canonical,
    appVersionMajor: Pubspec.version.major,
    appVersionMinor: Pubspec.version.minor,
    appVersionPatch: Pubspec.version.patch,
    appBuildTimestamp: Pubspec.timestamp,
    appLaunchedTimestamp: DateTime.now().toUtc(),
    deviceScreenSize: // ScreenUtil.screenSize.representation,
    switch (PlatformDispatcher.instance.implicitView) {
      // ignore: prefer_expression_function_bodies
      FlutterView(:final physicalSize, :final devicePixelRatio) => (Size size) {
        return '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}';
      }(physicalSize / devicePixelRatio),
      _ => '?',
    },
    deviceVersion: platform.version,
    isWeb: const bool.fromEnvironment('dart.library.js_util'), // platform.js,
    isRelease: const bool.fromEnvironment('dart.vm.product'), // platform.buildMode.release,
    locale: PlatformDispatcher.instance.locale.languageCode, // platform.locale,
    operatingSystem: defaultTargetPlatform.name, // platform.operatingSystem.name,
    processorsCount: platform.numberOfProcessors,
  );

  /// Is web platform
  final bool isWeb;

  /// Is release build
  final bool isRelease;

  /// App version
  final String appVersion;

  /// App version major
  final int appVersionMajor;

  /// App version minor
  final int appVersionMinor;

  /// App version patch
  final int appVersionPatch;

  /// App build timestamp
  final DateTime appBuildTimestamp;

  /// App name
  final String appName;

  /// Operating system
  final String operatingSystem;

  /// Processors count
  final int processorsCount;

  /// Locale
  final String locale;

  /// Device representation
  final String deviceVersion;

  /// Device logical screen size
  final String deviceScreenSize;

  /// App launched timestamp
  final DateTime appLaunchedTimestamp;

  /// Convert to headers
  Map<String, String> toHeaders() => <String, String>{
    'X-Meta-Is-Web': isWeb ? 'true' : 'false',
    'X-Meta-Is-Release': isRelease ? 'true' : 'false',
    'X-Meta-App-Version': appVersion,
    'X-Meta-App-Version-Major': appVersionMajor.toString(),
    'X-Meta-App-Version-Minor': appVersionMinor.toString(),
    'X-Meta-App-Version-Patch': appVersionPatch.toString(),
    'X-Meta-App-Build-Timestamp': appBuildTimestamp.millisecondsSinceEpoch.toString(),
    'X-Meta-App-Name': appName,
    'X-Meta-Operating-System': operatingSystem,
    'X-Meta-Processors-Count': processorsCount.toString(),
    'X-Meta-Locale': locale,
    'X-Meta-Device-Version': deviceVersion,
    'X-Meta-Device-Screen-Size': deviceScreenSize,
    'X-Meta-App-Launched-Timestamp': appLaunchedTimestamp.millisecondsSinceEpoch.toString(),
  };
}
