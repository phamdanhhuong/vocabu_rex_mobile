import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Feed UI Tokens - Centralized spacing, sizing, and typography values
class FeedTokens {
  // Spacing
  static double get spacingXs => 2.h;
  static double get spacingS => 4.h;
  static double get spacingM => 8.h;
  static double get spacingL => 12.h;
  static double get spacingXl => 16.h;
  static double get spacingXxl => 20.h;
  static double get spacing3xl => 24.h;

  // Horizontal Spacing
  static double get spacingHorizontalXs => 2.w;
  static double get spacingHorizontalS => 4.w;
  static double get spacingHorizontalM => 6.w;
  static double get spacingHorizontalL => 8.w;
  static double get spacingHorizontalXl => 12.w;
  static double get spacingHorizontalXxl => 16.w;
  static double get spacingHorizontal3xl => 20.w;

  // Border Radius
  static double get radiusS => 12.r;
  static double get radiusM => 16.r;
  static double get radiusL => 20.r;
  static double get radiusXl => 24.r;
  static double get radiusRound => 40.r;

  // Border Width
  static const double borderThin = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;

  // Icon Sizes
  static double get iconXs => 16.sp;
  static double get iconS => 18.sp;
  static double get iconM => 20.sp;
  static double get iconL => 28.sp;
  static double get iconXl => 32.sp;
  static double get iconXxl => 60.sp;

  // Avatar Sizes
  static double get avatarS => 20.r;
  static double get avatarM => 22.r;
  static double get avatarL => 26.r;

  // Font Sizes
  static double get fontXs => 13.sp;
  static double get fontS => 14.sp;
  static double get fontM => 15.sp;
  static double get fontL => 16.sp;
  static double get fontXl => 18.sp;
  static double get fontXxl => 26.sp;

  // Font Weights (using Material weights)
  static const fontWeightRegular = FontWeight.w400;
  static const fontWeightMedium = FontWeight.w500;
  static const fontWeightSemiBold = FontWeight.w600;
  static const fontWeightBold = FontWeight.w700;
  static const fontWeightExtraBold = FontWeight.w800;

  // Line Heights
  static const lineHeightTight = 1.3;
  static const lineHeightNormal = 1.5;

  // Letter Spacing
  static const letterSpacingTight = 0.0;
  static const letterSpacingNormal = 0.5;

  // Card Dimensions
  static double get cardPadding => 16.w;
  static double get cardMarginVertical => 6.h;
  static double get cardMarginHorizontal => 12.w;

  // Post Specific
  static double get postAchievementIconSize => 100.w;
  static double get reactionButtonWidth => 160.w;
  static double get reactionButtonPadding => 10.h;
  static double get reactionCircleSize => 40.w;
  static double get reactionCirclePadding => 8.w;
  static double get reactionCircleOverlap => 24.w;

  // Comment Input
  static double get commentInputPaddingHorizontal => 16.w;
  static double get commentInputPaddingVertical => 12.h;

  // Elevation/Shadow
  static const elevationLow = 4.0;
  static const shadowBlurLow = 12.0;
  static const shadowOpacityLow = 0.15;
  static const shadowOpacityMedium = 0.3;

  // Overlay
  static double get overlayPaddingHorizontal => 12.w;
  static double get overlayPaddingVertical => 8.h;
  static double get overlayEmojiMargin => 4.w;
  static double get overlayOffset => 80.h;
  static double get overlayOffsetHorizontal => 20.w;

  // Tab Bar
  static double get tabBarHeight => 50.h;
  static const tabIndicatorWeight = 3.0;

  // Max Items Display
  static const maxReactionTypesDisplay = 3;
  static const commentsPaginationLimit = 20;
  static const feedPaginationLimit = 20;

  // Page Specific
  static const scrollThreshold = 200.0;
  static const snackBarDuration = Duration(seconds: 1);
  
  // Comments Sheet
  static double get commentSheetHeightRatio => 0.9;
  static double get commentAvatarRadius => 20.r;
  static double get commentInputRadius => 24.r;
  static double get commentSendIconSize => 28.sp;
  
  // Post Reactions Page
  static double get reactionPageIconSize => 48.sp;
  static double get reactionUserItemPadding => 12.h;
  static double get reactionUserItemMargin => 4.h;
  static double get followButtonPadding => 10.h;
  static double get followButtonPaddingHorizontal => 20.w;
}
