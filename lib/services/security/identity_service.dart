import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';
import 'secure_storage.dart';

class IdentityService {
  static const _deviceIdKey = 'device_id';
  static const _privateKeyKey = 'ed25519_private';
  static const _publicKeyKey = 'ed25519_public';

  final _storage = SecureStorage.instance;
  final _signAlgorithm = Ed25519();

  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(_deviceIdKey);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await _storage.write(_deviceIdKey, id);
    return id;
  }

  Future<void> generateAndStoreKeypair() async {
    // Generate a 32-byte seed and derive the ed25519 keypair from it.
    final seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final keyPair = await _signAlgorithm.newKeyPairFromSeed(seed);
    final publicKey = await keyPair.extractPublicKey();
    await _storage.write(_privateKeyKey, base64Encode(seed));
    await _storage.write(_publicKeyKey, base64Encode(publicKey.bytes));
  }

  Future<String?> getPublicKeyBase64() => _storage.read(_publicKeyKey);

  Future<SimplePublicKey?> getPublicKey() async {
    final b = await getPublicKeyBase64();
    if (b == null) return null;
    final bytes = base64Decode(b);
    return SimplePublicKey(bytes, type: KeyPairType.ed25519);
  }

  Future<SimpleKeyPair> _loadKeyPair() async {
    final priv = await _storage.read(_privateKeyKey);
    final pub = await _storage.read(_publicKeyKey);
    if (priv == null || pub == null) {
      throw StateError('Keypair not found');
    }
    final privBytes = base64Decode(priv);
    // Recreate keypair from seed
    final keyPair = await _signAlgorithm.newKeyPairFromSeed(privBytes);
    return keyPair;
  }

  Future<List<int>> sign(List<int> data) async {
    final keyPair = await _loadKeyPair();
    final signature = await _signAlgorithm.sign(
      data,
      keyPair: keyPair,
    );
    return signature.bytes;
  }
}
