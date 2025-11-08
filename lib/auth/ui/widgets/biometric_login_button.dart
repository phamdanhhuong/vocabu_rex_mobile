import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/core/biometric_service.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';

class BiometricLoginButton extends StatefulWidget {
  const BiometricLoginButton({super.key});

  @override
  State<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends State<BiometricLoginButton> {
  bool _isAvailable = false;
  String _biometricType = 'Sinh trắc học';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Kiểm tra thiết bị có hỗ trợ sinh trắc học
    final isDeviceSupported = await BiometricService.isDeviceSupported();
    final canCheck = await BiometricService.canCheckBiometrics();
    final isEnabled = await TokenManager.isBiometricsEnabled();
    
    // Lấy tên loại sinh trắc học
    final biometricTypeName = await BiometricService.getBiometricTypeName();

    if (mounted) {
      setState(() {
        _isAvailable = isDeviceSupported && canCheck && isEnabled;
        _biometricType = biometricTypeName;
      });
    }
  }

  void _handleBiometricLogin() {
    context.read<AuthBloc>().add(BiometricLoginEvent());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 24.h),
        Text(
          'HOẶC',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.wolf,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: AppTokens.headerButtonWidth.h,
          child: ElevatedButton.icon(
            onPressed: _handleBiometricLogin,
            icon: Icon(
              _biometricType.contains('Face') ? Icons.face : Icons.fingerprint,
              color: AppColors.macaw,
              size: 28.sp,
            ),
            label: Text(
              'ĐĂNG NHẬP BẰNG $_biometricType',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.snow,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: AppColors.macaw.withOpacity(0.3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
