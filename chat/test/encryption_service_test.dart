import 'package:chat/src/services/encryption/encryption_service_contract.dart';
import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IEncryption sut;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    sut = EncryptionService(encrypter);
  });

  test('it encrypts the plain text', () {
    const String plainText = 'this is a messag';
    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

    final cipherText = sut.encrypt(plainText);

    expect(base64.hasMatch(cipherText), true);
  });

  test('it decrypts the cipher text', () {
    const String text = 'this is a message';
    final cipherText = sut.encrypt(text);
    final plainText = sut.decrypt(cipherText);

    expect(plainText, text);
  });
}
