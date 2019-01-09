import 'dart:async';

import 'package:flutter/services.dart';

class SimplePermissions {
  static const MethodChannel _channel =
      const MethodChannel('simple_permissions');

  static Future<String> get platformVersion async {
    final String platform = await _channel.invokeMethod('getPlatformVersion');
    return platform;
  }

  /// Check a [permission] and return a [Future] with the result
  static Future<bool> checkPermission(Permission permission) async {
    final bool isGranted = await _channel.invokeMethod(
        "checkPermission", {"permission": getPermissionString(permission)});
    return isGranted;
  }

  /// Request a [permission] and return a [Future] with the result
  static Future<PermissionStatus> requestPermission(
      Permission permission) async {
    final status = await _channel.invokeMethod(
        "requestPermission", {"permission": getPermissionString(permission)});

    return status is int
        ? intToPermissionStatus(status)
        : status is bool
            ? (status ? PermissionStatus.authorized : PermissionStatus.denied)
            : PermissionStatus.notDetermined;
  }

  /// Open app settings on Android and iOs
  static Future<bool> openSettings() async {
    final bool isOpen = await _channel.invokeMethod("openSettings");

    return isOpen;
  }

  static Future<PermissionStatus> getPermissionStatus(
      Permission permission) async {
    final int status = await _channel.invokeMethod(
        "getPermissionStatus", {"permission": getPermissionString(permission)});
    return intToPermissionStatus(status);
  }

  static PermissionStatus intToPermissionStatus(int status) {
    switch (status) {
      case 0:
        return PermissionStatus.notDetermined;
      case 1:
        return PermissionStatus.restricted;
      case 2:
        return PermissionStatus.denied;
      case 3:
        return PermissionStatus.authorized;
      case 4:
        return PermissionStatus.deniedNeverAsk;
      default:
        return PermissionStatus.notDetermined;
    }
  }
}

/// Enum of all available [Permission]
enum Permission {
  RecordAudio,
  CallPhone,
  Camera,
  PhotoLibrary,
  WriteExternalStorage,
  ReadExternalStorage,
  ReadPhoneState,
  AccessCoarseLocation,
  AccessFineLocation,
  WhenInUseLocation,
  AlwaysLocation,
  ReadContacts,
  ReadSms,
  SendSMS,
  Vibrate,
  WriteContacts,
  AccessMotionSensor
}

/// Permissions status enum (iOs: notDetermined, restricted, denied, authorized, deniedNeverAsk)
/// (Android: denied, authorized, deniedNeverAsk)
enum PermissionStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
  deniedNeverAsk /* android */
}

String getPermissionString(Permission permission) {
  String res;
  switch (permission) {
    case Permission.CallPhone:
      res = "CALL_PHONE";
      break;
    case Permission.Camera:
      res = "CAMERA";
      break;
    case Permission.PhotoLibrary:
      res = "PHOTO_LIBRARY";
      break;
    case Permission.RecordAudio:
      res = "RECORD_AUDIO";
      break;
    case Permission.WriteExternalStorage:
      res = "WRITE_EXTERNAL_STORAGE";
      break;
    case Permission.ReadExternalStorage:
      res = "READ_EXTERNAL_STORAGE";
      break;
    case Permission.ReadPhoneState:
      res = "READ_PHONE_STATE";
      break;
    case Permission.AccessFineLocation:
      res = "ACCESS_FINE_LOCATION";
      break;
    case Permission.AccessCoarseLocation:
      res = "ACCESS_COARSE_LOCATION";
      break;
    case Permission.WhenInUseLocation:
      res = "WHEN_IN_USE_LOCATION";
      break;
    case Permission.AlwaysLocation:
      res = "ALWAYS_LOCATION";
      break;
    case Permission.ReadContacts:
      res = "READ_CONTACTS";
      break;
    case Permission.SendSMS:
      res = "SEND_SMS";
      break;
    case Permission.ReadSms:
      res = "READ_SMS";
      break;
    case Permission.Vibrate:
      res = "VIBRATE";
      break;
    case Permission.WriteContacts:
      res = "WRITE_CONTACTS";
      break;
    case Permission.AccessMotionSensor:
      res = "MOTION_SENSOR";
      break;
  }
  return res;
}
