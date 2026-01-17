import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:platform_info/platform_info.dart';

/// {@template metadata_middleware}
/// Middleware for adding metadata to header of API requests.
/// {@endtemplate}
@immutable
class MetadataMiddleware {
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

  /// {@macro metadata_middleware}
  MetadataMiddleware({required this.metadata, required String environment})
    : _predefined = <String, String>{
        'Accept-Language': metadata.locale,
        'X-Platform': kIsWeb ? 'web' : 'native',
        'X-Environment': environment,
        'X-Is-Release': metadata.isRelease ? 'true' : 'false',
        'X-App-Version': metadata.appVersion,
        'X-App-Version-Major': metadata.appVersionMajor.toString(),
        'X-App-Version-Minor': metadata.appVersionMinor.toString(),
        'X-App-Version-Patch': metadata.appVersionPatch.toString(),
        'X-App-Build-Timestamp': metadata.appBuildTimestamp.toUtc().toIso8601String(),
        'X-App-Name': metadata.appName,
        'X-Operating-System': xOperatingSystem,
        'X-Processors-Count': metadata.processorsCount.toString(),
        'X-Locale': metadata.locale,
        // 'X-Device-Version' : metadata.deviceVersion,
        'X-Device-Screen-Size': metadata.deviceScreenSize,
        // 'X-Device-Identifier': deviceInfo.deviceId,
        'X-App-Launched-Timestamp': metadata.appLaunchedTimestamp.toUtc().toIso8601String(),
      };

  final Map<String, String> _predefined;

  /// Metadata to be added to the request.
  @protected
  final AppMetadata metadata;

  ApiClientHandler call(ApiClientHandler innerHandler) =>
      (request, context) => innerHandler(request..headers.addAll(_predefined), context);
}
