import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task App',
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(), 
    );
  }
}