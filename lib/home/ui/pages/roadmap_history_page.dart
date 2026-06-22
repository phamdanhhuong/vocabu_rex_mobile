import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/home_injection.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_roadmap_history_usecase.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class RoadmapHistoryPage extends StatefulWidget {
  const RoadmapHistoryPage({super.key});

  @override
  State<RoadmapHistoryPage> createState() => _RoadmapHistoryPageState();
}

class _RoadmapHistoryPageState extends State<RoadmapHistoryPage> {
  late Future<List<UserRoadmapEntity>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = sl<GetUserRoadmapHistoryUsecase>().call();
  }

  void _switchRoadmap(String roadmapId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi Lộ Trình?'),
        content: const Text('Bạn có chắc chắn muốn chuyển sang lộ trình này? Tiến độ học của kỹ năng đầu tiên trong lộ trình này sẽ bị đặt lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<HomeBloc>().add(SwitchRoadmapEvent(roadmapId));
              Navigator.of(context).pop(); // Quay lại trang trước
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.bodyText;
    final bgColor = isDark ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Lịch Sử Lộ Trình', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: FutureBuilder<List<UserRoadmapEntity>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}', style: TextStyle(color: textColor)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Chưa có lịch sử lộ trình nào.', style: TextStyle(color: textColor)));
          }

          final roadmaps = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: roadmaps.length,
            itemBuilder: (context, index) {
              final roadmap = roadmaps[index];
              final isCurrent = roadmap.status == 'IN_PROGRESS';

              return Card(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isCurrent ? AppColors.macaw : Colors.transparent,
                    width: 2,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              roadmap.roadmap.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.macaw.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ĐANG HỌC',
                                style: TextStyle(
                                  color: AppColors.macaw,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        roadmap.roadmap.description ?? 'Không có mô tả',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trạng thái: ${roadmap.status}',
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                          if (!isCurrent)
                            ElevatedButton(
                              onPressed: () => _switchRoadmap(roadmap.roadmapId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.macaw,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Học lại', style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
