import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/login_header.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/login_form.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/social_login_section.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/terms_and_privacy.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/biometric_enable_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            
            // Hiển thị dialog hỏi bật sinh trắc học (nếu chưa bật)
            BiometricEnableDialog.show(context).then((_) {
              // Sau khi dialog đóng (hoặc không hiện), chuyển sang home
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            });
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Lỗi: ${state.message}")));
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const LoginHeader(),

              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      
                      // Login form
                      const LoginForm(),
                      
                      SizedBox(height: 60.h),

                      // Social login section
                      const SocialLoginSection(),

                      const Spacer(),

                      // Terms and privacy
                      const TermsAndPrivacy(),
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
