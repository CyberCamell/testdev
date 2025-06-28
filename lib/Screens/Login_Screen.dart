import 'package:devguide/Widgets/Show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/auth_service.dart';
import '../Services/http_client.dart';
import '../routes/app_routs.dart';
import '../Services/manual_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${AuthService.baseUrl}/api/auth/login/');

    try {
      final client = CustomHttpClient.getClient();
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'remember_me': _rememberMe,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['tokens']['access'];
        final refreshToken = responseData['tokens']['refresh'];
        final userData = responseData['user'];

        await AuthService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userData: userData,
          rememberMe: _rememberMe,
        );

        final localizations = ManualLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? localizations.loginSuccessful),
          ),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/tracks');
        }
      } else {
        final localizations = ManualLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.login} ${localizations.failed}: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        final localizations = ManualLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.error}: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    await AuthService.setGuestMode();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/tracks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4B8EF6), Color(0xFFB3D4FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: MediaQuery.of(context).size.height * 0.1,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                children: [
                  Text(
                    localizations.login,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: localizations.enterEmail,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.pleaseEnterEmail;
                            }
                            if (!value.contains('@')) {
                              return localizations.pleaseEnterValidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          localizations.password,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: localizations.enterPassword,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.pleaseEnterNewPassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgotPassword');
                            },
                            child: Text(
                              localizations.forgotPassword,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4B8EF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B8EF6)),
                                  )
                                : Text(
                                    localizations.login,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                                                         Text(
                               "${localizations.dontHaveAccount} ",
                               style: TextStyle(
                                 color: Colors.white.withOpacity(0.8),
                                 fontSize: 14,
                               ),
                             ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                localizations.signup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const PrivacyPolicyDialog(),
                              );
                            },
                            child: Text(
                              localizations.privacyPolicy,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
