import 'package:coyote_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    super.key,
    required this.imageUri,
    required this.isSelected,
    required this.label,
    required this.onPress,
  });

  final String label;
  final String imageUri;

  final bool isSelected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          height: 50,
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(imageUri),
        
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? AppColors.gaugeTrackMin
                      : AppColors.segmentUnselected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
