class TransactionModel {
  final String transactionId;
  final String senderDeviceId;
  final String receiverDeviceId;
  final int amount;
  final String currency;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? nonce;
  final int? counter;
  final String? signature;
  final String? encryptedPayload;
  final int ttl;
  final String status;
  final int hopCount;

  TransactionModel({
    required this.transactionId,
    required this.senderDeviceId,
    required this.receiverDeviceId,
    required this.amount,
    this.currency = 'INR',
    required this.createdAt,
    this.expiresAt,
    this.nonce,
    this.counter,
    this.signature,
    this.encryptedPayload,
    this.ttl = 10,
    this.status = 'CREATED',
    this.hopCount = 0,
  });

  Map<String, Object?> toMap() {
    return {
      'transactionId': transactionId,
      'senderDeviceId': senderDeviceId,
      'receiverDeviceId': receiverDeviceId,
      'amount': amount,
      'currency': currency,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'nonce': nonce,
      'counter': counter,
      'signature': signature,
      'encryptedPayload': encryptedPayload,
      'ttl': ttl,
      'status': status,
      'hopCount': hopCount,
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?> m) {
    return TransactionModel(
      transactionId: m['transactionId'] as String,
      senderDeviceId: m['senderDeviceId'] as String,
      receiverDeviceId: m['receiverDeviceId'] as String,
      amount: m['amount'] as int,
      currency: (m['currency'] as String?) ?? 'INR',
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      expiresAt: m['expiresAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(m['expiresAt'] as int),
      nonce: m['nonce'] as String?,
      counter: m['counter'] as int?,
      signature: m['signature'] as String?,
      encryptedPayload: m['encryptedPayload'] as String?,
      ttl: (m['ttl'] as int?) ?? 10,
      status: (m['status'] as String?) ?? 'CREATED',
      hopCount: (m['hopCount'] as int?) ?? 0,
    );
  }
}
