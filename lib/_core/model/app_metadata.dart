import 'dart:io';
import 'dart:ui';

import 'package:auth_app/_core/generated/constant/pubspec.yaml.g.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:meta/meta.dart';
import 'package:platform_info/platform_info.dart';

/// {@template app_metadata}
/// App metadata
/// {@endtemplate}
@immutable
class AppMetadata {
  /// The operating system of the device.
  static final xOperatingSystem = switch (platform.operatingSystem) {
    OperatingSystem$Android() => 'android',
    OperatingSystem$Fuchsia() => 'fuchsia',
    OperatingSystem$iOS() => 'ios',
    OperatingSystem$Linux() => 'linux',
    OperatingSystem$MacOS() => 'macos',
    OperatingSystem$Windows() => 'windows',
    OperatingSystem$Unknown() => 'linux',
  };

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
    HttpHeaders.acceptLanguageHeader: locale,
    'X-Platform': kIsWeb ? 'web' : 'native',
    // 'X-Environment': environment,
    'X-Is-Release': isRelease ? 'true' : 'false',
    'X-App-Version': appVersion,
    'X-App-Version-Major': appVersionMajor.toString(),
    'X-App-Version-Minor': appVersionMinor.toString(),
    'X-App-Version-Patch': appVersionPatch.toString(),
    'X-App-Build-Timestamp': appBuildTimestamp.toUtc().toIso8601String(),
    'X-App-Name': appName,
    'X-Operating-System': xOperatingSystem,
    'X-Processors-Count': processorsCount.toString(),
    'X-Locale': locale,
    // 'X-Device-Version' : deviceVersion,
    'X-Device-Screen-Size': deviceScreenSize,
    // 'X-Device-Identifier': deviceId,
    'X-App-Launched-Timestamp': appLaunchedTimestamp.toUtc().toIso8601String(),
    // 'X-Meta-Is-Web': isWeb ? 'true' : 'false',
    // 'X-Meta-Is-Release': isRelease ? 'true' : 'false',
    // 'X-Meta-App-Version': appVersion,
    // 'X-Meta-App-Version-Major': appVersionMajor.toString(),
    // 'X-Meta-App-Version-Minor': appVersionMinor.toString(),
    // 'X-Meta-App-Version-Patch': appVersionPatch.toString(),
    // 'X-Meta-App-Build-Timestamp': appBuildTimestamp.millisecondsSinceEpoch.toString(),
    // 'X-Meta-App-Name': appName,
    // 'X-Meta-Operating-System': operatingSystem,
    // 'X-Meta-Processors-Count': processorsCount.toString(),
    // 'X-Meta-Locale': locale,
    // 'X-Meta-Device-Version': deviceVersion,
    // 'X-Meta-Device-Screen-Size': deviceScreenSize,
    // 'X-Meta-App-Launched-Timestamp': appLaunchedTimestamp.millisecondsSinceEpoch.toString(),
  };
}
