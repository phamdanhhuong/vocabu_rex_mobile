import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/wigets/custom_text_field.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  String _gender = "MALE";
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)), // 18 tuổi
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.black,
              surface: AppColors.primaryDark,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage("assets/logo.png"), height: 100),
              Text(
                "Register",
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              SizedBox(height: 50),
              Form(
                key: _formKey,
                child: SizedBox(
                  width: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Your-email@example.com",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: _fullNameController,
                        hintText: "Your full name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Trường chọn ngày sinh
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E2A20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? "Chọn ngày sinh"
                                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey
                                      : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      RadioGroup<String>(
                        groupValue: _gender,
                        onChanged: (String? value) {
                          setState(() {
                            _gender = value ?? "MALE";
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Nam',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                leading: Radio(
                                  value: "MALE",
                                  activeColor: Colors.blue,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Nữ',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                leading: Radio(
                                  value: "FEMALE",
                                  activeColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng chọn ngày sinh"),
                          ),
                        );
                        return;
                      } else {
                        try {
                          context.read<AuthBloc>().add(
                            RegisterEvent(
                              email: _emailController.text,
                              password: _passwordController.text,
                              fullName: _fullNameController.text,
                              gender: _gender,
                              birth: _selectedDate ?? DateTime.now(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Dữ liệu hợp lệ!")),
                          );
                          Navigator.pushReplacementNamed(context, '/otp');
                        } catch (e) {}
                      }
                    }
                  },
                  child: Text("Đăng ký"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue, // màu nền
                    foregroundColor: AppColors.textWhite, // màu chữ/icon
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // bo góc
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text("Đã có tài khoản? (Đăng nhập)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
