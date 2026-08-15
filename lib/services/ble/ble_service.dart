import 'dart:async';
import 'package:flutter/services.dart';

class BleService {
  static const MethodChannel _channel = MethodChannel('proxiupi/ble');

  static Future<bool> isBluetoothAvailable() async {
    final res = await _channel.invokeMethod<bool>('isBluetoothAvailable');
    return res ?? false;
  }

  static Future<bool> checkPermissions() async {
    final res = await _channel.invokeMethod<bool>('checkPermissions');
    return res ?? false;
  }

  static Future<void> startScan() async {
    await _channel.invokeMethod('startScan');
  }

  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
  }

  static Future<void> startAdvertise() async {
    await _channel.invokeMethod('startAdvertise');
  }

  static Future<void> stopAdvertise() async {
    await _channel.invokeMethod('stopAdvertise');
  }

  static Future<void> connect(String deviceId) async {
    await _channel.invokeMethod('connect', {'deviceId': deviceId});
  }

  static Future<void> disconnect(String deviceId) async {
    await _channel.invokeMethod('disconnect', {'deviceId': deviceId});
  }
}
