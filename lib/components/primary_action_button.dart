import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-width primary action button with leading icon (e.g. "Turn Off").
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isOn,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 22,
          color: isOn ? AppColors.textPrimary : AppColors.primary,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: isOn
              ? AppColors.primary
              : AppColors.segmentContainer,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
