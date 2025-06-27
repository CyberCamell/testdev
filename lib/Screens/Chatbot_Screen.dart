import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'codeblock.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'bot',
      'text':
          "Hi! I'm DevBot, your AI coding assistant. I'm here to help you with your development questions. What can I help you with today?",
      'isLoading': false,
    },
  ];

  List<Widget> parseMessage(String text) {
    final List<Widget> widgets = [];
    final codeBlockRegex = RegExp(r'```([\s\S]*?)```');
    final inlineCodeRegex = RegExp(r'`([^`]+)`');
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final italicRegex = RegExp(r'\*(.*?)\*');
    int lastIndex = 0;
    for (final match in codeBlockRegex.allMatches(text)) {
      // Add text before code block
      if (match.start > lastIndex) {
        widgets.add(
          SelectableText(
            text.substring(lastIndex, match.start),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }
      widgets.add(
        CodeBlock(code: match.group(1)?.trim() ?? '', isInline: false),
      );
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex);
      remainingText = remainingText.replaceAllMapped(boldRegex, (match) {
        return '**${match.group(1)}**';
      });
      remainingText = remainingText.replaceAllMapped(italicRegex, (match) {
        return '*${match.group(1)}*';
      });
      remainingText = remainingText.replaceAllMapped(inlineCodeRegex, (match) {
        return '`${match.group(1)}`';
      });
      widgets.add(
        SelectableText(
          remainingText,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return widgets;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _messages.add({'role': 'bot', 'text': '', 'isLoading': true});
      _controller.clear();
    });

    const String apiUrl =
        'https://api.devguide.help/api/chatbot/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['response'] ?? 'No response received';

        setState(() {
          _messages.removeLast();
          _messages.add({'role': 'bot', 'text': botReply, 'isLoading': false});
        });
      } else {
        throw Exception('Failed to load bot response: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'role': 'bot',
          'text': 'Sorry, I encountered an error. Please try again.',
          'isLoading': false,
        });
      });
    }
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final isBot = msg['role'] == 'bot';
    final isLoading = msg['isLoading'] == true;

    return Align(
      alignment: isBot ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color:
              isBot ? Colors.white.withOpacity(0.15) : const Color(0xFF4DA6FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [Dot(), Dot(), Dot()],
                  ),
                )
                : isBot
                ? MarkdownBody(
                  data: msg['text'] ?? '',
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white, fontSize: 16),
                    code: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.white,
                      backgroundColor: Color(0xFF222222),
                    ),
                    strong: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    em: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                )
                : SelectableText(
                  msg['text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006BCA), Color(0xFFE0ECF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'DevBot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _messages.length - 1 - index;
                  return buildMessage(_messages[reversedIndex]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask DevBot...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DA6FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          sendMessage(_controller.text.trim());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dot extends StatefulWidget {
  const Dot({super.key});

  @override
  State<Dot> createState() => _DotState();
}

class _DotState extends State<Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
