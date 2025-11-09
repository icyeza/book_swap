import 'package:flutter/material.dart';

class LinkText extends StatelessWidget {
  final String leadText;
  final String linkText;
  final VoidCallback onPressed;
  static const Color _accent = Color(0xFFF1C64A);

  const LinkText({
    super.key,
    required this.leadText,
    required this.linkText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(leadText, style: const TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: onPressed,
          child: Text(
            linkText,
            style: const TextStyle(color: _accent, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
