import 'dart:async';
import '../transaction/transaction_service.dart';
import '../ble/ble_service.dart';

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

    for (final tx in pending) {
      // For prototype, mark as QUEUED and then FORWARDED locally.
      await _txService.markAsQueued(tx.transactionId);
      // Placeholder for real forwarding via BLE; mark forwarded.
      await _txService.markAsForwarded(tx.transactionId);
    }
  }
}
