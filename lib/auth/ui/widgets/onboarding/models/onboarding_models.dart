import 'package:flutter/material.dart';

/// Layout types for option tiles
enum OptionTileLayout {
  icon,       // Icon on left (goals, level)
  emoji,      // Emoji on left (language, assessment)
  timeBadge,  // Time display on left (daily goal)
  simple,     // No icon (simple text)
}

/// Character position in the screen
enum CharacterPosition {
  top,        // Character ở trên, content ở dưới
  bottom,     // Content ở trên, character ở dưới
  left,       // Character bên trái, speech bên phải (horizontal)
  right,      // Speech bên trái, character bên phải
}

/// Button states for onboarding button
enum OnboardingButtonState {
  enabled,    // White background, can be pressed
  selected,   // Green background (after selection)
  disabled,   // Gray background, cannot press
}

/// Configuration for a single option in the onboarding
class OptionConfig {
  final dynamic value;         // Actual value to store
  final String title;
  final String? subtitle;
  
  // Layout-specific properties
  final IconData? icon;
  final String? emoji;
  final String? timeBadge;
  final Color? badgeColor;
  final String? badgeText;
  final double? progressValue;
  
  const OptionConfig({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    this.timeBadge,
    this.badgeColor,
    this.badgeText,
    this.progressValue,
  });
}

/// Configuration for character display
class CharacterConfig {
  final String? imageUrl;
  final String? speechText;
  final CharacterPosition position;
  final bool showSkip;
  final VoidCallback? onSkip;
  
  const CharacterConfig({
    this.imageUrl,
    this.speechText,
    this.position = CharacterPosition.top,
    this.showSkip = false,
    this.onSkip,
  });
}

/// Configuration for a complete onboarding step
class OnboardingStepConfig {
  final String id;
  final String? title;
  final CharacterConfig? character;
  final List<OptionConfig> options;
  final OptionTileLayout optionLayout;
  final bool allowMultiSelect;
  final String? validationMessage;
  final bool Function(dynamic)? validator;
  
  const OnboardingStepConfig({
    required this.id,
    this.title,
    this.character,
    required this.options,
    this.optionLayout = OptionTileLayout.icon,
    this.allowMultiSelect = false,
    this.validationMessage,
    this.validator,
  });
}
