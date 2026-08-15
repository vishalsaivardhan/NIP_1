import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/packet_model.dart';

class BleService {
  static const MethodChannel _channel = MethodChannel('proxiupi/ble');
  static const EventChannel _events = EventChannel('proxiupi/ble/events');

  static Stream<String>? _packetStream;

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

  static Future<void> sendPacket(PacketModel packet) async {
    final json = jsonEncode(packet.toMap());
    await _channel.invokeMethod('sendPacket', {'packet': json});
  }

  static Stream<PacketModel> packetStream() {
    _packetStream ??= _events.receiveBroadcastStream().map((e) => e as String);
    return _packetStream!.map((s) => PacketModel.fromMap(jsonDecode(s) as Map<String, dynamic>));
  }
}
