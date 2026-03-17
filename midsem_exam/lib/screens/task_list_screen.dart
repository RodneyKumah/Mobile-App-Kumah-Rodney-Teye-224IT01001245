import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [
    Task(
      title: "Assignment 1",
      courseCode: "CS101",
      dueDate: DateTime.now(),
    ),
    Task(
      title: "Project",
      courseCode: "CS202",
      dueDate: DateTime.now(),
    ),
    Task(
      title: "Quiz",
      courseCode: "CS303",
      dueDate: DateTime.now(),
    ),
  ];

  void addTask(String title, String courseCode, DateTime dueDate) {
    setState(() {
      tasks.add(Task(
        title: title,
        courseCode: courseCode,
        dueDate: dueDate,
      ));
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isComplete = !tasks[index].isComplete;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return ListTile(
            title: Text(task.title),
            subtitle: Text(
              "${task.courseCode} | ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
            ),
            trailing: Checkbox(
              value: task.isComplete,
              onChanged: (val) => toggleTask(index),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController titleController =
                  TextEditingController();
              TextEditingController courseController =
                  TextEditingController();

              DateTime? selectedDate;

              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return AlertDialog(
                    title: Text("Add Task"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration:
                              InputDecoration(labelText: "Title"),
                        ),
                        TextField(
                          controller: courseController,
                          decoration:
                              InputDecoration(labelText: "Course Code"),
                        ),
                        SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            selectedDate == null
                                ? "Select Due Date"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (selectedDate != null) {
                            addTask(
                              titleController.text,
                              courseController.text,
                              selectedDate!,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Save"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}