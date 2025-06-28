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
  
  // Navigation & Buttons
  String get favorites => _localizedValues[locale.languageCode]?['favorites'] ?? 'Favorites';
  String get explore => _localizedValues[locale.languageCode]?['explore'] ?? 'Explore';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'Retry';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get update => _localizedValues[locale.languageCode]?['update'] ?? 'Update';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get remove => _localizedValues[locale.languageCode]?['remove'] ?? 'Remove';
  String get viewDetails => _localizedValues[locale.languageCode]?['viewDetails'] ?? 'View Details';
  String get learnMore => _localizedValues[locale.languageCode]?['learnMore'] ?? 'Learn More';
  String get logOut => _localizedValues[locale.languageCode]?['logOut'] ?? 'Log out';
  String get logIn => _localizedValues[locale.languageCode]?['logIn'] ?? 'Log in';
  
  // Form & Input
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get confirmPassword => _localizedValues[locale.languageCode]?['confirmPassword'] ?? 'Confirm Password';
  String get newPassword => _localizedValues[locale.languageCode]?['newPassword'] ?? 'New Password';
  String get currentPassword => _localizedValues[locale.languageCode]?['currentPassword'] ?? 'Current Password';
  String get enterEmail => _localizedValues[locale.languageCode]?['enterEmail'] ?? 'Enter your email';
  String get enterPassword => _localizedValues[locale.languageCode]?['enterPassword'] ?? 'Enter your password';
  String get fullName => _localizedValues[locale.languageCode]?['fullName'] ?? 'Full Name';
  String get otpCode => _localizedValues[locale.languageCode]?['otpCode'] ?? 'OTP Code';
  
  // Messages & Status
  String get online => _localizedValues[locale.languageCode]?['online'] ?? 'Online';
  String get readyToHelp => _localizedValues[locale.languageCode]?['readyToHelp'] ?? 'Ready to help';
  String get typing => _localizedValues[locale.languageCode]?['typing'] ?? 'Typing...';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
  String get failed => _localizedValues[locale.languageCode]?['failed'] ?? 'Failed';
  
  // Error Messages
  String get passwordsDoNotMatch => _localizedValues[locale.languageCode]?['passwordsDoNotMatch'] ?? 'Passwords do not match!';
  String get pleaseEnterEmail => _localizedValues[locale.languageCode]?['pleaseEnterEmail'] ?? 'Please enter your email address';
  String get pleaseEnterValidEmail => _localizedValues[locale.languageCode]?['pleaseEnterValidEmail'] ?? 'Please enter a valid email';
  String get pleaseEnterOtp => _localizedValues[locale.languageCode]?['pleaseEnterOtp'] ?? 'Please enter the OTP';
  String get pleaseEnterNewPassword => _localizedValues[locale.languageCode]?['pleaseEnterNewPassword'] ?? 'Please enter a new password';
  String get nameCannotBeEmpty => _localizedValues[locale.languageCode]?['nameCannotBeEmpty'] ?? 'Name cannot be empty';
  String get passwordFieldsCannotBeEmpty => _localizedValues[locale.languageCode]?['passwordFieldsCannotBeEmpty'] ?? 'Password fields cannot be empty';
  String get newPasswordsDoNotMatch => _localizedValues[locale.languageCode]?['newPasswordsDoNotMatch'] ?? 'New passwords do not match';
  
  // Success Messages
  String get signUpSuccessful => _localizedValues[locale.languageCode]?['signUpSuccessful'] ?? 'Sign Up successful!';
  String get loginSuccessful => _localizedValues[locale.languageCode]?['loginSuccessful'] ?? 'Login successful!';
  String get passwordResetEmailSent => _localizedValues[locale.languageCode]?['passwordResetEmailSent'] ?? 'Password reset email has been sent.';
  String get passwordSuccessfullyReset => _localizedValues[locale.languageCode]?['passwordSuccessfullyReset'] ?? 'Password successfully reset.';
  String get profilePictureUpdated => _localizedValues[locale.languageCode]?['profilePictureUpdated'] ?? 'Profile picture updated successfully';
  String get nameUpdated => _localizedValues[locale.languageCode]?['nameUpdated'] ?? 'Name updated successfully';
  String get emailUpdated => _localizedValues[locale.languageCode]?['emailUpdated'] ?? 'Email updated successfully';
  String get passwordUpdated => _localizedValues[locale.languageCode]?['passwordUpdated'] ?? 'Password updated successfully';
  String get removedFromFavorites => _localizedValues[locale.languageCode]?['removedFromFavorites'] ?? 'Removed from favorites';
  String get removedFromSavedTracks => _localizedValues[locale.languageCode]?['removedFromSavedTracks'] ?? 'Removed from saved tracks.';
  String get copiedToClipboard => _localizedValues[locale.languageCode]?['copiedToClipboard'] ?? 'Copied to clipboard';
  
  // Dialog & Modal Titles
  String get updateName => _localizedValues[locale.languageCode]?['updateName'] ?? 'Update Name';
  String get updateEmail => _localizedValues[locale.languageCode]?['updateEmail'] ?? 'Update Email';
  String get changePassword => _localizedValues[locale.languageCode]?['changePassword'] ?? 'Change Password';
  String get privacyPolicy => _localizedValues[locale.languageCode]?['privacyPolicy'] ?? 'I agree with privacy policy';
  
  // General UI
  String get continueToVerifyOtp => _localizedValues[locale.languageCode]?['continueToVerifyOtp'] ?? 'Continue to Verify OTP';
  String get confirmReset => _localizedValues[locale.languageCode]?['confirmReset'] ?? 'Confirm Reset';
  String get swipeToNext => _localizedValues[locale.languageCode]?['swipeToNext'] ?? 'Swipe to next';
  String get askMeAnything => _localizedValues[locale.languageCode]?['askMeAnything'] ?? 'Ask me anything about programming...';
  String get noLinkAvailable => _localizedValues[locale.languageCode]?['noLinkAvailable'] ?? 'No link available';
  String get cannotOpenLink => _localizedValues[locale.languageCode]?['cannotOpenLink'] ?? 'Cannot open link';
  String get failedToOpenLink => _localizedValues[locale.languageCode]?['failedToOpenLink'] ?? 'Failed to open link';
  String get trackNotFound => _localizedValues[locale.languageCode]?['trackNotFound'] ?? 'Track not found.';
  String get comingSoon => _localizedValues[locale.languageCode]?['comingSoon'] ?? 'Coming Soon';
  String get version => _localizedValues[locale.languageCode]?['version'] ?? 'Version';
  String get linkedin => _localizedValues[locale.languageCode]?['linkedin'] ?? 'LinkedIn';
  String get next => _localizedValues[locale.languageCode]?['next'] ?? 'Next';
  String get skip => _localizedValues[locale.languageCode]?['skip'] ?? 'Skip';
  String get passwordTooShort => _localizedValues[locale.languageCode]?['passwordTooShort'] ?? 'Password must be at least 6 characters';
  String get dontHaveAccount => _localizedValues[locale.languageCode]?['dontHaveAccount'] ?? "Don't have an account?";
  String get forgotPassword => _localizedValues[locale.languageCode]?['forgotPassword'] ?? 'Forgot Password?';
  String get getTouched => _localizedValues[locale.languageCode]?['getTouched'] ?? 'Get in Touch';
  String get questionsOrFeedback => _localizedValues[locale.languageCode]?['questionsOrFeedback'] ?? 'Have questions or feedback? We\'d love to hear from you!';
  String get devGuideTeam => _localizedValues[locale.languageCode]?['devGuideTeam'] ?? 'DevGuide Team';
  String get teamDescription => _localizedValues[locale.languageCode]?['teamDescription'] ?? 'We\'re passionate developers committed to helping you learn and grow in your programming journey.';
  String get exploreTracksDescription => _localizedValues[locale.languageCode]?['exploreTracksDescription'] ?? 'Explore different programming tracks and languages to enhance your skills.';
  String get chatbotDescription => _localizedValues[locale.languageCode]?['chatbotDescription'] ?? 'Get instant help from our AI assistant for all your programming questions.';
  String get programmingLanguages => _localizedValues[locale.languageCode]?['programmingLanguages'] ?? 'Programming Languages';
  String get learningTracks => _localizedValues[locale.languageCode]?['learningTracks'] ?? 'Learning Tracks';
  String get activeUsers => _localizedValues[locale.languageCode]?['activeUsers'] ?? 'Active Users';
  String get codeExamples => _localizedValues[locale.languageCode]?['codeExamples'] ?? 'Code Examples';
  String get devGuideByNumbers => _localizedValues[locale.languageCode]?['devGuideByNumbers'] ?? 'DevGuide by the Numbers';
  String get ourMission => _localizedValues[locale.languageCode]?['ourMission'] ?? 'Our Mission';
  String get missionDescription => _localizedValues[locale.languageCode]?['missionDescription'] ?? 'DevGuide aims to make programming education accessible to everyone. We believe that coding should be fun, interactive, and available in your preferred language.';
  String get missionDetails => _localizedValues[locale.languageCode]?['missionDetails'] ?? "Whether you're a beginner taking your first steps in coding or an experienced developer looking to expand your skills, DevGuide is here to support your growth and success.";
  String get thankYouMessage => _localizedValues[locale.languageCode]?['thankYouMessage'] ?? "Thank you for using DevGuide! We're constantly working to improve your learning experience and add new features to help you on your programming journey.";
  String get noDescriptionAvailable => _localizedValues[locale.languageCode]?['noDescriptionAvailable'] ?? 'No description available.';
  String get relatedTerms => _localizedValues[locale.languageCode]?['relatedTerms'] ?? 'Related Terms';

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
      
      // Navigation & Buttons
      'favorites': 'Favorites',
      'explore': 'Explore',
      'retry': 'Retry',
      'confirm': 'Confirm',
      'update': 'Update',
      'save': 'Save',
      'delete': 'Delete',
      'remove': 'Remove',
      'viewDetails': 'View Details',
      'learnMore': 'Learn More',
      'logOut': 'Log out',
      'logIn': 'Log in',
      
      // Form & Input
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'newPassword': 'New Password',
      'currentPassword': 'Current Password',
      'enterEmail': 'Enter your email',
      'enterPassword': 'Enter your password',
      'fullName': 'Full Name',
      'otpCode': 'OTP Code',
      
      // Messages & Status
      'online': 'Online',
      'readyToHelp': 'Ready to help',
      'typing': 'Typing...',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'failed': 'Failed',
      
      // Error Messages
      'passwordsDoNotMatch': 'Passwords do not match!',
      'pleaseEnterEmail': 'Please enter your email address',
      'pleaseEnterValidEmail': 'Please enter a valid email',
      'pleaseEnterOtp': 'Please enter the OTP',
      'pleaseEnterNewPassword': 'Please enter a new password',
      'nameCannotBeEmpty': 'Name cannot be empty',
      'passwordFieldsCannotBeEmpty': 'Password fields cannot be empty',
      'newPasswordsDoNotMatch': 'New passwords do not match',
      
      // Success Messages
      'signUpSuccessful': 'Sign Up successful!',
      'loginSuccessful': 'Login successful!',
      'passwordResetEmailSent': 'Password reset email has been sent.',
      'passwordSuccessfullyReset': 'Password successfully reset.',
      'profilePictureUpdated': 'Profile picture updated successfully',
      'nameUpdated': 'Name updated successfully',
      'emailUpdated': 'Email updated successfully',
      'passwordUpdated': 'Password updated successfully',
      'removedFromFavorites': 'Removed from favorites',
      'removedFromSavedTracks': 'Removed from saved tracks.',
      'copiedToClipboard': 'Copied to clipboard',
      
      // Dialog & Modal Titles
      'updateName': 'Update Name',
      'updateEmail': 'Update Email',
      'changePassword': 'Change Password',
      'privacyPolicy': 'I agree with privacy policy',
      
      // General UI
      'continueToVerifyOtp': 'Continue to Verify OTP',
      'confirmReset': 'Confirm Reset',
      'swipeToNext': 'Swipe to next',
      'askMeAnything': 'Ask me anything about programming...',
      'noLinkAvailable': 'No link available',
      'cannotOpenLink': 'Cannot open link',
      'failedToOpenLink': 'Failed to open link',
      'trackNotFound': 'Track not found.',
      'comingSoon': 'Coming Soon',
      'version': 'Version',
      'linkedin': 'LinkedIn',
      'next': 'Next',
      'skip': 'Skip',
      'passwordTooShort': 'Password must be at least 6 characters',
      'dontHaveAccount': "Don't have an account?",
      'forgotPassword': 'Forgot Password?',
      'getTouched': 'Get in Touch',
      'questionsOrFeedback': 'Have questions or feedback? We\'d love to hear from you!',
      'devGuideTeam': 'DevGuide Team',
      'teamDescription': 'We\'re passionate developers committed to helping you learn and grow in your programming journey.',
      'exploreTracksDescription': 'Explore different programming tracks and languages to enhance your skills.',
      'chatbotDescription': 'Get instant help from our AI assistant for all your programming questions.',
      'programmingLanguages': 'Programming Languages',
      'learningTracks': 'Learning Tracks', 
      'activeUsers': 'Active Users',
      'codeExamples': 'Code Examples',
      'devGuideByNumbers': 'DevGuide by the Numbers',
      'ourMission': 'Our Mission',
      'missionDescription': 'DevGuide aims to make programming education accessible to everyone. We believe that coding should be fun, interactive, and available in your preferred language.',
      'missionDetails': "Whether you're a beginner taking your first steps in coding or an experienced developer looking to expand your skills, DevGuide is here to support your growth and success.",
      'thankYouMessage': "Thank you for using DevGuide! We're constantly working to improve your learning experience and add new features to help you on your programming journey.",
      'noDescriptionAvailable': 'No description available.',
      'relatedTerms': 'Related Terms',
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
      
      // Navigation & Buttons
      'favorites': 'المفضلة',
      'explore': 'استكشف',
      'retry': 'إعادة المحاولة',
      'confirm': 'تأكيد',
      'update': 'تحديث',
      'save': 'حفظ',
      'delete': 'حذف',
      'remove': 'إزالة',
      'viewDetails': 'عرض التفاصيل',
      'learnMore': 'تعلم أكثر',
      'logOut': 'تسجيل الخروج',
      'logIn': 'تسجيل الدخول',
      
      // Form & Input
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'newPassword': 'كلمة المرور الجديدة',
      'currentPassword': 'كلمة المرور الحالية',
      'enterEmail': 'أدخل بريدك الإلكتروني',
      'enterPassword': 'أدخل كلمة المرور',
      'fullName': 'الاسم الكامل',
      'otpCode': 'رمز التحقق',
      
      // Messages & Status
      'online': 'متصل',
      'readyToHelp': 'جاهز للمساعدة',
      'typing': 'يكتب...',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'failed': 'فشل',
      
      // Error Messages
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة!',
      'pleaseEnterEmail': 'يرجى إدخال عنوان بريدك الإلكتروني',
      'pleaseEnterValidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
      'pleaseEnterOtp': 'يرجى إدخال رمز التحقق',
      'pleaseEnterNewPassword': 'يرجى إدخال كلمة مرور جديدة',
      'nameCannotBeEmpty': 'لا يمكن أن يكون الاسم فارغاً',
      'passwordFieldsCannotBeEmpty': 'لا يمكن أن تكون حقول كلمة المرور فارغة',
      'newPasswordsDoNotMatch': 'كلمات المرور الجديدة غير متطابقة',
      
      // Success Messages
      'signUpSuccessful': 'تم إنشاء الحساب بنجاح!',
      'loginSuccessful': 'تم تسجيل الدخول بنجاح!',
      'passwordResetEmailSent': 'تم إرسال رسالة إعادة تعيين كلمة المرور.',
      'passwordSuccessfullyReset': 'تم إعادة تعيين كلمة المرور بنجاح.',
      'profilePictureUpdated': 'تم تحديث صورة الملف الشخصي بنجاح',
      'nameUpdated': 'تم تحديث الاسم بنجاح',
      'emailUpdated': 'تم تحديث البريد الإلكتروني بنجاح',
      'passwordUpdated': 'تم تحديث كلمة المرور بنجاح',
      'removedFromFavorites': 'تم الحذف من المفضلة',
      'removedFromSavedTracks': 'تم الحذف من المسارات المحفوظة.',
      'copiedToClipboard': 'تم النسخ إلى الحافظة',
      
      // Dialog & Modal Titles
      'updateName': 'تحديث الاسم',
      'updateEmail': 'تحديث البريد الإلكتروني',
      'changePassword': 'تغيير كلمة المرور',
      'privacyPolicy': 'أوافق على سياسة الخصوصية',
      
      // General UI
      'continueToVerifyOtp': 'المتابعة للتحقق من الرمز',
      'confirmReset': 'تأكيد الإعادة',
      'swipeToNext': 'اسحب للتالي',
      'askMeAnything': 'اسألني أي شيء عن البرمجة...',
      'noLinkAvailable': 'لا يوجد رابط متاح',
      'cannotOpenLink': 'لا يمكن فتح الرابط',
      'failedToOpenLink': 'فشل في فتح الرابط',
      'trackNotFound': 'المسار غير موجود.',
      'comingSoon': 'قريباً',
      'version': 'الإصدار',
      'linkedin': 'لينكد إن',
      'next': 'التالي',
      'skip': 'تخطي',
      'passwordTooShort': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'dontHaveAccount': "ليس لديك حساب؟",
      'forgotPassword': 'نسيت كلمة المرور؟',
      'getTouched': 'تواصل معنا',
      'questionsOrFeedback': 'هل لديك أسئلة أو تعليقات؟ نحب أن نسمع منك!',
      'devGuideTeam': 'فريق دليل المطور',
      'teamDescription': 'نحن مطورون شغوفون ملتزمون بمساعدتك على التعلم والنمو في رحلة البرمجة.',
      'exploreTracksDescription': 'استكشف مسارات ولغات البرمجة المختلفة لتعزيز مهاراتك.',
      'chatbotDescription': 'احصل على مساعدة فورية من مساعدنا الذكي لجميع أسئلة البرمجة.',
      'programmingLanguages': 'لغات البرمجة',
      'learningTracks': 'مسارات التعلم',
      'activeUsers': 'المستخدمون النشطون', 
      'codeExamples': 'أمثلة الكود',
      'devGuideByNumbers': 'دليل المطور بالأرقام',
      'ourMission': 'مهمتنا',
      'missionDescription': 'يهدف دليل المطور إلى جعل تعليم البرمجة في متناول الجميع. نؤمن أن البرمجة يجب أن تكون ممتعة وتفاعلية ومتاحة بلغتك المفضلة.',
      'missionDetails': 'سواء كنت مبتدئاً تخطو خطواتك الأولى في البرمجة أو مطوراً متمرساً يسعى لتوسيع مهاراته، دليل المطور هنا لدعم نموك ونجاحك.',
      'thankYouMessage': 'شكراً لك لاستخدام دليل المطور! نحن نعمل باستمرار لتحسين تجربة التعلم الخاصة بك وإضافة ميزات جديدة لمساعدتك في رحلة البرمجة.',
      'noDescriptionAvailable': 'لا يوجد وصف متاح.',
      'relatedTerms': 'المصطلحات ذات الصلة',
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