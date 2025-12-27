import 'package:auth_app/_core/generated/constant/pubspec.yaml.g.dart';
import 'package:platform_info/platform_info.dart';
import 'package:ui/ui.dart';

/// {@template app_metadata}
/// App metadata
/// {@endtemplate}
@immutable
class AppMetadata {
  /// {@macro app_metadata}
  const AppMetadata({
    required this.isWeb,
    required this.isRelease,
    required this.appVersion,
    required this.appVersionMajor,
    required this.appVersionMinor,
    required this.appVersionPatch,
    required this.appBuildTimestamp,
    required this.appName,
    required this.operatingSystem,
    required this.processorsCount,
    required this.locale,
    required this.deviceVersion,
    required this.deviceScreenSize,
    required this.appLaunchedTimestamp,
  });

  factory AppMetadata.fromApp() => AppMetadata(
    isWeb: platform.js,
    isRelease: platform.buildMode.release,
    appName: Pubspec.name,
    appVersion: Pubspec.version.representation,
    appVersionMajor: Pubspec.version.major,
    appVersionMinor: Pubspec.version.minor,
    appVersionPatch: Pubspec.version.patch,
    appBuildTimestamp:
        Pubspec
            .version
            .build
            .isNotEmpty //
        ? (int.tryParse(Pubspec.version.build.firstOrNull ?? '-1') ?? -1)
        : -1,
    operatingSystem: platform.operatingSystem.name,
    processorsCount: platform.numberOfProcessors,
    appLaunchedTimestamp: DateTime.now(),
    locale: platform.locale,
    deviceVersion: platform.version,
    deviceScreenSize: ScreenUtil.screenSize.representation,
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
  final int appBuildTimestamp;

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
    'X-Meta-App-Build-Timestamp': appBuildTimestamp.toString(),
    'X-Meta-App-Name': appName,
    'X-Meta-Operating-System': operatingSystem,
    'X-Meta-Processors-Count': processorsCount.toString(),
    'X-Meta-Locale': locale,
    'X-Meta-Device-Version': deviceVersion,
    'X-Meta-Device-Screen-Size': deviceScreenSize,
    'X-Meta-App-Launched-Timestamp': appLaunchedTimestamp.millisecondsSinceEpoch.toString(),
  };
}
