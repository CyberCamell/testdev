import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/responsive_helper.dart';
import '../Widgets/base_screen.dart';
import '../Services/manual_localizations.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    final localizations = ManualLocalizations.of(context);
    
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.copiedToClipboard)),
      );
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
    final localizations = ManualLocalizations.of(context);
    
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
                    localizations.contactUs,
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
                      Text(
                        'Get to know the talented individuals behind DevGuide',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            small: 16,
                            medium: 18,
                            large: 20,
                          ),
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTeamSection(context),
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

  Widget _buildTeamSection(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    
    return Column(
      children: [
        _buildTeamCard(
          context: context,
          name: 'Ibrahem Elgamal',
          role: 'Backend & AI Developer',
          description: 'Backend and AI specialist passionate about creating robust systems and intelligent solutions.',
          skills: ['Python', 'Django', 'REST API'],
          email: 'ibraheme024@gmail.com',
          linkedin: 'https://linkedin.com/in/cybercamel',
          imagePath: 'Assets/Images/ibrahem.jpg',
          isLeader: true,
          roleColor: const Color(0xFF4B8EF6),
          localizations: localizations,
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          context: context,
          name: 'Ahmed Kamal',
          role: 'Mobile Developer',
          description: 'Mobile app developer creating seamless cross-platform experiences with Flutter.',
          skills: ['Flutter', 'Dart', 'Mobile UI'],
          email: 'Ahmed2003kamal1024@gmail.com',
          linkedin: 'https://linkedin.com/in/ahmed-kamal-b1b295233',
          imagePath: 'Assets/Images/ahmed-kamal.jpg',
          roleColor: const Color(0xFF10B981),
          localizations: localizations,
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          context: context,
          name: 'Ahmed Aboshady',
          role: 'Mobile Developer',
          description: 'Flutter specialist focused on building intuitive and performant mobile applications.',
          skills: ['Flutter', 'Dart', 'Mobile UI'],
          email: 'aboshadyahmed74@gmail.com',
          imagePath: 'Assets/Images/ahmed-shady.jpg',
          roleColor: const Color(0xFF10B981),
          localizations: localizations,
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          context: context,
          name: 'Mohamed Elsaaed',
          role: 'Frontend Developer',
          description: 'Frontend developer crafting beautiful and responsive web interfaces with modern technologies.',
          skills: ['HTML', 'CSS', 'JavaScript'],
          email: 'mohamedelsaeed1101@gmail.com',
          linkedin: 'https://linkedin.com/in/mohamed-elsaeed-15a77a2aa/',
          imagePath: 'Assets/Images/mohamed.jpg',
          roleColor: const Color(0xFFF59E0B),
          localizations: localizations,
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          context: context,
          name: 'Shahd Elbana',
          role: 'UI/UX Designer',
          description: 'UI/UX designer creating intuitive and delightful user experiences through thoughtful design.',
          skills: ['Figma', 'UI Design', 'UX Research'],
          email: 'shahdmohamedd350@gmail.com',
          imagePath: 'Assets/Images/shahd.png',
          roleColor: const Color(0xFF8B5CF6),
          localizations: localizations,
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required BuildContext context,
    required String name,
    required String role,
    required String description,
    required List<String> skills,
    required String email,
    String? linkedin,
    required String imagePath,
    bool isLeader = false,
    required Color roleColor,
    required ManualLocalizations localizations,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with avatar and role badge
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLeader ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: roleColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          imagePath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $imagePath - $error');
                            return Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [roleColor.withOpacity(0.7), roleColor],
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (isLeader)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
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
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: roleColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(
                              context,
                              small: 12,
                              medium: 13,
                              large: 14,
                            ),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  small: 14,
                  medium: 15,
                  large: 16,
                ),
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Skills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 11,
                      medium: 12,
                      large: 13,
                    ),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            
            // Contact links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactButton(
                  context: context,
                  icon: Icons.email,
                  label: localizations.email,
                  onTap: () => _launchUrl('mailto:$email'),
                ),
                if (linkedin != null)
                  _buildContactButton(
                    context: context,
                    icon: FontAwesomeIcons.linkedin,
                    label: localizations.linkedin,
                    onTap: () => _launchUrl(linkedin),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  small: 12,
                  medium: 13,
                  large: 14,
                ),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
