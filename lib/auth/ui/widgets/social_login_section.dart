import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
        SizedBox(height: 16.h),
        _buildSocialLoginRow(),
      ],
    );
  }

  Widget _buildSocialLoginRow() {
    return Row(
      children: [
        Expanded(child: _buildFacebookButton()),
        SizedBox(width: 16.w),
        Expanded(child: _buildGoogleButton()),
      ],
    );
  }

  Widget _buildFacebookButton() {
    return SizedBox(
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: _handleFacebookSignIn,
        icon: Icon(Icons.facebook, color: Color(0xFF4267B2), size: 24.sp),
        label: Text(
          'FACEBOOK',
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

  Future<void> _handleFacebookSignIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;

        if (accessToken == null) {
          throw Exception('Không lấy được access token từ Facebook');
        }

        print("======== FACEBOOK ACCESS TOKEN ========");
        print(accessToken.tokenString);
        print("=======================================");

        if (mounted) {
          context.read<AuthBloc>().add(
            FacebookLoginEvent(accessToken: accessToken.tokenString),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        print("Người dùng đã hủy đăng nhập Facebook");
      } else {
        throw Exception('Đăng nhập Facebook thất bại: ${result.message}');
      }
    } catch (error) {
      print("Lỗi đăng nhập Facebook: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập Facebook thất bại: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
