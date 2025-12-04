import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/onboarding_controller.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/onboarding_config.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/models/onboarding_models.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/widgets/onboarding_header.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/widgets/onboarding_screen.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/widgets/onboarding_button.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/otp_verification_page.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// New config-driven onboarding page
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  late OnboardingController _controller;
  
  // Text controllers for input steps
  final Map<String, TextEditingController> _textControllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        _controller = OnboardingController();
        return _controller;
      },
      child: Consumer<OnboardingController>(
        builder: (context, controller, _) {
          final currentStepConfig = OnboardingConfig.steps[controller.currentStep];
          final currentValue = controller.getStepValue(currentStepConfig.id);
          final canContinue = currentStepConfig.validator?.call(currentValue) ?? true;
          
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is OtpState) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationPage(
                      userId: state.userId,
                      onboardingData: controller.getUserData(),
                    ),
                  ),
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đăng ký thất bại: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is AuthLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang tạo tài khoản...'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF2B3A4A),
              body: SafeArea(
                child: Column(
                  children: [
                    // Header with progress
                    OnboardingHeader(
                      currentStep: controller.currentStep,
                      totalSteps: OnboardingConfig.steps.length,
                      onBack: controller.currentStep > 0 
                          ? () => _handleBack(controller) 
                          : () => Navigator.pop(context),
                    ),
                    
                    // Main content (PageView)
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: OnboardingConfig.steps.length,
                        itemBuilder: (context, index) {
                          final stepConfig = OnboardingConfig.steps[index];
                          
                          // Handle text input steps differently
                          if (OnboardingConfig.isTextInputStep(stepConfig.id)) {
                            return _buildTextInputScreen(stepConfig, controller);
                          }
                          
                          // Regular option-based screen
                          return OnboardingScreen(
                            config: stepConfig,
                            currentValue: controller.getStepValue(stepConfig.id),
                            onValueChanged: (value) {
                              controller.setStepValue(stepConfig.id, value);
                            },
                          );
                        },
                      ),
                    ),
                    
                    // Continue button
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: OnboardingButton(
                        text: _getButtonText(controller.currentStep),
                        onPressed: canContinue ? () => _handleContinue(controller) : null,
                        state: canContinue 
                            ? OnboardingButtonState.enabled 
                            : OnboardingButtonState.disabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextInputScreen(OnboardingStepConfig config, OnboardingController controller) {
    final textController = _textControllers[config.id]!;
    final isPassword = config.id == 'password';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Character
          if (config.character != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  if (config.character!.imageUrl != null)
                    Image.network(
                      config.character!.imageUrl!,
                      height: 100.h,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 100.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (config.character!.speechText != null) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.snow,
                        borderRadius: BorderRadius.circular(16.w),
                        border: Border.all(color: AppColors.swan, width: 2.5),
                      ),
                      child: Text(
                        config.character!.speechText!,
                        style: TextStyle(
                          color: AppColors.bodyText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          SizedBox(height: 32.h),
          
          // Text input
          TextField(
            controller: textController,
            obscureText: isPassword,
            style: TextStyle(
              color: AppColors.snow,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(config.id),
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16.sp,
              ),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(
                  color: AppColors.featherGreen,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        Icons.visibility_off,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        // Toggle password visibility (would need state management)
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              controller.setStepValue(config.id, value);
            },
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  String _getHintText(String stepId) {
    switch (stepId) {
      case 'name':
        return 'Nhập tên của bạn';
      case 'email':
        return 'email@example.com';
      case 'password':
        return 'Tối thiểu 6 ký tự';
      default:
        return '';
    }
  }

  String _getButtonText(int step) {
    if (step == OnboardingConfig.steps.length - 1) {
      return 'TẠO TÀI KHOẢN';
    }
    if (step == 3) { // Benefits step
      return 'TÔI QUYẾT TÂM';
    }
    return 'TIẾP TỤC';
  }

  void _handleBack(OnboardingController controller) {
    controller.previousStep();
    _pageController.animateToPage(
      controller.currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleContinue(OnboardingController controller) {
    final currentStep = controller.currentStep;
    
    // Last step - register user
    if (currentStep == OnboardingConfig.steps.length - 1) {
      _registerUser(controller);
      return;
    }
    
    // Move to next step
    controller.nextStep();
    _pageController.animateToPage(
      controller.currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _registerUser(OnboardingController controller) {
    final userData = controller.getUserData();
    
    // Debug print
    print('🟢 ONBOARDING DATA: $userData');
    
    // Register with AuthBloc
    context.read<AuthBloc>().add(RegisterEvent(userData: userData));
  }
}
