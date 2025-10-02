import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;

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
    return Scaffold(
      backgroundColor: Color(0xFF2B3A4A), // Dark blue background
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Đăng nhập thành công! Chào mừng ${state.user.email}",
                ),
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Lỗi: ${state.message}")));
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button and title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textGray,
                        size: 28.sp,
                      ),
                    ),
                    Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 48.w), // Balance the close button
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      
                      // Login form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email/Username field
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF3A4A5C),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                children: [
                                  TextField(
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
                                  ),
                                  Container(
                                    height: 1,
                                    color: Color(0xFF4A5A6C),
                                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                                  ),
                                  // Password field
                                  TextField(
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
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 32.h),

                            // Login button
                            SizedBox(
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
                            ),

                            SizedBox(height: 24.h),

                            // Forgot password
                            TextButton(
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
                            ),

                            SizedBox(height: 60.h),
                          ],
                        ),
                      ),

                      // Social login section
                      Column(
                        children: [
                          // Phone login
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Handle phone login
                              },
                              icon: Icon(
                                Icons.phone,
                                color: Color(0xFF4FC3F7),
                                size: 24.sp,
                              ),
                              label: Text(
                                'ĐĂNG NHẬP ĐIỆN THOẠI',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFF4A5A6C)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Social login buttons row
                          Row(
                            children: [
                              // Facebook button
                              Expanded(
                                child: SizedBox(
                                  height: 56.h,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Handle Facebook login
                                    },
                                    icon: Icon(
                                      Icons.facebook,
                                      color: Color(0xFF4267B2),
                                      size: 24.sp,
                                    ),
                                    label: Text(
                                      'FACEBOOK',
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Color(0xFF4A5A6C)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 16.w),

                              // Google button
                              Expanded(
                                child: SizedBox(
                                  height: 56.h,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Handle Google login
                                    },
                                    icon: Text(
                                      'G',
                                      style: TextStyle(
                                        color: Color(0xFFDB4437),
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    label: Text(
                                      'GOOGLE',
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Color(0xFF4A5A6C)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Spacer(),

                      // Terms and privacy
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Khi đăng ký trên Duolingo, bạn đã đồng ý với ',
                              ),
                              TextSpan(
                                text: 'Các chính sách',
                                style: TextStyle(
                                  color: Color(0xFF4FC3F7),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  color: Color(0xFF4FC3F7),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' của chúng tôi.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
