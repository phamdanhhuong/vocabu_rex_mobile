import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
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
import 'package:google_sign_in/google_sign_in.dart';

/// New config-driven onboarding page
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  late OnboardingController _controller;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '211988684317-no41dc6blcn7fngmjnvvmn1alpg5step.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // Text controllers for input steps
  final Map<String, TextEditingController> _textControllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
  };

  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

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
          final currentStepConfig =
              OnboardingConfig.steps[controller.currentStep];
          final currentValue = controller.getStepValue(currentStepConfig.id);
          final canContinue =
              currentStepConfig.validator?.call(currentValue) ?? true;
              
          final isCreateAccountStep = currentStepConfig.id == 'create_account';

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
              } else if (state is AuthSuccess) {
                 Navigator.pushReplacementNamed(context, '/home');
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${state.message}'),
                    backgroundColor: AppColors.cardinal,
                  ),
                );
              } else if (state is AuthLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang xử lý...'),
                    backgroundColor: AppColors.macaw,
                  ),
                );
              }
            },
            child: WebPageWrapper(
              mobileScaffold: Scaffold(
                backgroundColor: AppColors.background,
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
                            if (OnboardingConfig.isTextInputStep(
                              stepConfig.id,
                            )) {
                              return _buildCreateAccountScreen(
                                stepConfig,
                                controller,
                              );
                            }

                            // Regular option-based screen
                            return OnboardingScreen(
                              config: stepConfig,
                              currentValue: controller.getStepValue(
                                stepConfig.id,
                              ),
                              onValueChanged: (value) {
                                controller.setStepValue(stepConfig.id, value);
                              },
                            );
                          },
                        ),
                      ),

                      // Continue button (Hide on create account step to use custom form buttons)
                      if (!isCreateAccountStep)
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                          child: OnboardingButton(
                            text: _getButtonText(controller.currentStep),
                            onPressed: canContinue
                                ? () => _handleContinue(controller)
                                : null,
                            state: canContinue
                                ? OnboardingButtonState.enabled
                                : OnboardingButtonState.disabled,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateAccountScreen(
    OnboardingStepConfig config,
    OnboardingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    size: 100.sp,
                                    color: AppColors.hare,
                                  ),
                            ),
                          if (config.character!.speechText != null) ...[
                            SizedBox(height: 16.h),
                            // Speech bubble
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.snow,
                                borderRadius: BorderRadius.circular(20.r).copyWith(topLeft: Radius.zero),
                                border: Border.all(
                                  color: AppColors.swan,
                                  width: 2.5,
                                ),
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

                  SizedBox(height: 24.h),

                  // Form nhập liệu
                  Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.snow,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.swan, width: 2),
                      ),
                      child: Column(
                        children: [
                          // Name
                          TextFormField(
                            controller: _textControllers['name'],
                            style: TextStyle(color: AppColors.eel, fontSize: 16.sp),
                            decoration: InputDecoration(
                              hintText: 'Tên của bạn',
                              hintStyle: TextStyle(color: AppColors.wolf, fontSize: 16.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                            ),
                            validator: (v) => v!.isEmpty ? 'Nhập tên của bạn' : null,
                          ),
                          Container(height: 2, color: AppColors.swan),
                          // Email
                          TextFormField(
                            controller: _textControllers['email'],
                            style: TextStyle(color: AppColors.eel, fontSize: 16.sp),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: AppColors.wolf, fontSize: 16.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                            ),
                            validator: (v) => v!.isEmpty ? 'Nhập email hợp lệ' : null,
                          ),
                          Container(height: 2, color: AppColors.swan),
                          // Password
                          TextFormField(
                            controller: _textControllers['password'],
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(color: AppColors.eel, fontSize: 16.sp),
                            decoration: InputDecoration(
                              hintText: 'Mật khẩu (tối thiểu 6 ký tự)',
                              hintStyle: TextStyle(color: AppColors.wolf, fontSize: 16.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.macaw,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            validator: (v) => v!.length < 6 ? 'Mật khẩu quá ngắn' : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                  
                  // Đăng ký Button
                  OnboardingButton(
                    text: 'TẠO TÀI KHOẢN',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.setStepValue('name', _textControllers['name']!.text);
                        controller.setStepValue('email', _textControllers['email']!.text);
                        controller.setStepValue('password', _textControllers['password']!.text);
                        _registerUser(controller);
                      }
                    },
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Google Sign In
                  SizedBox(
                    height: 56.h,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleGoogleSignIn(context),
                      icon: Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFFDB4437),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: Text(
                        'ĐĂNG KÝ BẰNG GOOGLE',
                        style: TextStyle(
                          color: AppColors.eel,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.snow,
                        side: BorderSide(color: AppColors.swan, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Không lấy được ID token Google');

      if (mounted) {
        context.read<AuthBloc>().add(GoogleLoginEvent(idToken: idToken));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập Google thất bại: $error'),
            backgroundColor: AppColors.cardinal,
          ),
        );
      }
    }
  }

  String _getButtonText(int step) {
    if (step == 3) {
      // Benefits step
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
    controller.nextStep();
    _pageController.animateToPage(
      controller.currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _registerUser(OnboardingController controller) {
    final userData = controller.getUserData();
    context.read<AuthBloc>().add(RegisterEvent(userData: userData));
  }
}
