import 'package:devguide/Screens/About_us.dart';
import 'package:devguide/Screens/Contact_us.dart';
import 'package:devguide/Screens/Profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Widgets/Custom_button.dart';
import '../Widgets/settings_option_card.dart';
import '../Services/auth_service.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Increase AppBar height
        child: AppBar(
          backgroundColor: const Color(0xFF4DA6FF),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 12), // Push icon down
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 12), // Push text down
            child: Text(
              'Settings',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
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
                const SizedBox(height: 15),
                SettingsOptionCard(
                  icon: Icons.account_circle_sharp,
                  text: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  },
                  color: Colors.black,
                  size: 20,
                ),
                SettingsOptionCard(
                  icon: FontAwesomeIcons.phone,
                  text: 'Contact us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactUs()),
                    );
                  },
                  color: Colors.black,
                  size: 20,
                ),
                SettingsOptionCard(
                  icon: FontAwesomeIcons.exclamationCircle,
                  text: 'About us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUs()),
                    );
                  },
                  color: Colors.black,
                  size: 20,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: CustomButton(
                    text: 'Log out',
                    onPressed: () async {
                      try {
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', // Make sure this route exists in your app
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error logging out. Please try again.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
