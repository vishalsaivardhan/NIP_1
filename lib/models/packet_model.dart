class PacketModel {
  final String packetId;
  final String transactionId;
  final String source;
  final String destination;
  final int ttl;
  final String packetType;
  final String encryptedPayload;
  final int hopCount;

  PacketModel({
    required this.packetId,
    required this.transactionId,
    required this.source,
    required this.destination,
    this.ttl = 10,
    required this.packetType,
    required this.encryptedPayload,
    this.hopCount = 0,
  });

  Map<String, Object?> toMap() => {
        'packetId': packetId,
        'transactionId': transactionId,
        'source': source,
        'destination': destination,
        'ttl': ttl,
        'packetType': packetType,
        'encryptedPayload': encryptedPayload,
        'hopCount': hopCount,
      };

  factory PacketModel.fromMap(Map<String, dynamic> m) => PacketModel(
        packetId: m['packetId'] as String,
        transactionId: m['transactionId'] as String,
        source: m['source'] as String,
        destination: m['destination'] as String,
        ttl: (m['ttl'] as int?) ?? 10,
        packetType: m['packetType'] as String,
        encryptedPayload: m['encryptedPayload'] as String,
        hopCount: (m['hopCount'] as int?) ?? 0,
      );
}
