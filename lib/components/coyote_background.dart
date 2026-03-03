import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// Full-screen background using gradient + bg.svg behind content.
class CoyoteBackground extends StatelessWidget {
  const CoyoteBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), AppColors.background],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            'assets/images/bg.svg',
            fit: BoxFit.cover,
          ),
          child,
        ],
      ),
    );
  }
}

