import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class OtpVerificationPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? onboardingData; // Store assessment choice and other data

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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.eel),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              
              // Title
              Text(
                'Xác thực email',
                style: TextStyle(
                  color: AppColors.featherGreen,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Description
              Text(
                'Chúng tôi đã gửi mã xác thực đến email của bạn.\nVui lòng kiểm tra hộp thư và nhập mã bên dưới.',
                style: TextStyle(
                  color: AppColors.wolf,
                  fontSize: 16.sp,
                ),
                textAlign: TextAlign.center,
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
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8.w,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: AppColors.wolf,
                      fontSize: 24.sp,
                      letterSpacing: 8.w,
                    ),
                    filled: true,
                    fillColor: AppColors.snow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.w),
                      borderSide: BorderSide(color: AppColors.swan, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.w),
                      borderSide: BorderSide(color: AppColors.swan, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.w),
                      borderSide: BorderSide(color: AppColors.featherGreen, width: 2.w),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20.h),
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
              
              SizedBox(height: 32.h),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.featherGreen,
                    foregroundColor: AppColors.snow,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  child: Text(
                    'XÁC THỰC',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Resend OTP
              TextButton(
                onPressed: _resendOtp,
                child: Text(
                  'Gửi lại mã xác thực',
                  style: TextStyle(
                    color: AppColors.featherGreen,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(
          userId: widget.userId,
          otp: _otpController.text,
        ),
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

    // Navigate based on assessment choice
    if (assessmentType == 'skip') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (assessmentType == 'assessment') {
      Navigator.pushReplacementNamed(context, '/assessment-test');
    } else if (assessmentType == 'beginner') {
      Navigator.pushReplacementNamed(context, '/beginner-lessons');
    } else {
      // Default to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}