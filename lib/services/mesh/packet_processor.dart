import 'dart:async';

import 'dart:convert';
// dart:typed_data not required

import 'package:cryptography/cryptography.dart';

import '../../data/local/database.dart';
import '../../models/packet_model.dart';
import '../ble/ble_service.dart';
import '../security/identity_service.dart';
import '../crypto/crypto_service.dart';
import '../crypto/key_service.dart';

class PacketProcessor {
  static final PacketProcessor instance = PacketProcessor._();
  PacketProcessor._();

  StreamSubscription? _sub;
  final AppDatabase _db = AppDatabase.instance;
  final IdentityService _identity = IdentityService();
  final CryptoService _crypto = CryptoService();
  final KeyService _keyService = KeyService();

  Future<void> start() async {
    if (_sub != null) return;
    _sub = BleService.packetStream().listen(_onPacket, onError: (e) {});
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<bool> _seenPacket(String packetId) async {
    final db = await _db.database;
    final rows = await db.query('packets', where: 'packetId = ?', whereArgs: [packetId]);
    return rows.isNotEmpty;
  }

  Future<void> _markSeen(PacketModel p) async {
    final db = await _db.database;
    await db.insert('packets', {
      'packetId': p.packetId,
      'transactionId': p.transactionId,
      'source': p.source,
      'destination': p.destination,
      'packetType': p.packetType,
      'encryptedPayload': p.encryptedPayload,
      'ttl': p.ttl,
      'hopCount': p.hopCount,
      'firstSeenAt': DateTime.now().millisecondsSinceEpoch,
      'forwardedAt': null,
    });
  }

  Future<void> _markForwarded(String packetId) async {
    final db = await _db.database;
    await db.update('packets', {'forwardedAt': DateTime.now().millisecondsSinceEpoch}, where: 'packetId = ?', whereArgs: [packetId]);
  }

  Future<void> _onPacket(PacketModel p) async {
    try {
      if (await _seenPacket(p.packetId)) return;
      await _markSeen(p);

      final me = await _identity.getOrCreateDeviceId();

      if (p.destination == me) {
        // Attempt to decrypt and verify signature if fields present
        String status = 'RECEIVED';
        int amount = 0;
        String? signatureB64 = p.signature;
        try {
          if (p.nonce != null && p.encryptedPayload.isNotEmpty) {
            final secretKey = await _keyService.getOrCreateAesKey();
            final encryptedBytes = base64Decode(p.encryptedPayload);
            final nonceBytes = base64Decode(p.nonce!);
            final plain = await _crypto.decrypt(secretKey, encryptedBytes, nonceBytes);
            final payloadJson = utf8.decode(plain);
            final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
            amount = (payload['amount'] as int?) ?? 0;

            // Verify signature if sender public key and signature available
            if (p.senderPublicKey != null && signatureB64 != null) {
              final sigBytes = base64Decode(signatureB64);
              final pubBytes = base64Decode(p.senderPublicKey!);
              final pubKey = SimplePublicKey(pubBytes, type: KeyPairType.ed25519);
              final isValid = await _crypto.signatureAlgorithm.verify(
                plain,
                signature: Signature(sigBytes, publicKey: pubKey),
              );
              status = isValid ? 'VERIFIED' : 'INVALID_SIGNATURE';
            }
          }
        } catch (e) {
          // decryption or verification failed; keep as RECEIVED
          status = 'RECEIVED_ERROR';
        }

        final db = await _db.database;
        await db.insert('transactions', {
          'transactionId': p.transactionId,
          'senderDeviceId': p.source,
          'receiverDeviceId': p.destination,
          'amount': amount,
          'currency': 'INR',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'expiresAt': null,
          'nonce': p.nonce,
          'counter': null,
          'signature': signatureB64,
          'encryptedPayload': p.encryptedPayload,
          'ttl': p.ttl,
          'status': status,
          'hopCount': p.hopCount,
        });
        return;
      }

      // Not for me: forward if TTL remains
      if (p.ttl > 0) {
        final fwd = PacketModel(
          packetId: p.packetId,
          transactionId: p.transactionId,
          source: p.source,
          destination: p.destination,
          ttl: p.ttl - 1,
          packetType: p.packetType,
          encryptedPayload: p.encryptedPayload,
          hopCount: p.hopCount + 1,
        );

        await BleService.sendPacket(fwd);
        await _markForwarded(p.packetId);
      }
    } catch (e) {
      // ignore errors in prototype
    }
  }
}
