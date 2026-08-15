import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import '../security/secure_storage.dart';

class KeyService {
  static const _aesKeyStorageKey = 'aes_key_v1';
  final _storage = SecureStorage.instance;
  final algorithm = AesGcm.with256bits();

  Future<SecretKey> getOrCreateAesKey() async {
    final existing = await _storage.read(_aesKeyStorageKey);
    if (existing != null) {
      final bytes = base64Decode(existing);
      return SecretKeyData(Uint8List.fromList(bytes));
    }

    final key = await algorithm.newSecretKey();
    final keyBytes = await key.extractBytes();
    await _storage.write(_aesKeyStorageKey, base64Encode(keyBytes));
    return SecretKeyData(Uint8List.fromList(keyBytes));
  }
}
