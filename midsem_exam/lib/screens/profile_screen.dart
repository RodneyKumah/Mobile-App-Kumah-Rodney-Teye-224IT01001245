
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'task_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Student student = Student(
    name: "John Doe",
    studentId: "123456",
    programme: "Computer Science",
    level: 300,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(student.name[0]),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Name: ${student.name}"),
                    Text("ID: ${student.studentId}"),
                    Text("Programme: ${student.programme}"),
                    Text("Level: ${student.level}"),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Edit Profile"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskListScreen()),
                );
              },
              child: Text("View Tasks"),
            ),
          ],
        ),
      ),
    );
  }
}
