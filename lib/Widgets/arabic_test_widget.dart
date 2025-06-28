import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Services/locale_service.dart';

class ArabicTestWidget extends StatelessWidget {
  const ArabicTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleService>(
      builder: (context, localeService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language Test / اختبار اللغة',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Current Language: ${localeService.getLocaleDisplayName(localeService.currentLocale)}',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Text Direction: ${localeService.isRTL ? "RTL" : "LTR"}',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localeService.currentLocale.languageCode == 'ar'
                    ? 'مرحباً! هذا نص تجريبي باللغة العربية لاختبار دعم اللغة العربية في التطبيق.'
                    : 'Hello! This is a test text in English to verify language support.',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
                textDirection: localeService.isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final newLocale = localeService.currentLocale.languageCode == 'ar'
                      ? const Locale('en', '')
                      : const Locale('ar', '');
                  await localeService.changeLocale(newLocale);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  localeService.currentLocale.languageCode == 'ar'
                      ? 'التبديل إلى الإنجليزية'
                      : 'Switch to Arabic',
                  style: GoogleFonts.notoSans(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 