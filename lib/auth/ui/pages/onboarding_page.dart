import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/onboarding_controller.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/otp_verification_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/language_selection_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/experience_level_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/learning_goals_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/daily_goal_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/learning_benefits_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/assessment_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/profile_setup_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/notification_permission_screen.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _hasAssessmentSelection = false;

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
          // Reset assessment selection when not on assessment step
          if (controller.currentStep != 5) {
            _hasAssessmentSelection = false;
          }
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is OtpState) {
                // Registration successful, navigate to new OTP verification page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationPage(
                      userId: state.userId,
                      onboardingData: {
                        'assessmentType': controller.assessmentType,
                      },
                    ),
                  ),
                );
              } else if (state is AuthFailure) {
                // Registration failed, show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đăng ký thất bại: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is AuthLoading) {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang tạo tài khoản...'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF2B3A4A), // Dark blue background
              body: SafeArea(
                child: Column(
                  children: [
                    // Progress bar and back button
                    _buildHeader(controller),
                    
                    // Main content
                    Expanded(
                      child: _buildCurrentScreen(controller),
                    ),
                    
                    // Continue button
                    _buildContinueButton(controller),
                  ],
                ),
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
                widthFactor: (controller.currentStep + 1) / 11,
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
        return const LearningBenefitsScreen();
      case 5:
        return AssessmentScreen(
          onAssessmentSelected: (value) {
            controller.setAssessmentType(value);
            setState(() {
              _hasAssessmentSelection = true;
            });
          },
        );
      case 6:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          dateOfBirth: controller.dateOfBirth,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          onDateOfBirthChanged: controller.setDateOfBirth,
          step: 0, // Name step
        );
      case 7:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          dateOfBirth: controller.dateOfBirth,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          onDateOfBirthChanged: controller.setDateOfBirth,
          step: 1, // Email step
        );
      case 8:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          dateOfBirth: controller.dateOfBirth,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          onDateOfBirthChanged: controller.setDateOfBirth,
          step: 2, // Password step
        );
      case 9:
        return ProfileSetupScreen(
          name: controller.name,
          email: controller.email,
          password: controller.password,
          dateOfBirth: controller.dateOfBirth,
          onNameChanged: controller.setName,
          onEmailChanged: controller.setEmail,
          onPasswordChanged: controller.setPassword,
          onDateOfBirthChanged: controller.setDateOfBirth,
          step: 3, // DateOfBirth step
        );
      case 10:
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
    if (controller.currentStep == 9) {
      return const SizedBox.shrink();
    }
    
    bool canProceed = controller.canProceedFromStep(controller.currentStep);
    
    // Special handling for assessment screen
    if (controller.currentStep == 5) {
      canProceed = _hasAssessmentSelection;
    }
    
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
        return 'TIẾP TỤC';
      case 6:
      case 7:
        return 'TIẾP TỤC';
      case 8:
        return 'TẠO TÀI KHOẢN';
      default:
        return 'TIẾP TỤC';
    }
  }

  void _handleContinue(OnboardingController controller) {
    if (controller.currentStep == 8) {
      // After password step (step 8), register user
      _registerUser(controller);
    } else if (controller.currentStep == 5) {
      // Assessment step - just proceed to profile setup
      controller.nextStep();
    } else if (controller.currentStep < 9) {
      controller.nextStep();
    }
  }

  void _registerUser(OnboardingController controller) {
    // Validate required fields
    if (controller.name == null || controller.name!.isEmpty ||
        controller.email == null || controller.email!.isEmpty ||
        controller.password == null || controller.password!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get user data from onboarding controller
    final userData = controller.getUserData();
    
    // Set proficiency level based on assessment choice (default to BEGINNER)
    userData['proficiencyLevel'] = 'BEGINNER';
    
    // Debug print to check userData
    print('🟢 ONBOARDING DATA: $userData');
    controller.printCurrentState();
    
    // Register user with AuthBloc
    context.read<AuthBloc>().add(RegisterEvent(userData: userData));
  }



  void _completeOnboarding(OnboardingController controller) {
    // After OTP verification and assessment completion, navigate to main app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chào mừng bạn đến với VocabuRex!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }
}