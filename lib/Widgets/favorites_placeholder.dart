import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class FavoritesPlaceholder extends StatelessWidget {
  const FavoritesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4B8EF6), Color(0xFFB3D4FF)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heart icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(seconds: 1),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Your Favorites',
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
                
                const SizedBox(height: 16),
                
                Text(
                  'Tap the favorites button in the bottom navigation to choose between favorite tracks and favorite languages.',
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
                
                const SizedBox(height: 32),
                
                // Animated arrow pointing down
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 10.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 48,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 