import 'package:flutter/material.dart';
// 1. Update this import to point to your Login Screen file
import 'screens/login_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task App',
      debugShowCheckedModeBanner: false,
      
      home: LoginScreen(), 
    );
  }
}