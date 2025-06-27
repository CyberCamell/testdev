// ignore: unused_import
import 'dart:ffi';

import 'package:flutter/material.dart';

class SettingsOptionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const SettingsOptionCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    required  this.color,
    required this.size,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, size: size, color: color),
          title: Text(text),
          trailing: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
