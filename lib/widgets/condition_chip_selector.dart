import 'package:flutter/material.dart';

class ConditionChipSelector extends StatelessWidget {
  final List<String> conditions;
  final String selectedCondition;
  final ValueChanged<String> onConditionSelected;
  static const Color _accent = Color(0xFFF1C64A);

  const ConditionChipSelector({
    super.key,
    required this.conditions,
    required this.selectedCondition,
    required this.onConditionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: conditions.map((condition) {
        final isSelected = selectedCondition == condition;
        return GestureDetector(
          onTap: () => onConditionSelected(condition),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? _accent : Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              condition,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
