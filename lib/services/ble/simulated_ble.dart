import 'dart:async';
import 'dart:convert';

import '../../models/packet_model.dart';

class SimulatedBle {
  static final SimulatedBle instance = SimulatedBle._();
  SimulatedBle._();

  final StreamController<String> _ctrl = StreamController<String>.broadcast();

  Stream<String> get stream => _ctrl.stream;

  Future<bool> isBluetoothAvailable() async => true;
  Future<bool> checkPermissions() async => true;

  Future<void> startScan() async {}
  Future<void> stopScan() async {}
  Future<void> startAdvertise() async {}
  Future<void> stopAdvertise() async {}
  Future<void> connect(String deviceId) async {}
  Future<void> disconnect(String deviceId) async {}

  Future<void> sendPacket(PacketModel packet) async {
    final json = jsonEncode(packet.toMap());
    // In simulation, immediately emit packet to listeners (loopback)
    _ctrl.add(json);
  }

  // Allow direct injection of incoming packets for tests/demos
  void simulateIncomingJson(String json) => _ctrl.add(json);
}
