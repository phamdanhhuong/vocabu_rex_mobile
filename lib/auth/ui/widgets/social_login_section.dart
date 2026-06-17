import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/biometric_login_button.dart';

class SocialLoginSection extends StatefulWidget {
  const SocialLoginSection({super.key});

  @override
  State<SocialLoginSection> createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '211988684317-no41dc6blcn7fngmjnvvmn1alpg5step.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BiometricLoginButton(),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.swan, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'HOẶC',
                style: TextStyle(
                  color: AppColors.wolf,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.swan, thickness: 1)),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSocialLoginRow(),
      ],
    );
  }

  Widget _buildSocialLoginRow() {
    return SizedBox(
      width: double.infinity,
      child: _buildGoogleButton(),
    );
  }



  Widget _buildGoogleButton() {
    return SizedBox(
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
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
            color: AppColors.snow,
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
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Không lấy được ID token Google');
      }

      print("======== GOOGLE ID TOKEN ========");
      print(idToken);
      print("=================================");

      if (mounted) {
        print("Chay duoc gooogle");
        context.read<AuthBloc>().add(GoogleLoginEvent(idToken: idToken));
      }
    } catch (error) {
      print("Lỗi đăng nhập Google: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập google thất bại: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}
