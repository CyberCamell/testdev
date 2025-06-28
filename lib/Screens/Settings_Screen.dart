import 'package:devguide/Screens/About_us.dart';
import 'package:devguide/Screens/Contact_us.dart';
import 'package:devguide/Screens/Profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Widgets/Custom_button.dart';
import '../Widgets/settings_option_card.dart';
import '../Widgets/user_avatar_widget.dart';
import '../Widgets/arabic_test_widget.dart';
import '../Services/auth_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      Map<String, dynamic>? userData;
      
      if (isLoggedIn) {
        userData = await AuthService.getUserData();
      }
      
      setState(() {
        _isLoggedIn = isLoggedIn;
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _userData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAuthAction() async {
    if (_isLoggedIn) {
      // Handle logout
      try {
        await AuthService.logout();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
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
    } else {
      // Handle login - navigate to login screen
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
    }
  }

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
                // User Profile Section (only show when logged in)
                if (_isLoggedIn && _userData != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        UserAvatarWidget(
                          profilePictureUrl: _userData!['profile_picture'],
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userData!['full_name'] ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userData!['email'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.6),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                
                // Arabic Language Test Widget
                const ArabicTestWidget(),
                
                const SizedBox(height: 8),
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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : CustomButton(
                          text: _isLoggedIn ? 'Log out' : 'Log in',
                          onPressed: _handleAuthAction,
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
