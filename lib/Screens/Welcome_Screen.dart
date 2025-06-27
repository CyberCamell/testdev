import 'package:devguide/routes/app_routs.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'Login_Screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A8DFF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            "Welcome", // Matches the screen typo
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'Assets/Images/welcome_illustration.png',
              height: 260,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Welcome To DevGuide",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C2A3A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Your ultimate programming companion. Discover docs, code smarter, and chat your way through development.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Spacer(),
          CustomButton(
            text: "Sign Up",
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.signup);
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text.rich(
                TextSpan(
                  text: "You already have a account? ",
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: Color(0xFF3A8DFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
