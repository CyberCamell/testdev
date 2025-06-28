import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  // Initialize locale from saved preferences
  Future<void> initializeLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      _currentLocale = Locale(savedLocale, '');
      notifyListeners();
    }
  }

  // Change locale and save to preferences
  Future<void> changeLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    
    notifyListeners();
  }

  // Get available locales
  List<Locale> get supportedLocales => const [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];

  // Check if current locale is RTL
  bool get isRTL => _currentLocale.languageCode == 'ar';

  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }
} 