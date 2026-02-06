import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/app_colors.dart';

/// Presets screen showing Sit / Walk / Run rows and language selector.
class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  int _sitValue = 8;
  int _walkValue = 10;
  int _runValue = 20;

  int _clampValue(int value) => value.clamp(0, 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Preset',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _LanguageDropdown(),
                  ],
                ),
                const SizedBox(height: 32),
                _PresetTile(
                  imageUri: "assets/images/sit_white.svg",
                  label: 'Sit',
                  value: _sitValue,
                  onIncrement: () =>
                      setState(() => _sitValue = _clampValue(_sitValue + 1)),
                  onDecrement: () =>
                      setState(() => _sitValue = _clampValue(_sitValue - 1)),
                ),
                const SizedBox(height: 16),
                _PresetTile(
                  imageUri: "assets/images/walk_white.svg",
                  label: 'Walk',
                  value: _walkValue,
                  onIncrement: () =>
                      setState(() => _walkValue = _clampValue(_walkValue + 1)),
                  onDecrement: () =>
                      setState(() => _walkValue = _clampValue(_walkValue - 1)),
                ),
                const SizedBox(height: 16),
                _PresetTile(
                  imageUri: "assets/images/run_white.svg",
                  label: 'Run',
                  value: _runValue,
                  onIncrement: () =>
                      setState(() => _runValue = _clampValue(_runValue + 1)),
                  onDecrement: () =>
                      setState(() => _runValue = _clampValue(_runValue - 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatefulWidget {
  @override
  State<_LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<_LanguageDropdown> {
  String _value = 'English';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _value = v);
          },
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.imageUri,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String imageUri;
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.segmentContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(imageUri),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _ArrowButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: onIncrement,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ArrowButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: onDecrement,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
      ),
    );
  }
}
