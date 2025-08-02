import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';

class SelectionRow extends StatelessWidget {
  const SelectionRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.background,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
