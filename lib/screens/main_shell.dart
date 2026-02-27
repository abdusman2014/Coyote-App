import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../components/components.dart';
import 'control_screen.dart';
import 'pair_screen.dart';
import 'presets_screen.dart';
import 'about_screen.dart';

/// Shell that shows the bottom nav bar and the selected page.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _navItems = [
    CoyoteNavItem(label: 'Home', icon: Icons.home_outlined),
    CoyoteNavItem(label: 'Pair', icon: Icons.bluetooth),
    CoyoteNavItem(label: 'Presets', icon: Icons.settings_outlined),
    CoyoteNavItem(label: 'About', icon: Icons.info_outline),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ControlScreen(),
      const PairScreen(),
      const PresetsScreen(),
      const AboutScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navBarBackground,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          CoyoteNavBar(
            items: _navItems,
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
