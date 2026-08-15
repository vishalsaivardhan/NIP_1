import 'dart:async';
import 'package:uuid/uuid.dart';
import '../transaction/transaction_service.dart';
import '../ble/ble_service.dart';
import '../../models/packet_model.dart';
import '../security/identity_service.dart';

class QueueService {
  final TransactionService _txService = TransactionService();
  Timer? _timer;

  void startPoll([Duration interval = const Duration(seconds: 5)]) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _tryForwardPending());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tryForwardPending() async {
    final pending = await _txService.pendingTransactions();
    if (pending.isEmpty) return;

    final bleAvailable = await BleService.isBluetoothAvailable();
    if (!bleAvailable) return;

    final idGen = const Uuid();
    final identity = IdentityService();
    final sourceId = await identity.getOrCreateDeviceId();

    for (final tx in pending) {
      await _txService.markAsQueued(tx.transactionId);

      final packet = PacketModel(
        packetId: idGen.v4(),
        transactionId: tx.transactionId,
        source: sourceId,
        destination: tx.receiverDeviceId,
        ttl: tx.ttl,
        packetType: 'TRANSACTION',
        encryptedPayload: tx.encryptedPayload ?? '',
        hopCount: tx.hopCount,
      );

      try {
        await BleService.sendPacket(packet);
        await _txService.markAsForwarded(tx.transactionId);
      } catch (e) {
        // sending failed; leave as QUEUED for next attempt
      }
    }
  }
}
