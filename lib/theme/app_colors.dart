import 'package:flutter/material.dart';

/// Coyote app color palette matching the dark blue UI.
class AppColors {
  AppColors._();

  /// Bright blue used for selected segments, primary button, and active states.
  static const Color primary = Color(0xFF1974FE);

  /// Dark blue / indigo background (screen).
  static const Color background = Color(0xFF1A2332);

  /// Dark gray for unselected segments and status cards.
  static const Color surface = Color(0xFF2A3544);

  /// Segmented control outer container (dark slate).e
  static const Color segmentContainer = Color(0xFF161F2E);

  /// Segmented control selected pill (vibrant blue).
  // static const Color segmentPill = Color(0xFF1974FE);

  /// Segmented control unselected icon/text.
  static const Color segmentUnselected = Color(0xFF7A7F8C);

  /// Light gray for unselected text/icons and nav bar inactive.
  static const Color textMuted = Color(0xFF8B949E);

  /// White for selected text and primary content.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Green accent (e.g. battery +89%).
  static const Color success = Color(0xFF4CAF50);

  /// Light blue for gauge value and secondary highlights.
  static const Color accent = Color(0xFF7EB8F0);

  /// Light yellow/beige for gauge track (minimum side).
  static const Color gaugeTrackMin = Color(0xFFE8DCC8);

  /// Dashed track stroke color.
  static const Color gaugeTrackDashed = Color(0xFF5A6575);

  /// Bottom nav bar background (dark gray / navy).
  static const Color navBarBackground = Color(0xFF21262D);

  /// Nav bar selected item (bright blue).
  static const Color navBarSelected = Color(0xFF3A7CFF);

  /// Status card background (dark navy/charcoal).
  static const Color statusCardBackground = Color(0xFF1A1E27);

  /// Status card title (light gray/white).
  static const Color statusCardTitle = Color(0xFFE0E0E0);

  /// Status card icon and accent (medium blue).
  static const Color statusCardIconBlue = Color(0xFF4285F4);

  /// Status card subtitle (e.g. "Connected") medium blue.
  static const Color statusCardSubtitleBlue = Color(0xFF66B2FF);
}
