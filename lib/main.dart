import 'package:devguide/Screens/Signup_Screen.dart';
import 'package:devguide/screens/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'Services/locale_service.dart';
import 'Services/manual_localizations.dart';
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
  
  // Initialize locale service
  final localeService = LocaleService();
  await localeService.initializeLocale();
  
  PerformanceHelper.optimizeApp();
  runApp(DevGuideApp(localeService: localeService));
}

class DevGuideApp extends StatelessWidget {
  final LocaleService localeService;
  
  const DevGuideApp({super.key, required this.localeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: localeService,
      child: Consumer<LocaleService>(
        builder: (context, localeService, child) {
          return MaterialApp(
            locale: localeService.currentLocale,
      title: 'DevGuide',
      debugShowCheckedModeBanner: false,
      
                  // Add localization support
            localizationsDelegates: const [
              ManualLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: Colors.blue,
          onPrimary: Colors.white, // This ensures white text on primary colored buttons
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Button text color
            backgroundColor: Colors.blue, // Button background color
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // TextButton text color
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white, // OutlinedButton text color
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        // Add font support for Arabic
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: MediaQuery.of(context).padding.copyWith(
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
          ),
          child: Directionality(
            textDirection: _getTextDirection(context),
            child: child!,
          ),
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
        },
      ),
    );
  }
  
  TextDirection _getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ar') {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
