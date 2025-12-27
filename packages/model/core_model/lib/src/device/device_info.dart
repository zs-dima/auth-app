enum OsEnum {
  fuchsia,
  linux,
  macOS,
  windows,
  iOS,
  android,
  unknown,
}

abstract interface class IDeviceInfo {
  String get installationId;
  String get deviceName;
  String get deviceModel;
  String get deviceId;
  OsEnum get deviceOs;
  String get deviceOsVersion;
}
