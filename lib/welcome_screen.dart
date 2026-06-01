import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // This will be connected in main.dart
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 114, 224, 239),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Planning',
                    style: GoogleFonts.workSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      
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
