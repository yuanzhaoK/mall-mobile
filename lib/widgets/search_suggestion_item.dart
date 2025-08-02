import 'package:flutter/material.dart';

/// 搜索建议项组件
class SearchSuggestionItem extends StatelessWidget {
  const SearchSuggestionItem({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.onDelete,
    this.isHot = false,
  }) : super(key: key);
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isHot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
      title: Row(
        children: [
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          if (isHot) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'HOT',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: onDelete != null
          ? IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
