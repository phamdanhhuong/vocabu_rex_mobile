import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button_tokens.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetOtpSentState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.featherGreen,
              ),
            );
            // Navigate to reset password page
            Navigator.pushNamed(
              context,
              '/reset-password',
              arguments: state.userId,
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
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
                  'Quên mật khẩu',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.eel,
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Description
                Text(
                  'Chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu của bạn qua email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.wolf,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Email input
                Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.swan,
                        width: 2,
                      ),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.eel,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Submit button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    
                    return AppButton(
                      label: 'GỬI',
                      onPressed: isLoading ? null : _handleSubmit,
                      isLoading: isLoading,
                      isDisabled: isLoading,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      width: double.infinity,
                      backgroundColor: AppColors.macaw,
                      shadowColor: AppColors.macaw.withOpacity(0.3),
                    );
                  },
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SendResetOtpEvent(email: _emailController.text.trim()),
      );
    }
  }
}
