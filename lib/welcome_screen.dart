import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motor/motor.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _buttonScale = 1.0;

  void _getStarted() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                'Small tasks,Big Progress',
                style: GoogleFonts.workSans(
                  fontSize: 48,
                  fontWeight: FontWeight.normal,
                  height: 1.1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Focus less on planning…and more on creating.',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              Listener(
                onPointerDown: (_) => setState(() => _buttonScale = 0.96),
                onPointerUp: (_) => setState(() => _buttonScale = 1.0),
                onPointerCancel: (_) => setState(() => _buttonScale = 1.0),
                child: SingleMotionBuilder(
                  motion: CupertinoMotion.snappy(),
                  value: _buttonScale,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _getStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 33, 37, 41),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Text(
                        'Lock in',
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
