import 'package:flutter/material.dart';

class ManualLocalizations {
  final Locale locale;

  ManualLocalizations(this.locale);

  static ManualLocalizations of(BuildContext context) {
    return Localizations.of<ManualLocalizations>(context, ManualLocalizations) ??
        ManualLocalizations(const Locale('en', ''));
  }

  static const LocalizationsDelegate<ManualLocalizations> delegate =
      _ManualLocalizationsDelegate();

  // Getters for localized strings
  String get appTitle => _localizedValues[locale.languageCode]?['appTitle'] ?? 'DevGuide';
  String get welcome => _localizedValues[locale.languageCode]?['welcome'] ?? 'Welcome';
  String get welcomeMessage => _localizedValues[locale.languageCode]?['welcomeMessage'] ?? 'Welcome To DevGuide';
  String get welcomeDescription => _localizedValues[locale.languageCode]?['welcomeDescription'] ?? 'Your ultimate programming companion. Discover docs, code smarter, and chat your way through development.';
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get signup => _localizedValues[locale.languageCode]?['signup'] ?? 'Sign Up';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get tracks => _localizedValues[locale.languageCode]?['tracks'] ?? 'Tracks';
  String get events => _localizedValues[locale.languageCode]?['events'] ?? 'Events';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get editProfile => _localizedValues[locale.languageCode]?['editProfile'] ?? 'Edit Profile';
  String get aboutUs => _localizedValues[locale.languageCode]?['aboutUs'] ?? 'About Us';
  String get contactUs => _localizedValues[locale.languageCode]?['contactUs'] ?? 'Contact Us';
  String get haveAccount => _localizedValues[locale.languageCode]?['haveAccount'] ?? 'You already have an account?';
  String get chatbot => _localizedValues[locale.languageCode]?['chatbot'] ?? 'DevBot';
  String get chatbotWelcome => _localizedValues[locale.languageCode]?['chatbotWelcome'] ?? "Hi! I'm DevBot, your AI coding assistant. I'm here to help you with your development questions. What can I help you with today?";
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get chooseLanguage => _localizedValues[locale.languageCode]?['chooseLanguage'] ?? 'Choose Language';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';

  // Localized values map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'DevGuide',
      'welcome': 'Welcome',
      'welcomeMessage': 'Welcome To DevGuide',
      'welcomeDescription': 'Your ultimate programming companion. Discover docs, code smarter, and chat your way through development.',
      'login': 'Login',
      'signup': 'Sign Up',
      'home': 'Home',
      'tracks': 'Tracks',
      'events': 'Events',
      'settings': 'Settings',
      'profile': 'Profile',
      'editProfile': 'Edit Profile',
      'aboutUs': 'About Us',
      'contactUs': 'Contact Us',
      'haveAccount': 'You already have an account?',
      'chatbot': 'DevBot',
      'chatbotWelcome': "Hi! I'm DevBot, your AI coding assistant. I'm here to help you with your development questions. What can I help you with today?",
      'language': 'Language',
      'chooseLanguage': 'Choose Language',
      'cancel': 'Cancel',
    },
    'ar': {
      'appTitle': 'دليل المطور',
      'welcome': 'مرحباً',
      'welcomeMessage': 'مرحباً بك في دليل المطور',
      'welcomeDescription': 'رفيقك البرمجي المثالي. اكتشف الوثائق، ابرمج بذكاء، وتحدث في طريقك خلال التطوير.',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'home': 'الرئيسية',
      'tracks': 'المسارات',
      'events': 'الأحداث',
      'settings': 'الإعدادات',
      'profile': 'الملف الشخصي',
      'editProfile': 'تعديل الملف الشخصي',
      'aboutUs': 'من نحن',
      'contactUs': 'اتصل بنا',
      'haveAccount': 'هل لديك حساب بالفعل؟',
      'chatbot': 'مساعد ذكي',
      'chatbotWelcome': 'مرحباً! أنا مساعدك الذكي للبرمجة. أنا هنا لمساعدتك في أسئلة التطوير. كيف يمكنني مساعدتك اليوم؟',
      'language': 'اللغة',
      'chooseLanguage': 'اختر اللغة',
      'cancel': 'إلغاء',
    },
  };
}

class _ManualLocalizationsDelegate extends LocalizationsDelegate<ManualLocalizations> {
  const _ManualLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<ManualLocalizations> load(Locale locale) async {
    return ManualLocalizations(locale);
  }

  @override
  bool shouldReload(_ManualLocalizationsDelegate old) => false;
} 