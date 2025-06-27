import 'package:devguide/Screens/Signup_Screen.dart';
import 'package:devguide/screens/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'Screens/Login_Screen.dart';
import 'routes/app_routs.dart';
import 'Screens/splash_screen.dart';
import 'Screens/Welcome_Screen.dart';
import 'Screens/tracks_page.dart';
import 'Screens/Forgot-Password_Screen.dart';
import 'Screens/Verify-OTP_Screen.dart';
import 'utils/performance_helper.dart';
import 'Screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    print('Error initializing SharedPreferences: $e');
  }
  
  PerformanceHelper.optimizeApp();
  runApp(const DevGuideApp());
}

class DevGuideApp extends StatelessWidget {
  const DevGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevGuide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: MediaQuery.of(context).padding.copyWith(
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
          ),
          child: child!,
        );
      },
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.tracks: (context) => const HomeScreen(),
        AppRoutes.chatbot: (context) => const ChatbotScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.verifyOtp: (context) => const VerifyOtpScreen(),
      },
    );
  }
}
