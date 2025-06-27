import 'package:flutter/material.dart';

class CodeBlock extends StatelessWidget {
  final String code;
  final bool isInline;

  const CodeBlock({
    super.key,
    required this.code,
    this.isInline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isInline ? 4 : 8),
      margin: EdgeInsets.symmetric(vertical: isInline ? 2 : 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isInline ? 4 : 8),
      ),
      child: SelectableText(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.white,
          height: 1.5,
        ),
      ),
    );
  }
}
