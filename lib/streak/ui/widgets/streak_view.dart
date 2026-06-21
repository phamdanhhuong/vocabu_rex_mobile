import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/confetti_overlay.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        ConfettiOverlay.show(
          context,
          Offset(size.width / 2, size.height - 100), // Fire from bottom
          ReactionType.fire,
        );
      }
    });
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
                const StreakAppBar(),
                const StreakHeader(),
                _StreakCalendar(),
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

