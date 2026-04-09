import 'dart:convert';
import '../models/note.dart';
import '../utils/encryption_helper.dart';
import 'secure_storage_service.dart';

class NotesService {
  List<Note> notes = [];

  Future<void> loadNotes() async {
    final data = await SecureStorageService.loadNotes();
    if (data == null) return;

    final decrypted = EncryptionHelper.decrypt(data);
    final List decoded = jsonDecode(decrypted);
    notes = decoded.map((e) => Note.fromJson(e)).toList();
  }

  Future<void> saveNotes() async {
    final jsonString =
        jsonEncode(notes.map((e) => e.toJson()).toList());
    final encrypted = EncryptionHelper.encrypt(jsonString);
    await SecureStorageService.saveNotes(encrypted);
  }

  Future<void> addNote(Note note) async {
    notes.insert(0, note);
    await saveNotes();
  }

  Future<void> deleteNote(String id) async {
    notes.removeWhere((n) => n.id == id);
    await saveNotes();
  }
}