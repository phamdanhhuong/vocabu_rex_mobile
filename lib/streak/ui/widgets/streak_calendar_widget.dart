// import 'package:flutter/material.dart';
// import 'package:vocabu_rex_mobile/theme/colors.dart';
// import 'streak_tokens.dart';

// class StreakCalendarWidget extends StatelessWidget {
//   final DateTime month;
//   final List<DateTime> streakDays;
//   final List<DateTime> frozenDays;
//   final Function(DateTime)? onMonthChanged;
//   final DateTime? selectedDay;
//   final Function(DateTime)? onDaySelected;

//   const StreakCalendarWidget({
//     Key? key,
//     required this.month,
//     required this.streakDays,
//     required this.frozenDays,
//     this.onMonthChanged,
//     this.selectedDay,
//     this.onDaySelected,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final firstDayOfMonth = DateTime(month.year, month.month, 1);
//     final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
//     final daysInMonth = lastDayOfMonth.day;
//     final weekdayOffset = firstDayOfMonth.weekday % 7;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.chevron_left),
//                 onPressed: () {
//                   // compute previous month (handle year boundary)
//                   final prevMonth = DateTime(month.year, month.month - 1, 1);
//                   onMonthChanged?.call(prevMonth);
//                 },
//               ),
//                   Text(
//                     'THÁNG ${(month.month)} NĂM ${month.year}',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: kCalendarMonthFontSize, color: AppColors.wolf),
//                   ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right),
//                 onPressed: () {
//                   // compute next month (handle year boundary)
//                   final nextMonth = DateTime(month.year, month.month + 1, 1);
//                   onMonthChanged?.call(nextMonth);
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: List.generate(7, (i) {
//               const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
//               return Expanded(
//                 child: Center(
//                   child: Text(
//                     days[i],
//                     style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.wolf.withOpacity(0.9), fontSize: kCalendarWeekdayFontSize),
//                   ),
//                 ),
//               );
//             }),
//           ),
//           const SizedBox(height: 8),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 7,
//               mainAxisSpacing: kCalendarGridSpacing,
//               crossAxisSpacing: kCalendarGridSpacing,
//               childAspectRatio: kCalendarChildAspectRatio,
//             ),
//             itemCount: weekdayOffset + daysInMonth,
//             itemBuilder: (context, index) {
//               if (index < weekdayOffset) {
//                 return SizedBox.shrink();
//               }
//               final day = index - weekdayOffset + 1;
//               final date = DateTime(month.year, month.month, day);
//               final isStreak = streakDays.any((d) => _isSameDay(d, date));
//               final isFrozen = frozenDays.any((d) => _isSameDay(d, date));
//               final isSelected = selectedDay != null && _isSameDay(selectedDay!, date);
//               Color bgColor = Colors.transparent;
//               if (isStreak) bgColor = AppColors.fox;
//               if (isFrozen) bgColor = AppColors.macaw;
//               if (isSelected) bgColor = AppColors.hare;
//               return GestureDetector(
//                 onTap: () => onDaySelected?.call(date),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: bgColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       '$day',
//                       style: TextStyle(
//                         color: bgColor == Colors.transparent ? AppColors.wolf.withOpacity(0.95) : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: kCalendarDayFontSize,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   String _monthName(int month) {
//     const names = [
//       'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return names[month - 1];
//   }

//   bool _isSameDay(DateTime a, DateTime b) {
//     // Ensure we compare local calendar dates. If a/b are UTC (parsed with offset)
//     // convert them to local first. Then compare Y/M/D only so midnight/time parts
//     // don't affect the comparison.
//     final da = a.isUtc ? a.toLocal() : a;
//     final db = b.isUtc ? b.toLocal() : b;
//     return da.year == db.year && da.month == db.month && da.day == db.day;
//   }
// }
