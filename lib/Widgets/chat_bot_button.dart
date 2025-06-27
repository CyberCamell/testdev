import 'package:flutter/material.dart';

class ChatBotButton extends StatelessWidget {
  final VoidCallback onTap;

  const ChatBotButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: const Color(0xFF4B8EF6),
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
} 