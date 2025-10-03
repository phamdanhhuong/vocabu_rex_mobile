import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Input fields container
          _buildInputContainer(),
          SizedBox(height: 32.h),
          // Login button
          _buildLoginButton(),
          SizedBox(height: 24.h),
          // Forgot password
          _buildForgotPasswordButton(),
        ],
      ),
    );
  }

  Widget _buildInputContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3A4A5C),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Email field
          _buildEmailField(),
          _buildDivider(),
          // Password field
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Tên đăng nhập hoặc email',
        hintStyle: TextStyle(
          color: AppColors.textGray,
          fontSize: 16.sp,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 20.h,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Color(0xFF4A5A6C),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Mật khẩu',
        hintStyle: TextStyle(
          color: AppColors.textGray,
          fontSize: 16.sp,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 20.h,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Color(0xFF4FC3F7),
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            try {
              context.read<AuthBloc>().add(
                LoginEvent(
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
              );
            } catch (e) {}
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A5A6C),
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'ĐĂNG NHẬP',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        // Handle forgot password
      },
      child: Text(
        'QUÊN MẬT KHẨU',
        style: TextStyle(
          color: Color(0xFF4FC3F7),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}