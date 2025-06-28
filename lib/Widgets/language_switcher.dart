import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/locale_service.dart';

class LanguageSwitcher extends StatelessWidget {
  final LocaleService localeService;
  
  const LanguageSwitcher({
    super.key,
    required this.localeService,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: (Locale locale) async {
        await localeService.changeLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return localeService.supportedLocales.map((Locale locale) {
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Icon(
                  locale.languageCode == localeService.currentLocale.languageCode
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: locale.languageCode == localeService.currentLocale.languageCode
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  localeService.getLocaleDisplayName(locale),
                  style: GoogleFonts.notoSans(
                    fontWeight: locale.languageCode == localeService.currentLocale.languageCode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
} 