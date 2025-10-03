import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? password;
  final Function(String) onNameChanged;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final int step; // 0: name, 1: email, 2: password

  const ProfileSetupScreen({
    super.key,
    this.name,
    this.email,
    this.password,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.step,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late TextEditingController _controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  void _updateControllerText() {
    switch (widget.step) {
      case 0:
        _controller.text = widget.name ?? '';
        break;
      case 1:
        _controller.text = widget.email ?? '';
        break;
      case 2:
        _controller.text = widget.password ?? '';
        break;
    }
  }

  @override
  void didUpdateWidget(ProfileSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _updateControllerText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed header section
        _buildFixedHeader(),
        
        // Scrollable content
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }

  Widget _buildFixedHeader() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        _buildDuoCharacter(),
        SizedBox(height: 40.h),
        _buildSpeechBubble(),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInputField(),
          SizedBox(height: 32.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildDuoCharacter() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(60.w),
        border: Border.all(color: Colors.grey[800]!, width: 4),
      ),
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(60.w),
            ),
          ),
          _buildEye(left: 25.w),
          _buildEye(right: 25.w),
          _buildBeak(),
          if (widget.step == 2) _buildGlasses(), // Show glasses for password step
        ],
      ),
    );
  }

  Widget _buildEye({double? left, double? right}) {
    return Positioned(
      left: left,
      right: right,
      top: 35.h,
      child: Container(
        width: 18.w,
        height: 25.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Container(
            width: 8.w,
            height: 12.h,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeak() {
    return Positioned(
      left: 52.w,
      top: 65.h,
      child: Container(
        width: 16.w,
        height: 12.h,
        decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildGlasses() {
    return Positioned(
      left: 15.w,
      top: 25.h,
      child: Container(
        width: 90.w,
        height: 45.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.w),
          borderRadius: BorderRadius.circular(25.w),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    String message;
    switch (widget.step) {
      case 0:
        message = 'Tôi có thể gọi bạn là gì?';
        break;
      case 1:
        message = 'Địa chỉ email của bạn là gì?';
        break;
      case 2:
        message = 'Hãy tạo mật khẩu an toàn!';
        break;
      default:
        message = '';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          CustomPaint(
            size: Size(20.w, 10.h),
            painter: TrianglePainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          _buildTextField(),
          SizedBox(height: 20.h),
          if (widget.step == 2) _buildPasswordHint(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    String hintText;
    bool isPassword = widget.step == 2;
    
    switch (widget.step) {
      case 0:
        hintText = 'Nhập tên của bạn';
        break;
      case 1:
        hintText = 'Nhập email của bạn';
        break;
      case 2:
        hintText = 'Nhập mật khẩu';
        break;
      default:
        hintText = '';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: Colors.grey[600]!, width: 1.w),
      ),
      child: TextField(
        controller: _controller,
        obscureText: isPassword && _obscurePassword,
        onChanged: _onTextChanged,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        ),
      ),
    );
  }

  Widget _buildPasswordHint() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: Colors.blue[700]!, width: 1.w),
      ),
      child: Text(
        'Mật khẩu phải có ít nhất 6 ký tự',
        style: TextStyle(
          color: Colors.blue[300],
          fontSize: 14.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _onTextChanged(String value) {
    switch (widget.step) {
      case 0:
        widget.onNameChanged(value);
        break;
      case 1:
        widget.onEmailChanged(value);
        break;
      case 2:
        widget.onPasswordChanged(value);
        break;
    }
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}