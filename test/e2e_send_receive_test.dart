import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:nip/services/security/identity_service.dart';
import 'package:nip/services/crypto/crypto_service.dart';
import 'package:nip/services/crypto/key_service.dart';
import 'package:nip/services/ble/simulated_ble.dart';
import 'package:nip/services/mesh/packet_processor.dart';
import 'package:nip/models/packet_model.dart';
import 'package:nip/data/local/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('end-to-end send->receive->verify (simulated)', () async {
    final identity = IdentityService();
    await identity.generateAndStoreKeypair();
    final myId = await identity.getOrCreateDeviceId();

    final keyService = KeyService();
    final crypto = CryptoService();

    final txId = const Uuid().v4();
    final payload = {
      'transactionId': txId,
      'sender': 'SENDER-TEST',
      'receiver': myId,
      'amount': 123,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final payloadBytes = utf8.encode(jsonEncode(payload));
    final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));
    final aesKey = await keyService.getOrCreateAesKey();
    final encrypted = await crypto.encrypt(aesKey, nonce, payloadBytes);

    final sig = await identity.sign(payloadBytes);
    final sigB64 = base64Encode(sig);
    final pubB64 = await identity.getPublicKeyBase64();

    final packet = PacketModel(
      packetId: const Uuid().v4(),
      transactionId: txId,
      source: 'SENDER-TEST',
      destination: myId,
      packetType: 'TRANSACTION',
      encryptedPayload: base64Encode(encrypted),
      signature: sigB64,
      senderPublicKey: pubB64,
      nonce: base64Encode(nonce),
      hopCount: 0,
    );

    // start processor and simulate incoming packet
    await PacketProcessor.instance.start();
    SimulatedBle.instance.simulateIncomingJson(jsonEncode(packet.toMap()));

    // wait a short while for processing
    await Future.delayed(const Duration(seconds: 1));

    final db = await AppDatabase.instance.database;
    final rows = await db.query('transactions', where: 'transactionId = ?', whereArgs: [txId]);
    expect(rows.length, 1);
    expect(rows.first['status'], 'VERIFIED');
    expect(rows.first['amount'], 123);
  });
}
