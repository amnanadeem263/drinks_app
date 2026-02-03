import 'dart:math';
import 'package:flutter/material.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animationBegin;
  late Animation<Alignment> _animationEnd;

  void _goToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen()),
    );
  }

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 6));

    // Moving Gradient Animation
    _animationBegin =
        Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.bottomRight)
            .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

    _animationEnd =
        Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.topLeft)
            .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

    // Repeat Forever
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // ✅ Animated Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.shade100],
                    begin: _animationBegin.value,
                    end: _animationEnd.value,
                  ),
                ),
              ),

              // ✅ Bubble Animation Layer
              CustomPaint(
                painter: BubblePainter(_controller.value),
                child: Container(),
              ),

              // ✅ Main Splash Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo - Increased Size
                    Image.asset(
                      'assets/splashscreen.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: 20),

                    // App Name
                    Text(
                      "Drinkly",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: 40),

                    CircularProgressIndicator(color: Colors.white),

                    SizedBox(height: 40),

                    // Continue Button
                    ElevatedButton(
                      onPressed: _goToNextScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ Bubble Painter Class
//////////////////////////////////////////////////////////////

class BubblePainter extends CustomPainter {
  final double animationValue;
  BubblePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..style = PaintingStyle.fill;

    final random = Random(1); // fixed seed for smooth movement

    for (int i = 0; i < 18; i++) {
      double radius = random.nextDouble() * 18 + 8;

      // Bubble X position
      double x = random.nextDouble() * size.width;

      // ✅ Slow upward movement
      double speed = (i + 1) * 30;

      double y = size.height -
          ((animationValue * speed) + (i * 150)) % size.height;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
