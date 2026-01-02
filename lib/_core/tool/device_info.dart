import 'package:android_id/android_id.dart';
import 'package:core_model/core_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platform_info/platform_info.dart';

class DeviceInfo implements IDeviceInfo {
  const DeviceInfo({
    required this.installationId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.deviceOs,
    required this.deviceOsVersion,
  });

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

  static Future<DeviceInfo> instance(String installationId) async {
    final platform = Platform.instance;
    final deviceOs = platform.operatingSystem.toString();

    if (platform.js) {
      return DeviceInfo(
        installationId: installationId,
        deviceId: installationId,
        deviceName: 'Unknown device',
        deviceModel: 'Unknown model',
        deviceOs: deviceOs,
        deviceOsVersion: platform.version,
      );
    }

    final deviceInfo = DeviceInfoPlugin();

    switch (platform.operatingSystem) {
      case OperatingSystem$iOS():
        final iosInfo = await deviceInfo.iosInfo;
        return DeviceInfo(
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
          installationId: installationId,
          deviceId: androidId ?? installationId,
          deviceName: androidInfo.host,
          deviceModel: androidInfo.model,
          deviceOs: deviceOs,
          deviceOsVersion: platform.version,
        );

      default:
        return DeviceInfo(
          installationId: installationId,
          deviceId: installationId,
          deviceName: 'Unknown device',
          deviceModel: 'Unknown model',
          deviceOs: deviceOs,
          deviceOsVersion: platform.version,
        );
    }
  }
}
