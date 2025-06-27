import 'package:flutter/material.dart';
import '../Services/track_service.dart';
import '../models/language.dart';
import '../models/term.dart';
import '../utils/responsive_helper.dart';
import '../Widgets/base_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class LanguageDetailPage extends StatefulWidget {
  final int languageId;
  const LanguageDetailPage({super.key, required this.languageId});

  @override
  State<LanguageDetailPage> createState() => _LanguageDetailPageState();
}

class _LanguageDetailPageState extends State<LanguageDetailPage> {
  Language? _language;
  List<Term> _terms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLanguage();
  }

  Future<void> _fetchLanguage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final language = await TrackService.getLanguageById(widget.languageId);
      if (language != null) {
        final terms = await TrackService.getLanguageTerms(language.name);
        setState(() {
          _language = language;
          _terms = terms;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Language not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load language details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4B8EF6), Color(0xFFB3D4FF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchLanguage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF4B8EF6),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _language == null
                          ? const Center(
                              child: Text(
                                'Language not found.',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _language!.icon != null && _language!.icon!.isNotEmpty
                                              ? Image.network(
                                                  _language!.icon!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return SvgPicture.asset(
                                                      'Assets/Images/Layer_1.svg',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : SvgPicture.asset(
                                                  'Assets/Images/Layer_1.svg',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Text(
                                        _language!.name,
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.getFontSize(context, small: 24, medium: 28, large: 32),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        _language!.code.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (_language!.description != null && _language!.description!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _language!.description!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'No description available.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    if (_terms.isNotEmpty) ...[
                                      const SizedBox(height: 32),
                                      Text(
                                        'Related Terms',
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.getFontSize(context, small: 20, medium: 24, large: 28),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _terms.length,
                                        itemBuilder: (context, index) {
                                          final term = _terms[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    term.term,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    term.description,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  if (term.link.isNotEmpty) ...[
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            if (term.link.isNotEmpty) {
                                                              try {
                                                                // Ensure the URL has a proper scheme
                                                                String urlString = term.link;
                                                                if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
                                                                  urlString = 'https://$urlString';
                                                                }
                                                                
                                                                print('Attempting to open URL: $urlString'); // Debug print
                                                                
                                                                final Uri url = Uri.parse(urlString);
                                                                
                                                                if (await canLaunchUrl(url)) {
                                                                  print('URL can be launched, opening...'); // Debug print
                                                                  final bool launched = await launchUrl(
                                                                    url, 
                                                                    mode: LaunchMode.externalApplication,
                                                                    webViewConfiguration: const WebViewConfiguration(
                                                                      enableJavaScript: true,
                                                                      enableDomStorage: true,
                                                                    ),
                                                                  );
                                                                  
                                                                  if (!launched && context.mounted) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      const SnackBar(
                                                                        content: Text('Failed to open link'),
                                                                        backgroundColor: Colors.red,
                                                                      ),
                                                                    );
                                                                  }
                                                                } else {
                                                                  print('URL cannot be launched: $urlString'); // Debug print
                                                                  if (context.mounted) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      SnackBar(
                                                                        content: Text('Cannot open link: $urlString'),
                                                                        backgroundColor: Colors.red,
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              } catch (e) {
                                                                print('Error opening URL: $e'); // Debug print
                                                                if (context.mounted) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text('Error opening link: $e'),
                                                                      backgroundColor: Colors.red,
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                            } else {
                                                              if (context.mounted) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text('No link available'),
                                                                    backgroundColor: Colors.orange,
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          style: TextButton.styleFrom(
                                                            foregroundColor: const Color(0xFF4B8EF6),
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text('Learn More'),
                                                              SizedBox(width: 4),
                                                              Icon(Icons.arrow_forward, size: 16),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
            ],
          ),
        ),
      ),
    );
  }
} 