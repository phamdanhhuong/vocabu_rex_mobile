import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/intro.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/login_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/register_page.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';

void main() {
  init();
  final authBloc = sl<AuthBloc>();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider.value(value: authBloc)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocabuRex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F1F1F)),
      ),
      home: const Intro(),
      routes: <String, WidgetBuilder>{
        '/intro': (BuildContext context) => const Intro(),
        '/home': (BuildContext context) => const HomePage(),
        '/register': (BuildContext context) => const RegisterPage(),
        '/login': (BuildContext context) => const LoginPage(),
      },
    );
  }
}
