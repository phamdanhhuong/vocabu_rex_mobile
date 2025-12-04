import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../models/onboarding_models.dart';
import 'character_display.dart';
import 'onboarding_option_tile.dart';

/// Generic onboarding screen that renders based on config
class OnboardingScreen extends StatelessWidget {
  final OnboardingStepConfig config;
  final dynamic currentValue;
  final Function(dynamic) onValueChanged;
  
  const OnboardingScreen({
    Key? key,
    required this.config,
    required this.currentValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Character/Image section
        if (config.character != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: CharacterDisplay(
              imageUrl: config.character!.imageUrl,
              speechText: config.character!.speechText,
              position: config.character!.position,
              showSkipButton: config.character!.showSkip,
              onSkip: config.character!.onSkip,
            ),
          ),
        
        // Main content (scrollable options)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (if no character)
                if (config.character == null && config.title != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Text(
                      config.title!,
                      style: TextStyle(
                        color: AppColors.snow,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                
                // Options list
                ...config.options.map((option) {
                  final isSelected = _isSelected(option.value);
                  
                  return OnboardingOptionTile(
                    title: option.title,
                    subtitle: option.subtitle,
                    isSelected: isSelected,
                    onTap: () => _handleOptionTap(option.value),
                    layout: config.optionLayout,
                    icon: option.icon,
                    emoji: option.emoji,
                    timeBadge: option.timeBadge,
                    badgeColor: option.badgeColor,
                    badgeText: option.badgeText,
                    progressValue: option.progressValue,
                  );
                }),
                
                // Bottom spacing
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isSelected(dynamic value) {
    if (config.allowMultiSelect && currentValue is List) {
      return (currentValue as List).contains(value);
    }
    return currentValue == value;
  }

  void _handleOptionTap(dynamic value) {
    if (config.allowMultiSelect) {
      final current = List.from(currentValue as List? ?? []);
      if (current.contains(value)) {
        current.remove(value);
      } else {
        current.add(value);
      }
      onValueChanged(current);
    } else {
      onValueChanged(value);
    }
  }
}
