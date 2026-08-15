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
    SecretBox secretBox;
    if (aad != null) {
      secretBox = await algorithm.encrypt(
        plaintext,
        secretKey: key,
        nonce: nonce,
        aad: aad,
      );
    } else {
      secretBox = await algorithm.encrypt(
        plaintext,
        secretKey: key,
        nonce: nonce,
      );
    }
    final concat = secretBox.concatenation();
    return Uint8List.fromList(concat ?? <int>[]);
  }

  Future<List<int>> decrypt(SecretKey key, List<int> data, List<int> nonce, {List<int>? aad}) async {
    final macBytes = data.sublist(data.length - 16);
    final cipherText = data.sublist(0, data.length - 16);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
    final List<int> plaintext;
    if (aad != null) {
      plaintext = await algorithm.decrypt(secretBox, secretKey: key, aad: aad);
    } else {
      plaintext = await algorithm.decrypt(secretBox, secretKey: key);
    }
    return plaintext;
  }
}
