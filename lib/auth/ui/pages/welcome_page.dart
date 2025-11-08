import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/welcome_header.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/character_illustration.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/welcome_text.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/welcome_buttons.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Duolingo logo
            const WelcomeHeader(),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Character illustration area
                    const CharacterIllustration(),

                    // Welcome text
                    const WelcomeText(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            const WelcomeButtons(),
          ],
        ),
      ),
    );
  }
}