
class Task {
  String title;
  String courseCode;
  DateTime dueDate;
  bool isComplete;

  Task({
    required this.title,
    required this.courseCode,
    required this.dueDate,
    this.isComplete = false,
  });
}
