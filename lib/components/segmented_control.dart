import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// A single segment option with icon and label (icon left, label right).
class SegmentOption<T> {
  const SegmentOption({
    required this.label,
    required this.imageUri,
    this.value,
  });

  final String label;
  final String imageUri;
  final T? value;
}

/// Segmented control: dark container with a sliding blue pill behind the
/// selected option. Each option shows icon (left) + label (right).
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<SegmentOption<T>> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = options.length;
        final segmentWidth = count > 0 ? width / count : 0.0;
        const margin = 6.0;
        const verticalMargin = 6.0;

        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.segmentContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding blue pill
              if (segmentWidth > 0 && selectedIndex < count)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  left: selectedIndex * segmentWidth + margin,
                  top: verticalMargin,
                  bottom: verticalMargin,
                  width: segmentWidth - margin * 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              // Segment options (icon + label horizontal)
              Row(
                children: List.generate(options.length, (index) {
                  final option = options[index];
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () => onChanged(index),

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(option.imageUri),
                                // Icon(
                                //   option.icon,
                                //   size: 20,
                                //   color: isSelected
                                //       ? AppColors.textPrimary
                                //       : AppColors.segmentUnselected,
                                // ),
                                const SizedBox(width: 8),
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : AppColors.segmentUnselected,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
