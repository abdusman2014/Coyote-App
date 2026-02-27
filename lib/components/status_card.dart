import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// Tappable status card matching the design: dark navy background, pill-like
/// corners, icon left. Either title + subtitle below (e.g. Bluetooth "Connected")
/// or title + trailing widget on the same row (e.g. Battery with lightning + 89%).
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.title,
    required this.imageUri,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.subtitleColor,
    this.onTap,
    required this.isConnected,
  });

  /// Main label (e.g. "Bluetooth", "Battery").
  final String title;

  /// Optional line below title (e.g. "Connected"). Use for Bluetooth-style cards.
  final String? subtitle;

  /// Optional widget at the end of the row (e.g. lightning + "89%"). Use for Battery-style cards.
  final Widget? trailing;

  final String imageUri;
  final Color? iconColor;
  final Color? subtitleColor;
  final VoidCallback? onTap;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.transparent,
      ),
      // borderRadius: radius,
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: AppColors.background,
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                imageUri,
                color: isConnected
                    ? AppColors.primary
                    : AppColors.gaugeTrackDashed,
              ),
              const SizedBox(width: 10),
              // Icon(
              //   icon,
              //   size: 26,
              //   color: iconColor ?? AppColors.statusCardIconBlue,
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: trailing != null
                    ? Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isConnected
                                  ? AppColors.statusCardTitle
                                  : AppColors.gaugeTrackDashed,
                            ),
                          ),
                          const Spacer(),
                          trailing!,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isConnected
                                  ? AppColors.statusCardTitle
                                  : AppColors.gaugeTrackDashed,
                            ),
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 8,
                                color:
                                    subtitleColor ??
                                    (isConnected
                                        ? AppColors.statusCardSubtitleBlue
                                        : AppColors.gaugeTrackDashed),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
