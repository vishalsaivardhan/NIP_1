import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/packet_model.dart';
import 'simulated_ble.dart';

class BleService {
  // Toggle simulation mode. When true, no platform BLE calls are made and
  // the in-memory simulator is used. This avoids Android runtime permission prompts.
  static bool useSimulated = true;

  static const MethodChannel _channel = MethodChannel('proxiupi/ble');
  static const EventChannel _events = EventChannel('proxiupi/ble/events');

  static Stream<String>? _packetStreamRaw;

  static Future<bool> isBluetoothAvailable() async {
    if (useSimulated) return SimulatedBle.instance.isBluetoothAvailable();
    final res = await _channel.invokeMethod<bool>('isBluetoothAvailable');
    return res ?? false;
  }

  static Future<bool> checkPermissions() async {
    if (useSimulated) return SimulatedBle.instance.checkPermissions();
    final res = await _channel.invokeMethod<bool>('checkPermissions');
    return res ?? false;
  }

  static Future<void> startScan() async {
    if (useSimulated) return SimulatedBle.instance.startScan();
    await _channel.invokeMethod('startScan');
  }

  static Future<void> stopScan() async {
    if (useSimulated) return SimulatedBle.instance.stopScan();
    await _channel.invokeMethod('stopScan');
  }

  static Future<void> startAdvertise() async {
    if (useSimulated) return SimulatedBle.instance.startAdvertise();
    await _channel.invokeMethod('startAdvertise');
  }

  static Future<void> stopAdvertise() async {
    if (useSimulated) return SimulatedBle.instance.stopAdvertise();
    await _channel.invokeMethod('stopAdvertise');
  }

  static Future<void> connect(String deviceId) async {
    if (useSimulated) return SimulatedBle.instance.connect(deviceId);
    await _channel.invokeMethod('connect', {'deviceId': deviceId});
  }

  static Future<void> disconnect(String deviceId) async {
    if (useSimulated) return SimulatedBle.instance.disconnect(deviceId);
    await _channel.invokeMethod('disconnect', {'deviceId': deviceId});
  }

  static Future<void> sendPacket(PacketModel packet) async {
    if (useSimulated) return SimulatedBle.instance.sendPacket(packet);
    final json = jsonEncode(packet.toMap());
    await _channel.invokeMethod('sendPacket', {'packet': json});
  }

  static Stream<PacketModel> packetStream() {
    if (useSimulated) {
      _packetStreamRaw ??= SimulatedBle.instance.stream;
    } else {
      _packetStreamRaw ??= _events.receiveBroadcastStream().map((e) => e as String);
    }
    return _packetStreamRaw!.map((s) => PacketModel.fromMap(jsonDecode(s) as Map<String, dynamic>));
  }
}
