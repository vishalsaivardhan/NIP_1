import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../data/local/database.dart';
import '../../models/transaction_model.dart';
import '../security/identity_service.dart';

class TransactionService {
  final AppDatabase _db = AppDatabase.instance;
  final IdentityService _identity = IdentityService();

  Future<TransactionModel> createTransaction({required String receiverDeviceId, required int amount}) async {
    final txId = const Uuid().v4();
    final sender = await _identity.getOrCreateDeviceId();
    final now = DateTime.now();
    final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));

    final tx = TransactionModel(
      transactionId: txId,
      senderDeviceId: sender,
      receiverDeviceId: receiverDeviceId,
      amount: amount,
      createdAt: now,
      nonce: base64Encode(nonce),
      ttl: 10,
      status: 'CREATED',
    );

    final db = await _db.database;
    await db.insert('transactions', tx.toMap());
    return tx;
  }

  Future<List<TransactionModel>> pendingTransactions() async {
    final db = await _db.database;
    final rows = await db.query('transactions', where: 'status IN (?,?,?)', whereArgs: ['CREATED', 'QUEUED', 'FORWARDED']);
    return rows.map((r) => TransactionModel.fromMap(r)).toList();
  }

  Future<void> markAsQueued(String transactionId) async {
    final db = await _db.database;
    await db.update('transactions', {'status': 'QUEUED'}, where: 'transactionId = ?', whereArgs: [transactionId]);
  }

  Future<void> markAsForwarded(String transactionId) async {
    final db = await _db.database;
    await db.update('transactions', {'status': 'FORWARDED'}, where: 'transactionId = ?', whereArgs: [transactionId]);
  }
}
