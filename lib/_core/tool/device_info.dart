import 'package:android_id/android_id.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:core_model/core_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platform_info/platform_info.dart';

class DeviceInfo implements IDeviceInfo {
  const DeviceInfo({
    required this.appVersion,
    required this.installationId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.deviceOs,
    required this.deviceOsVersion,
  });

  /// Fallback identity when platform device info is unavailable (web, unsupported platforms, or a
  /// failed plugin read): the stable [installationId] doubles as the device id.
  const DeviceInfo._unknown({
    required this.appVersion,
    required this.installationId,
    required this.deviceOs,
    required String osVersion,
  }) : deviceId = installationId,
       deviceName = 'Unknown device',
       deviceModel = 'Unknown model',
       deviceOsVersion = osVersion;
  @override
  final String appVersion;
  @override
  final String installationId;
  @override
  final String deviceName;
  @override
  final String deviceModel;
  @override
  final String deviceId;
  @override
  final String deviceOs;

  @override
  final String deviceOsVersion;

  static Future<DeviceInfo> instance(String appVersion, String installationId) async {
    final platform = Platform.instance;
    final deviceOs = platform.operatingSystem.toString();

    if (platform.js) {
      return DeviceInfo._unknown(
        appVersion: appVersion,
        installationId: installationId,
        deviceOs: deviceOs,
        osVersion: platform.version,
      );
    }

    final deviceInfo = DeviceInfoPlugin();

    // A device-info read must never block authentication (ClientInfo is session labeling, not a
    // credential): a plugin failure degrades to the unknown-device fallback.
    try {
      switch (platform.operatingSystem) {
        case OperatingSystem$iOS():
          final iosInfo = await deviceInfo.iosInfo;
          return DeviceInfo(
            appVersion: appVersion,
            installationId: installationId,
            deviceId: iosInfo.identifierForVendor ?? installationId,
            deviceName: iosInfo.name,
            deviceModel: iosInfo.model,
            deviceOs: deviceOs,
            deviceOsVersion: platform.version,
          );

        case OperatingSystem$Android():
          const androidIdPlugin = AndroidId();
          final androidId = await androidIdPlugin.getId();
          final androidInfo = await deviceInfo.androidInfo;
          return DeviceInfo(
            appVersion: appVersion,
            installationId: installationId,
            deviceId: androidId ?? installationId,
            deviceName: androidInfo.host,
            deviceModel: androidInfo.model,
            deviceOs: deviceOs,
            deviceOsVersion: platform.version,
          );

        default:
          return DeviceInfo._unknown(
            appVersion: appVersion,
            installationId: installationId,
            deviceOs: deviceOs,
            osVersion: platform.version,
          );
      }
    } on Object catch (error, stackTrace) {
      log.w('Device | info | unavailable', error: error, stackTrace: stackTrace);
      return DeviceInfo._unknown(
        appVersion: appVersion,
        installationId: installationId,
        deviceOs: deviceOs,
        osVersion: platform.version,
      );
    }
  }
}
