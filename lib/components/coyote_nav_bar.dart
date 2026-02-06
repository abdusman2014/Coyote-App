import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A single item in the nav bar (icon + label).
class CoyoteNavItem {
  const CoyoteNavItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

/// Bottom navigation bar with dark background, icon + label per item,
/// and a pill-shaped selection indicator above the selected icon.
class CoyoteNavBar extends StatelessWidget {
  const CoyoteNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CoyoteNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBarBackground,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              return _NavBarTile(
                item: items[index],
                isSelected: index == currentIndex,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarTile extends StatelessWidget {
  const _NavBarTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final CoyoteNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.navBarSelected : AppColors.textMuted;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (isSelected) _buildPillIndicator(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      item.icon,
                      size: 26,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillIndicator() {
    return Positioned(
      top: 0,
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.navBarSelected,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
