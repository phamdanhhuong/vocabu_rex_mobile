import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/wigets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
      backgroundColor: const Color(0xFF0F1612),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage("assets/logo.png"), height: 100),
              Text(
                "Register",
                style: TextStyle(
                  color: Colors.lightGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      hintText: "your-email@example.com",
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
                      hintText: "password",
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      try {
                        context.read<AuthBloc>().add(
                          RegisterEvent(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dữ liệu hợp lệ!")),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      } catch (e) {}
                    }
                  },
                  child: Text("Đăng ký"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // màu nền
                    foregroundColor: Colors.white, // màu chữ/icon
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
