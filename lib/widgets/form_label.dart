import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const FormLabel({super.key, required this.text, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
