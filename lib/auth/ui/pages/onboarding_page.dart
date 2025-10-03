import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/onboarding_controller.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/language_selection_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/experience_level_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/learning_goals_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/daily_goal_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/profile_setup_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/notification_permission_screen.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Consumer<OnboardingController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF2B3A4A), // Dark blue background
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Progress bar and back button
                  SliverToBoxAdapter(
                    child: _buildHeader(controller),
                  ),
                  
                  // Main content
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildCurrentScreen(controller),
                        ),
                        // Continue button
                        _buildContinueButton(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OnboardingController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Back button
          if (controller.currentStep > 0)
            GestureDetector(
              onTap: () => controller.previousStep(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.grey[400],
                  size: 24.sp,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[400],
                  size: 24.sp,
                ),
              ),
            ),
          
          SizedBox(width: 16.w),
          
          // Progress bar
          Expanded(
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (controller.currentStep + 1) / 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen(OnboardingController controller) {
    switch (controller.currentStep) {
      case 0:
        return LanguageSelectionScreen(

          onLanguageSelected: controller.setLanguage,
        );
      case 1:
        return ExperienceLevelScreen(
          selectedLevel: controller.experienceLevel,
          onLevelSelected: controller.setExperienceLevel,
        );
      case 2:
        return LearningGoalsScreen(
          selectedGoals: controller.selectedGoals,
          onGoalToggled: controller.toggleGoal,
        );
      case 3:
        return DailyGoalScreen(
          selectedGoal: controller.dailyGoal,
          onGoalSelected: controller.setDailyGoal,
        );
      case 4:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          step: 0, // Name step
        );
      case 5:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          step: 1, // Email step
        );
      case 6:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          step: 2, // Password step
        );
      case 7:
        return NotificationPermissionScreen(
          onPermissionSelected: (enabled) {
            controller.setNotifications(enabled);
            _completeOnboarding(controller);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContinueButton(OnboardingController controller) {
    // Don't show continue button on notification screen as it handles its own navigation
    if (controller.currentStep == 7) {
      return const SizedBox.shrink();
    }
    
    final canProceed = controller.canProceedFromStep(controller.currentStep);
    
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: GestureDetector(
        onTap: canProceed ? () => _handleContinue(controller) : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            color: canProceed ? AppColors.primaryGreen : Colors.grey[600],
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: Text(
            _getContinueButtonText(controller.currentStep),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _getContinueButtonText(int step) {
    switch (step) {
      case 0:
      case 1:
      case 2:
      case 3:
        return 'TIẾP TỤC';
      case 4:
        return 'TÔI QUYẾT TÂM';
      case 5:
      case 6:
        return 'TIẾP TỤC';
      default:
        return 'HÃY NHẮC TÔI HỌC NHÉ';
    }
  }

  void _handleContinue(OnboardingController controller) {
    if (controller.currentStep < 7) {
      controller.nextStep();
    }
  }

  void _completeOnboarding(OnboardingController controller) {
    // Here you would typically:
    // 1. Register the user with the collected data
    // 2. Navigate to the main app or lesson 1
    
    final userData = controller.getUserData();
    print('User registration data: $userData');
    
    // For now, let's navigate to home or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding completed! Welcome to Duolingo!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate to main app (you'll need to implement this route)
    Navigator.pushReplacementNamed(context, '/home');
  }
}