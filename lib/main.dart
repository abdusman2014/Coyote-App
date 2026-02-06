import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const CoyoteApp());
}

class CoyoteApp extends StatelessWidget {
  const CoyoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coyote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const MainShell(),
    );
  }
}
