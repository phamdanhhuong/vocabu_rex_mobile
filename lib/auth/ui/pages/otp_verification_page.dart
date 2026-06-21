import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/widgets/onboarding_button.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/models/onboarding_models.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class OtpVerificationPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>?
      onboardingData; // Store assessment choice and other data

  const OtpVerificationPage({
    super.key,
    required this.userId,
    this.onboardingData,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is VerifySucess) {
          // OTP verification successful
          _navigateAfterVerification();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xác thực thất bại: ${state.message}'),
              backgroundColor: AppColors.cardinal,
            ),
          );
        }
      },
      child: ListenableBuilder(
        listenable: AppPreferences(),
        builder: (context, _) {
          return WebPageWrapper(
            mobileScaffold: StaticSpaceBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.eel),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: 20.h),
                        // Character
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Column(
                            children: [
                              Image.network(
                                'https://res.cloudinary.com/diugsirlo/image/upload/v1739775399/normal_vj6h56.gif',
                                height: 100.h,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.mail_outline,
                                  size: 100.sp,
                                  color: AppColors.hare,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Speech bubble
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColors.snow.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20.r).copyWith(topLeft: Radius.zero),
                                  border: Border.all(
                                    color: AppColors.swan,
                                    width: 2.5,
                                  ),
                                ),
                                child: Text(
                                  'Chúng tôi đã gửi mã xác thực đến email của bạn. Vui lòng nhập mã bên dưới!',
                                  style: TextStyle(
                                    color: AppColors.bodyText,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40.h),

                        // OTP Input
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.eel,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 12.w,
                            ),
                            decoration: InputDecoration(
                              hintText: '000000',
                              hintStyle: TextStyle(
                                color: AppColors.wolf,
                                fontSize: 28.sp,
                                letterSpacing: 12.w,
                              ),
                              filled: true,
                              fillColor: AppColors.snow.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.w),
                                borderSide: BorderSide(
                                  color: AppColors.swan,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.w),
                                borderSide: BorderSide(
                                  color: AppColors.swan,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.w),
                                borderSide: BorderSide(
                                  color: AppColors.macaw,
                                  width: 2.w,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mã xác thực';
                              }
                              if (value.length != 6) {
                                return 'Mã xác thực phải có 6 chữ số';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 40.h),

                        // Verify Button
                        OnboardingButton(
                          text: 'XÁC THỰC',
                          onPressed: _verifyOtp,
                        ),

                        SizedBox(height: 24.h),

                        // Resend OTP
                        Center(
                          child: TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              'Gửi lại mã xác thực',
                              style: TextStyle(
                                color: AppColors.macaw,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
          );
        },
      ),
    );
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(userId: widget.userId, otp: _otpController.text),
      );
    }
  }

  void _resendOtp() {
    // TODO: Implement resend OTP functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi lại mã xác thực'),
        backgroundColor: AppColors.macaw,
      ),
    );
  }

  void _navigateAfterVerification() {
    final assessmentType = widget.onboardingData?['assessmentType'];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xác thực thành công!'),
        backgroundColor: AppColors.featherGreen,
      ),
    );

    // Temporary fallback: navigate to /home directly as the other pages are not defined yet
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
