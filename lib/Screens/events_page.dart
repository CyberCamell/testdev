import 'package:flutter/material.dart';
import '../Widgets/chat_bot_button.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: Stack(
        children: [
          const Center(
            child: Text('Events Page - Coming Soon'),
          ),
          ChatBotButton(
            onTap: () => Navigator.pushNamed(context, '/chatbot'),
          ),
        ],
      ),
    );
  }
}
