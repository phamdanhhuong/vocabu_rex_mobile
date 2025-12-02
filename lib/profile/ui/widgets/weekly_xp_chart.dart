import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class WeeklyXPChart extends StatelessWidget {
  final List<XPHistoryEntry> myXpHistory;
  final List<XPHistoryEntry> theirXpHistory;
  final String myName;
  final String theirName;
  final int myTotalXp;
  final int theirTotalXp;

  const WeeklyXPChart({
    Key? key,
    required this.myXpHistory,
    required this.theirXpHistory,
    required this.myName,
    required this.theirName,
    required this.myTotalXp,
    required this.theirTotalXp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            children: [
              _buildLegendItem(myName, AppColors.macaw, myTotalXp),
              SizedBox(width: 24.w),
              _buildLegendItem(theirName, Colors.grey, theirTotalXp),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Chart
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.swan.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = _getWeekLabels();
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: [
                  // My XP line
                  LineChartBarData(
                    spots: _buildSpots(myXpHistory),
                    isCurved: true,
                    color: AppColors.macaw,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.macaw,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Their XP line
                  LineChartBarData(
                    spots: _buildSpots(theirXpHistory),
                    isCurved: true,
                    color: Colors.grey,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.grey,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color, int totalXp) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          name,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$totalXp KN',
          style: TextStyle(
            fontSize: 14.sp,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildSpots(List<XPHistoryEntry> history) {
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length && i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].xp.toDouble()));
    }
    return spots;
  }

  List<String> _getWeekLabels() {
    // Labels: T3, T4, T5, T6, T7, CN, T2 (Mon-Sun in Vietnamese)
    return ['T3', 'T4', 'T5', 'T6', 'T7', 'CN', 'T2'];
  }

  double _getMaxY() {
    double max = 0;
    for (var entry in myXpHistory) {
      if (entry.xp > max) max = entry.xp.toDouble();
    }
    for (var entry in theirXpHistory) {
      if (entry.xp > max) max = entry.xp.toDouble();
    }
    // Round up to nearest 10
    return ((max / 10).ceil() * 10).toDouble() + 10;
  }
}
