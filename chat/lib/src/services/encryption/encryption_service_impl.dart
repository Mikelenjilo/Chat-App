import 'package:chat/src/services/encryption/encryption_service_contract.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryption {
  final Encrypter _encrypter;
  final IV _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String decrypt(String cipherText) {
    final encrypted = Encrypted.fromBase64(cipherText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }
}
