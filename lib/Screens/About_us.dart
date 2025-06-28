import 'package:flutter/material.dart';
import '../Services/manual_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/responsive_helper.dart';
import '../Widgets/base_screen.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      extendBodyBehindAppBar: true,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4B8EF6), Color(0xFFB3D4FF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'About DevGuide',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        small: 24,
                        medium: 28,
                        large: 32,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeroSection(context),
                      const SizedBox(height: 32),
                      _buildFeaturesSection(context),
                      const SizedBox(height: 32),
                      _buildStatsSection(context),
                      const SizedBox(height: 32),
                      _buildMissionSection(context),
                      const SizedBox(height: 32),
                      _buildVersionInfo(context),
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

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              FontAwesomeIcons.code,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'DevGuide',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                small: 28,
                medium: 32,
                large: 36,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your comprehensive platform for learning programming languages, development tracks, and connecting with the developer community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                small: 16,
                medium: 18,
                large: 20,
              ),
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.school,
        'title': 'Learning Tracks',
        'description': 'Structured learning paths for different programming languages and technologies',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': FontAwesomeIcons.code,
        'title': 'Programming Languages',
        'description': 'Comprehensive guides and references for popular programming languages',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.smart_toy,
        'title': 'AI Chatbot',
        'description': 'Get instant help and answers to your programming questions',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.group,
        'title': 'Community',
        'description': 'Connect with fellow developers and share knowledge',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(
              context,
              small: 24,
              medium: 26,
              large: 28,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureCard(
          context: context,
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
          color: feature['color'] as Color,
        )).toList(),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 18,
                      medium: 20,
                      large: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 14,
                      medium: 15,
                      large: 16,
                    ),
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    final stats = [
      {'label': localizations.programmingLanguages, 'value': '15+'},
      {'label': localizations.learningTracks, 'value': '10+'},
      {'label': localizations.activeUsers, 'value': '1K+'},
      {'label': localizations.codeExamples, 'value': '500+'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            localizations.devGuideByNumbers,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                small: 20,
                medium: 22,
                large: 24,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['value']!,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          small: 24,
                          medium: 28,
                          large: 32,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          small: 12,
                          medium: 13,
                          large: 14,
                        ),
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B8EF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                localizations.ourMission,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(
                    context,
                    small: 22,
                    medium: 24,
                    large: 26,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.missionDescription,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                small: 16,
                medium: 17,
                large: 18,
              ),
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.missionDetails,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                small: 16,
                medium: 17,
                large: 18,
              ),
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.version,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(
                    context,
                    small: 16,
                    medium: 17,
                    large: 18,
                  ),
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                ),
                child: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 14,
                      medium: 15,
                      large: 16,
                    ),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Colors.white24,
            height: 1,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.thankYouMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                small: 14,
                medium: 15,
                large: 16,
              ),
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
