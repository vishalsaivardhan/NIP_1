import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';
import '../crypto/crypto_service.dart';
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
    final keyPair = await _signAlgorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    // Attempt to extract private key bytes
    final privateKeyBytes = await _extractPrivateKeyBytes(keyPair);
    await _storage.write(_privateKeyKey, base64Encode(privateKeyBytes));
    await _storage.write(_publicKeyKey, base64Encode(publicKey.bytes));
  }

  Future<Uint8List> _extractPrivateKeyBytes(KeyPair keyPair) async {
    try {
      // SimpleKeyPair has extractPrivateKeyBytes in some versions
      final data = await keyPair.extractPrivateKeyBytes();
      return Uint8List.fromList(data);
    } catch (_) {
      // Fallback: try to export via algorithm-specific API
      throw StateError('Unable to extract private key bytes on this platform/version');
    }
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
    final pubBytes = base64Decode(pub);
    return SimpleKeyPairData(
      privBytes,
      publicKey: SimplePublicKey(pubBytes, type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
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
