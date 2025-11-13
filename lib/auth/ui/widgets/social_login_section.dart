import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class SocialLoginSection extends StatefulWidget {
  const SocialLoginSection({super.key});

  @override
  State<SocialLoginSection> createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {
  // Th�m serverClientId (Web Client ID) d? l?y du?c idToken
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '211988684317-no41dc6blcn7fngmjnvvmn1alpg5step.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPhoneLoginButton(),
        SizedBox(height: 16.h),
        _buildSocialLoginRow(),
      ],
    );
  }

  Widget _buildPhoneLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.phone, color: Color(0xFF4FC3F7), size: 24.sp),
        label: Text(
          '�ANG NH?P �I?N THO?I',
          style: TextStyle(
            color: AppColors.snow,
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
        // Ngu?i d�ng d� h?y dang nh?p
        return;
      }

      // L?y th�ng tin x�c th?c
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Kh�ng l?y du?c ID Token t? Google');
      }

      print("======== GOOGLE ID TOKEN ========");
      print(idToken);
      print("=================================");

      // G?i idToken l�n backend qua BLoC
      if (mounted) {
        print("Chay duoc gooogle");
        context.read<AuthBloc>().add(GoogleLoginEvent(idToken: idToken));
      }
    } catch (error) {
      print("L?i dang nh?p Google: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('�ang nh?p Google th?t b?i: $error'),
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
        // L?y access token
        final AccessToken? accessToken = result.accessToken;

        if (accessToken == null) {
          throw Exception('Kh�ng l?y du?c Access Token t? Facebook');
        }

        print("======== FACEBOOK ACCESS TOKEN ========");
        print(accessToken.tokenString);
        print("=======================================");

        // G?i accessToken l�n backend qua BLoC
        if (mounted) {
          print("Ch?y du?c Facebook login");
          context.read<AuthBloc>().add(
            FacebookLoginEvent(accessToken: accessToken.tokenString),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        print("Ngu?i d�ng d� h?y dang nh?p Facebook");
      } else {
        throw Exception('�ang nh?p Facebook th?t b?i: ${result.message}');
      }
    } catch (error) {
      print("L?i dang nh?p Facebook: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('�ang nh?p Facebook th?t b?i: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
