import 'dart:async';

import '../../data/local/database.dart';
import '../../models/packet_model.dart';
import '../ble/ble_service.dart';
import '../security/identity_service.dart';

class PacketProcessor {
  static final PacketProcessor instance = PacketProcessor._();
  PacketProcessor._();

  StreamSubscription? _sub;
  final AppDatabase _db = AppDatabase.instance;
  final IdentityService _identity = IdentityService();

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
        // Store as received transaction (encrypted payload retained)
        final db = await _db.database;
        await db.insert('transactions', {
          'transactionId': p.transactionId,
          'senderDeviceId': p.source,
          'receiverDeviceId': p.destination,
          'amount': 0,
          'currency': 'INR',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'expiresAt': null,
          'nonce': null,
          'counter': null,
          'signature': null,
          'encryptedPayload': p.encryptedPayload,
          'ttl': p.ttl,
          'status': 'RECEIVED',
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
