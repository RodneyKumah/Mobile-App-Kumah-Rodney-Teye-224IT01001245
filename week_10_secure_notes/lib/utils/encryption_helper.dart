import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static final key =
      Key.fromUtf8('my32lengthsupersecretkey1234567890');
  static final iv = IV.fromLength(16);

  static String encrypt(String text) {
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(text, iv: iv).base64;
  }

  static String decrypt(String text) {
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt64(text, iv: iv);
  }
}