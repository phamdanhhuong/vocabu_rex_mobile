import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_calendar_v2_widget.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_app_bar.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_header.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_card.dart';
import 'streak_tokens.dart';

/// Giao diện màn hình "Streak" (Cá nhân).
class StreakView extends StatefulWidget {
  const StreakView({super.key});

  @override
  State<StreakView> createState() => _StreakViewState();
}

class _StreakViewState extends State<StreakView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WebPageWrapper(
      mobileScaffold: Material(
        child: Container(
          color: AppColors.snow, // Nền
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: const StreakAppBar(),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: const StreakHeader(),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 250),
                  child: _StreakCalendar(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// App bar implementation moved to `streak_app_bar.dart`.

// Header implementation moved to `streak_header.dart`.

// (Info card removed — its content was merged into the header so both
// share the same accent background and layout.)

// --- 4. LỊCH ---
class _StreakCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreakCard(
      title: 'Lịch',
      child: StreakCalendarV2Widget(initialMonth: DateTime.now()),
    );
  }
}

