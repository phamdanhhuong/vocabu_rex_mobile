import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/profile_input_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? password;
  final DateTime? dateOfBirth;
  final Function(String) onNameChanged;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final Function(DateTime) onDateOfBirthChanged;
  final int step; // 0: name, 1: email, 2: password, 3: dateOfBirth

  const ProfileSetupScreen({
    super.key,
    this.name,
    this.email,
    this.password,
    this.dateOfBirth,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onDateOfBirthChanged,
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
      case 3:
        // Date of birth doesn't use text controller
        _controller.text = '';
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60.h),
                DuoWithSpeechFactory.vertical(
                  duoType: DuoCharacterType.happy,
                  speechText: _getSpeechText(),
                ),
                SizedBox(height: 40.h),
                _buildForm(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getSpeechText() {
    switch (widget.step) {
      case 0:
        return 'Chào bạn! Tôi có thể gọi bạn là gì?';
      case 1:
        return 'Tuyệt vời! Bây giờ cho tôi biết email của bạn nhé.';
      case 2:
        return 'Tạo một mật khẩu để bảo vệ tài khoản.';
      case 3:
        return 'Cuối cùng, cho tôi biết ngày sinh của bạn nhé!';
      default:
        return '';
    }
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: _buildInputField(),
    );
  }

  Widget _buildInputField() {
    switch (widget.step) {
      case 0:
        return ProfileInputField(
          label: 'Tên của bạn',
          hintText: 'Nhập tên của bạn',
          controller: _controller,
          onChanged: widget.onNameChanged,
          keyboardType: TextInputType.name,
        );
      case 1:
        return ProfileInputField(
          label: 'Địa chỉ email',
          hintText: 'Nhập địa chỉ email',
          controller: _controller,
          onChanged: widget.onEmailChanged,
          keyboardType: TextInputType.emailAddress,
        );
      case 2:
        return ProfileInputField(
          label: 'Mật khẩu',
          hintText: 'Tạo mật khẩu mạnh',
          controller: _controller,
          onChanged: widget.onPasswordChanged,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        );
      case 3:
        return _buildDatePicker();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày sinh',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A20),
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: Colors.grey[600]!,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.dateOfBirth == null
                      ? "Chọn ngày sinh"
                      : "${widget.dateOfBirth!.day}/${widget.dateOfBirth!.month}/${widget.dateOfBirth!.year}",
                  style: TextStyle(
                    color: widget.dateOfBirth == null
                        ? Colors.grey[400]
                        : Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)), // 20 years old
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF58CC02),
              onPrimary: Colors.black,
              surface: Color(0xFF1E2A20),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onDateOfBirthChanged(picked);
    }
  }
}