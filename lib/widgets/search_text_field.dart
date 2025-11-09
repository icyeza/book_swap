import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchTextField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        fillColor: Colors.white10,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.white60),
      ),
    );
  }
}
