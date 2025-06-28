import 'package:flutter/material.dart';
import '../Services/manual_localizations.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = ManualLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.events),
        backgroundColor: const Color(0xFF4B8EF6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('${localizations.events} - ${localizations.comingSoon}'),
      ),
    );
  }
}
