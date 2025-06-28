import 'package:flutter/material.dart';
import '../Services/manual_localizations.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Privacy Policy',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DevGuide ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Information We Collect\n'
              '• Account information (name, email)\n'
              '• Usage data and preferences\n'
              '• Device information\n\n'
              '2. How We Use Your Information\n'
              '• Provide and improve our services\n'
              '• Personalize your experience\n'
              '• Send important updates\n\n'
              '3. Data Security\n'
              'We implement appropriate security measures to protect your personal information.\n\n'
              '4. Contact Us\n'
              'If you have questions about this Privacy Policy, please contact us at contact@devguide.com',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (bool? value) {
                // Handle checkbox state change if needed
              },
            ),
            Expanded(
              child: Text(localizations.privacyPolicy),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B8EF6),
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.confirm, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
