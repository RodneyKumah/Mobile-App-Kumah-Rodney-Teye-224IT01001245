import 'package:flutter/material.dart';

class FacultyScreen extends StatelessWidget {
  const FacultyScreen({super.key});

  final List<String> professors = const [
    'Prof. Kwame Mensah',
    'Prof. Ama Serwaa',
    'Prof. Kofi Boateng',
    'Prof. Nana Adjei',
    'Prof. Akosua Owusu',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Directory'),
      ),
      body: ListView.builder(
        itemCount: professors.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(professors[index]),
              subtitle: const Text('Computer Science Department'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to faculty detail later
              },
            ),
          );
        },
      ),
    );
  }
}
