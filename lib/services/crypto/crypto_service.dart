import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  final algorithm = AesGcm.with256bits();
  final signatureAlgorithm = Ed25519();

  Future<SecretKey> generateAesKey() async {
    final key = await algorithm.newSecretKey();
    return key;
  }

  Future<SimpleKeyPair> generateEd25519KeyPair() async {
    return await signatureAlgorithm.newKeyPair();
  }

  Future<Uint8List> encrypt(SecretKey key, List<int> nonce, List<int> plaintext, {List<int>? aad}) async {
    final secretBox = await algorithm.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
      aad: aad,
    );
    return Uint8List.fromList(secretBox.concatenation());
  }

  Future<List<int>> decrypt(SecretKey key, List<int> data, List<int> nonce, {List<int>? aad}) async {
    final secretBox = SecretBox(data.sublist(0, data.length - 16), nonce: nonce, mac: Mac(data.sublist(data.length - 16)));
    final plaintext = await algorithm.decrypt(secretBox, secretKey: key, aad: aad);
    return plaintext;
  }
}
