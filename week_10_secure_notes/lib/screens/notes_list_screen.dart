import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/notes_service.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final service = NotesService();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    await service.loadNotes();
    setState(() => loading = false);
  }

  void addNote() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddEditNoteScreen(service)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Notes"),
        actions: [
          Consumer<ThemeService>(
            builder: (context, theme, _) {
              return Switch(
                value: theme.isDark,
                onChanged: (_) => theme.toggleTheme(),
              );
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: service.notes.length,
              itemBuilder: (_, i) {
                final note = service.notes[i];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  onLongPress: () async {
                    await service.deleteNote(note.id);
                    setState(() {});
                  },
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}