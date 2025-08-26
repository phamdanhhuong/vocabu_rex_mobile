import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/intro.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/login_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/register_page.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dependency injection
  init();

  // Khôi phục token nếu có
  final hasToken = await TokenManager.hasValidToken();
  if (hasToken) {
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      // Token sẽ được set trong TokenManager.getAccessToken()
      // AuthInterceptor sẽ tự động sử dụng token này
    }
  }

  final authBloc = sl<AuthBloc>();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider.value(value: authBloc)],
      child: MyApp(hasToken: hasToken),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasToken;

  const MyApp({super.key, this.hasToken = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocabuRex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F1F1F)),
      ),
      home: hasToken ? const HomePage() : const Intro(),
      routes: <String, WidgetBuilder>{
        '/intro': (BuildContext context) => const Intro(),
        '/home': (BuildContext context) => const HomePage(),
        '/register': (BuildContext context) => const RegisterPage(),
        '/login': (BuildContext context) => const LoginPage(),
      },
    );
  }
}
