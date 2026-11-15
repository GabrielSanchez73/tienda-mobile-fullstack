import 'package:flutter/material.dart';

import '../models/category.dart';

/// Ícono y color de cada categoría (según su nombre en la base de datos).
class CategoryStyle {
  const CategoryStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  static const List<Color> _fallbackColors = [
    Color(0xFF00897B),
    Color(0xFF6D4C41),
    Color(0xFF5E35B1),
  ];

  static CategoryStyle of(String name, int index) {
    final n = name.toLowerCase();
    if (n.contains('electr')) {
      return const CategoryStyle(
          Icons.devices_other_rounded, Color(0xFF2563EB));
    }
    if (n.contains('ropa')) {
      return const CategoryStyle(Icons.checkroom_rounded, Color(0xFFDB2777));
    }
    if (n.contains('hogar')) {
      return const CategoryStyle(Icons.chair_rounded, Color(0xFFEA580C));
    }
    if (n.contains('deport')) {
      return const CategoryStyle(
          Icons.sports_soccer_rounded, Color(0xFF16A34A));
    }
    return CategoryStyle(
      Icons.category_rounded,
      _fallbackColors[index % _fallbackColors.length],
    );
  }
}

/// Tarjeta de categoría del home.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.index = 0,
  });

  final Category category;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = CategoryStyle.of(category.name, index);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(style.icon, color: style.color),
              ),
              const Spacer(),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                category.description ?? 'Ver productos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
