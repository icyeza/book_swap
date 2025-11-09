import 'package:flutter/material.dart';
import 'category_chip.dart';

class CategoryFilterRow extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterRow({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories
            .map(
              (category) => CategoryChip(
                label: category,
                isSelected: selectedCategory == category,
                onTap: () => onCategorySelected(category),
              ),
            )
            .toList(),
      ),
    );
  }
}
