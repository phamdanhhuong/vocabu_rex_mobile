import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/wigets/custom_text_field.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1612),
          body: Stack(
            children: [
              if (state is OtpState)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: AssetImage("assets/logo.png"), height: 100),
                      Text(
                        "OTP",
                        style: TextStyle(
                          color: Colors.lightGreen,
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
                                controller: _otpController,
                                hintText: "OTP",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'OTP is required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              try {
                                context.read<AuthBloc>().add(
                                  VerifyOtpEvent(
                                    userId: state.userId,
                                    otp: _otpController.text,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Dữ liệu hợp lệ!"),
                                  ),
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              } catch (e) {}
                            }
                          },
                          child: Text("Xác nhận"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // màu nền
                            foregroundColor: Colors.white, // màu chữ/icon
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // bo góc
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (state is AuthLoading)
                Container(
                  color: Colors.black54, // nền mờ
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.lightGreen,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
