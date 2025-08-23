import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/ui/blocs/register_bloc.dart';
import 'package:vocabu_rex_mobile/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/ui/pages/register_page.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';

void main() {
  init();
  final registerBloc = sl<RegisterBloc>();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider.value(value: registerBloc)],
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
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        '/register': (BuildContext context) => const RegisterPage(),
      },
    );
  }
}
