import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _notesKey = 'notes';
  static const _pinKey = 'pin';

  static Future<void> saveNotes(String data) async {
    await _storage.write(key: _notesKey, value: data);
  }

  static Future<String?> loadNotes() async {
    return await _storage.read(key: _notesKey);
  }

  static Future<void> savePin(String hash) async {
    await _storage.write(key: _pinKey, value: hash);
  }

  static Future<String?> loadPin() async {
    return await _storage.read(key: _pinKey);
  }
}