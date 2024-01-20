// splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:crudapp/homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay to simulate a splash screen
    Timer(Duration(seconds: 3), () {
      // Navigate to the main screen after the delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue,
        child: Image.asset(
          'images/splashscreen.gif',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
