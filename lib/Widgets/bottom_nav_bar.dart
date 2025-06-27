import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4B8EF6),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'Assets/Images/home.png',
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
              'Assets/Images/home_filled.png',
              width: 24,
              height: 24,
              color: const Color(0xFF4B8EF6),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'Assets/Images/heart.png',
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
              'Assets/Images/heart_filled.png',
              width: 24,
              height: 24,
              color: const Color(0xFF4B8EF6),
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.smart_toy_rounded,
              size: 24,
            ),
            activeIcon: const Icon(
              Icons.smart_toy_rounded,
              size: 24,
            ),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'Assets/Images/settings.png',
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
              'Assets/Images/settings_filled.png',
              width: 24,
              height: 24,
              color: const Color(0xFF4B8EF6),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
} 