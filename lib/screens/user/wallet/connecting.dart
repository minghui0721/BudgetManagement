import 'package:flutter/material.dart';
import 'package:wise/screens/user/wallet/successfulConnect.dart';

class ConnectingPage extends StatefulWidget {
  final String bankLogoPath; // This should be the URL of the bank logo
  final String bankName;

  ConnectingPage({required this.bankLogoPath, required this.bankName});

  @override
  _ConnectingPageState createState() => _ConnectingPageState();
}

class _ConnectingPageState extends State<ConnectingPage> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds before navigating to the SuccessPage
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SuccessPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo/logoWithPadding.png',
                  height: 50,
                ),
                SizedBox(width: 20),
                LoadingAnimation(), // The animation for connecting
                SizedBox(width: 20),
                Image.network(
                  widget.bankLogoPath, // Use Image.network for URL
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image,
                        color: Colors.white, size: 50);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator(
                      color: Colors.white,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Connecting to ${widget.bankName}...",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingAnimation extends StatefulWidget {
  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller!,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}
