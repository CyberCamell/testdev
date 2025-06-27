import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/responsive_helper.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          ResponsiveHelper.getSpacing(
            context,
            small: 80,
            medium: 100,
            large: 120,
          ),
        ),
        child: AppBar(
          backgroundColor: const Color(0xFF4DA6FF),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.getSpacing(
                context,
                small: 12,
                medium: 16,
                large: 20,
              ),
            ),
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: ResponsiveHelper.getFontSize(
                  context,
                  small: 20,
                  medium: 24,
                  large: 28,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.getSpacing(
                context,
                small: 12,
                medium: 16,
                large: 20,
              ),
            ),
            child: Text(
              'Contact Us',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  small: 24,
                  medium: 28,
                  large: 32,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DA6FF), Colors.white],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: ResponsiveHelper.getSpacing(
                context,
                small: 60,
                medium: 80,
                large: 100,
              ),
            ),
            Text(
              'If you have any inquiries get in \n touch with us',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  small: 16,
                  medium: 18,
                  large: 20,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: ResponsiveHelper.getSpacing(
                context,
                small: 8,
                medium: 10,
                large: 12,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(
                  context,
                  small: 20,
                  medium: 25,
                  large: 30,
                ),
                vertical: ResponsiveHelper.getSpacing(
                  context,
                  small: 4,
                  medium: 5,
                  large: 6,
                ),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    size: ResponsiveHelper.getFontSize(
                      context,
                      small: 20,
                      medium: 22,
                      large: 25,
                    ),
                    color: const Color(0xff2384F5),
                  ),
                  title: Text(
                    '0502727486',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        small: 14,
                        medium: 16,
                        large: 18,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: const Color(0xff2384F5),
                      size: ResponsiveHelper.getFontSize(
                        context,
                        small: 20,
                        medium: 22,
                        large: 25,
                      ),
                    ),
                    onPressed:
                        () => _copyToClipboard(context, '0502727486'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(
                  context,
                  small: 20,
                  medium: 25,
                  large: 30,
                ),
                vertical: ResponsiveHelper.getSpacing(
                  context,
                  small: 4,
                  medium: 5,
                  large: 6,
                ),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.email,
                    size: ResponsiveHelper.getFontSize(
                      context,
                      small: 20,
                      medium: 22,
                      large: 25,
                    ),
                    color: const Color(0xff2384F5),
                  ),
                  title: Text(
                    'Devg@yahoo.com',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        small: 14,
                        medium: 16,
                        large: 18,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: const Color(0xff2384F5),
                      size: ResponsiveHelper.getFontSize(
                        context,
                        small: 20,
                        medium: 22,
                        large: 25,
                      ),
                    ),
                    onPressed:
                        () => _copyToClipboard(context, 'Devg@yahoo.com'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(
                  context,
                  small: 16,
                  medium: 20,
                  large: 24,
                ),
                vertical: ResponsiveHelper.getSpacing(
                  context,
                  small: 8,
                  medium: 10,
                  large: 12,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: ResponsiveHelper.getSpacing(
                  context,
                  small: 60,
                  medium: 70,
                  large: 80,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getSpacing(
                      context,
                      small: 8,
                      medium: 10,
                      large: 12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Social media',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            small: 10,
                            medium: 12,
                            large: 14,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(
                          context,
                          small: 6,
                          medium: 8,
                          large: 10,
                        ),
                      ),
                      InkWell(
                        onTap:
                            () => _launchUrl('mailto:info@metmans.edu.eg'),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              color: const Color(0xff2384F5),
                              size: ResponsiveHelper.getFontSize(
                                context,
                                small: 16,
                                medium: 18,
                                large: 20,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.getSpacing(
                                context,
                                small: 4,
                                medium: 5,
                                large: 6,
                              ),
                            ),
                            Text(
                              'info@metmans.edu.eg',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  small: 12,
                                  medium: 14,
                                  large: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
