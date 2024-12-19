import 'package:flutter/material.dart';
import 'package:wise/screens/admin/AdminMain.dart';
import 'dart:async';
import 'package:wise/screens/user/login/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate to LoginPage after the splash screen
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b0f12),
      body: Center(
        child: Image.asset(
          'assets/images/logo/logoWithPadding.png',
          width: 350,
          height: 650,
        ),
      ),
    );
  }
}
