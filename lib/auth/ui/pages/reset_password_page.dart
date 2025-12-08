import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button_tokens.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userId;
  
  const ResetPasswordPage({
    super.key,
    required this.userId,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.featherGreen,
              ),
            );
            // Navigate back to login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.cardinal,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.eel,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Title
                  Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eel,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Description
                  Text(
                    'Nhập mã OTP đã được gửi đến email của bạn và mật khẩu mới.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.wolf,
                      height: 1.4,
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // OTP input
                        _buildInputField(
                          controller: _otpController,
                          hintText: 'Mã OTP',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mã OTP';
                            }
                            if (value.length != 6) {
                              return 'Mã OTP phải có 6 chữ số';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Password input
                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Mật khẩu mới',
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu mới';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Confirm password input
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Xác nhận mật khẩu mới',
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Submit button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      
                      return AppButton(
                        label: 'ĐẶT LẠI MẬT KHẨU',
                        onPressed: isLoading ? null : _handleSubmit,
                        isLoading: isLoading,
                        isDisabled: isLoading,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        width: double.infinity,
                        backgroundColor: AppColors.featherGreen,
                      );
                    },
                  ),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.swan,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.eel,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.hare,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.swan,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.eel,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.hare,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.macaw,
              size: 22.sp,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ResetPasswordEvent(
          userId: widget.userId,
          otp: _otpController.text.trim(),
          newPassword: _passwordController.text,
        ),
      );
    }
  }
}
