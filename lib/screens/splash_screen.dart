import 'dart:async';

import 'package:coyote_app/screens/main_shell.dart';
import 'package:coyote_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../components/components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1 ), () {
      if (!mounted) return;
      Get.offAll(() => const MainShell());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  CoyoteBackground(
        child: SafeArea(
            child: Center(
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              height: 84,
            ),
          ),
        ),
      ),
    );
  }
}

