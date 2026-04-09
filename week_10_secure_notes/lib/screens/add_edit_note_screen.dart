import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import 'dart:math';

class AddEditNoteScreen extends StatelessWidget {
  final NotesService service;
  AddEditNoteScreen(this.service);

  final title = TextEditingController();
  final content = TextEditingController();

  void save(BuildContext context) async {
    final note = Note(
      id: Random().nextInt(100000).toString(),
      title: title.text,
      content: content.text,
      date: DateTime.now(),
    );

    await service.addNote(note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: content, decoration: const InputDecoration(labelText: "Content")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => save(context), child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}