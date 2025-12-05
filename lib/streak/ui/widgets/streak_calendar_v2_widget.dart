import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/calendar_day_entity.dart';
import 'package:vocabu_rex_mobile/streak/data/models/calendar_day_model.dart' show DayStatus;
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_event.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'streak_tokens.dart';

class StreakCalendarV2Widget extends StatefulWidget {
  final DateTime? initialMonth;

  const StreakCalendarV2Widget({
    Key? key,
    this.initialMonth,
  }) : super(key: key);

  @override
  State<StreakCalendarV2Widget> createState() => _StreakCalendarV2WidgetState();
}

class _StreakCalendarV2WidgetState extends State<StreakCalendarV2Widget> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.initialMonth ?? DateTime.now();
    _loadCalendarData();
  }

  void _loadCalendarData() {
    final startDate = DateTime(currentMonth.year, currentMonth.month, 1);
    final endDate = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    context.read<StreakBloc>().add(
      GetStreakCalendarEvent(startDate: startDate, endDate: endDate),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + delta, 1);
    });
    _loadCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 8),
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          'THÁNG ${currentMonth.month} NĂM ${currentMonth.year}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: kCalendarMonthFontSize,
            color: AppColors.wolf,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: _canGoNext() ? () => _changeMonth(1) : null,
        ),
      ],
    );
  }

  bool _canGoNext() {
    final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    return nextMonth.isBefore(DateTime.now()) || nextMonth.month == DateTime.now().month;
  }

  Widget _buildWeekdayHeaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
        return Expanded(
          child: Center(
            child: Text(
              days[i],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.wolf.withOpacity(0.9),
                fontSize: kCalendarWeekdayFontSize,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarGrid() {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakCalendarLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is StreakCalendarLoaded) {
          return _buildCalendarDays(state.calendarResponse.days);
        }

        if (state is StreakError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildCalendarDays(List<CalendarDayEntity> days) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final weekdayOffset = firstDayOfMonth.weekday % 7;
    final daysInMonth = days.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: kCalendarGridSpacing,
        crossAxisSpacing: kCalendarGridSpacing,
        childAspectRatio: kCalendarChildAspectRatio,
      ),
      itemCount: weekdayOffset + daysInMonth,
      itemBuilder: (context, index) {
        if (index < weekdayOffset) {
          return SizedBox.shrink();
        }
        final dayIndex = index - weekdayOffset;
        if (dayIndex >= days.length) {
          return SizedBox.shrink();
        }
        return _buildDayCell(days[dayIndex]);
      },
    );
  }

  Widget _buildDayCell(CalendarDayEntity day) {
    final config = _getDayConfig(day);
    
    return GestureDetector(
      onTap: () => _showDayDetail(day),
      child: Container(
        decoration: BoxDecoration(
          color: config.backgroundColor,
          shape: BoxShape.circle,
          border: day.isStreakStart || day.isStreakEnd
              ? Border.all(color: AppColors.fox, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day number
                  Text(
                    '${day.date.day}',
                    style: TextStyle(
                      color: config.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: kCalendarDayFontSize,
                    ),
                  ),
                  // Icon
                  if (config.icon != null)
                    Icon(
                      config.icon,
                      size: 14,
                      color: config.iconColor,
                    ),
                ],
              ),
            ),
            // Freeze indicator
            if (day.freezeUsed)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.ac_unit,
                  size: 10,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  DayConfig _getDayConfig(CalendarDayEntity day) {
    switch (day.status) {
      case DayStatus.active:
        return DayConfig(
          backgroundColor: AppColors.fox,
          textColor: Colors.white,
          icon: Icons.local_fire_department,
          iconColor: Colors.white,
        );
      
      case DayStatus.frozen:
        return DayConfig(
          backgroundColor: AppColors.macaw,
          textColor: Colors.white,
          icon: Icons.ac_unit,
          iconColor: Colors.white,
        );
      
      case DayStatus.missed:
        return DayConfig(
          backgroundColor: Colors.red[100]!,
          textColor: Colors.red[900]!,
          icon: Icons.close,
          iconColor: Colors.red[700]!,
        );
      
      case DayStatus.noStreak:
        return DayConfig(
          backgroundColor: Colors.transparent,
          textColor: AppColors.wolf.withOpacity(0.5),
          icon: null,
          iconColor: Colors.grey,
        );
      
      case DayStatus.future:
      default:
        return DayConfig(
          backgroundColor: Colors.transparent,
          textColor: AppColors.wolf.withOpacity(0.3),
          icon: null,
          iconColor: Colors.grey[300]!,
        );
    }
  }

  void _showDayDetail(CalendarDayEntity day) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DayDetailSheet(day: day),
    );
  }

  Widget _buildSummary() {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakCalendarLoaded) {
          final summary = state.calendarResponse.summary;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    '${summary.activeDays}',
                    'Study Days',
                    Icons.local_fire_department,
                    AppColors.fox,
                  ),
                  _buildStat(
                    '${summary.frozenDays}',
                    'Freezes',
                    Icons.ac_unit,
                    AppColors.macaw,
                  ),
                  _buildStat(
                    '${summary.missedDays}',
                    'Missed',
                    Icons.close,
                    Colors.red,
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class DayConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Color iconColor;

  DayConfig({
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.iconColor,
  });
}

class _DayDetailSheet extends StatelessWidget {
  final CalendarDayEntity day;

  const _DayDetailSheet({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Center(
            child: Text(
              _formatDate(day.date),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Status
          _buildStatusCard(),
          SizedBox(height: 12),
          
          // Streak info
          if (day.streakCount > 0)
            ListTile(
              leading: Icon(Icons.timeline, color: AppColors.fox),
              title: Text('Streak on this day'),
              trailing: Text(
                '${day.streakCount} days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          
          // Special markers
          if (day.isStreakStart)
            Chip(
              avatar: Icon(Icons.play_arrow, size: 16, color: Colors.green),
              label: Text('Streak Started'),
              backgroundColor: Colors.green[100],
            ),
          if (day.isStreakEnd && day.status != DayStatus.active)
            Chip(
              avatar: Icon(Icons.stop, size: 16, color: Colors.red),
              label: Text('Streak Ended'),
              backgroundColor: Colors.red[100],
            ),
          if (day.freezeUsed)
            Chip(
              avatar: Icon(Icons.ac_unit, size: 16, color: Colors.blue),
              label: Text('Freeze Used'),
              backgroundColor: Colors.blue[100],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final config = _getStatusConfig();
    
    return Card(
      color: config['color'],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(config['icon'], size: 40, color: Colors.white),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    config['description'] as String,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (day.status) {
      case DayStatus.active:
        return {
          'icon': Icons.local_fire_department,
          'color': AppColors.fox,
          'title': 'Study Day',
          'description': 'You studied on this day!',
        };
      case DayStatus.frozen:
        return {
          'icon': Icons.ac_unit,
          'color': AppColors.macaw,
          'title': 'Freeze Day',
          'description': 'Streak protected by freeze',
        };
      case DayStatus.missed:
        return {
          'icon': Icons.close,
          'color': Colors.red,
          'title': 'Missed Day',
          'description': 'Streak was lost',
        };
      case DayStatus.noStreak:
        return {
          'icon': Icons.circle_outlined,
          'color': Colors.grey,
          'title': 'No Active Streak',
          'description': 'No streak on this day',
        };
      case DayStatus.future:
      default:
        return {
          'icon': Icons.help_outline,
          'color': Colors.grey,
          'title': 'Future Date',
          'description': '',
        };
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
