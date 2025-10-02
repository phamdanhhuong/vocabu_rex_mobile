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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Duo character
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(60.w),
            border: Border.all(color: Colors.grey[800]!, width: 4),
          ),
          child: Stack(
            children: [
              // Main head
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(60.w),
                ),
              ),
              // Eyes
              _buildEye(25.w, 35.h),
              _buildEye(77.w, 35.h),
              // Beak
              Positioned(
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
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        
        // Speech bubble
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Column(
            children: [
              Text(
                _getSpeechText(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              // Triangle pointer
              CustomPaint(
                size: Size(20.w, 10.h),
                painter: TrianglePainter(),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 60.h),
        
        // Input field
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(color: Colors.grey[600]!, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    obscureText: widget.step == 2 && _obscurePassword,
                    onChanged: (value) {
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
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _getHintText(),
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                if (widget.step == 2)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        const Spacer(),
        
        if (widget.step == 0) ...[
          Text(
            'Như vậy bạn sẽ học được 50 từ vựng\ntrong tuần đầu tiên!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Như vậy bạn sẽ học được ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                TextSpan(
                  text: '50 từ vựng',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '\ntrong tuần đầu tiên!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildEye(double left, double top) {
    return Positioned(
      left: left,
      top: top,
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

  String _getSpeechText() {
    switch (widget.step) {
      case 0:
        return 'Hãy cùng lên kế hoạch học tập nhé!';
      case 1:
        return 'Được rồi, mình cùng học từ cơ bản nhé!';
      case 2:
        return 'Tôi sẽ nhắc bạn luyện tập để giúp bạn tạo thói quen học tập nhé!';
      default:
        return '';
    }
  }

  String _getHintText() {
    switch (widget.step) {
      case 0:
        return 'Tên của bạn';
      case 1:
        return 'Email';
      case 2:
        return 'Mật khẩu';
      default:
        return '';
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