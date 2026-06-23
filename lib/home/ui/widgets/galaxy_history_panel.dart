import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/home_injection.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_roadmap_history_usecase.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'dart:math' as math;

class GalaxyHistoryPanel extends StatefulWidget {
  const GalaxyHistoryPanel({super.key});

  @override
  State<GalaxyHistoryPanel> createState() => _GalaxyHistoryPanelState();
}

class _GalaxyHistoryPanelState extends State<GalaxyHistoryPanel> {
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
        backgroundColor: Colors.black87,
        title: const Text('Dịch chuyển không gian?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn sắp nhảy bước nhảy alpha sang một Ngân Hà khác. Lịch trình tại Ngân Hà hiện tại sẽ tạm ngưng. Xác nhận khởi hành?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              context.read<HomeBloc>().add(SwitchRoadmapEvent(roadmapId));
              Navigator.of(context).pop(); // Close bottom sheet
              // Optional: Show loading or warp speed animation
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.macaw),
            child: const Text('Kích hoạt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // Deep space color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.bee.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.travel_explore, color: AppColors.bee),
                const SizedBox(width: 8),
                const Text(
                  'Kho Ngân Hà',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserRoadmapEntity>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.bee),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi không gian: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Vũ trụ của bạn đang trống rỗng.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final roadmaps = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: roadmaps.length,
                  itemBuilder: (context, index) {
                    final roadmap = roadmaps[index];
                    final isCurrent = roadmap.status == 'IN_PROGRESS';
                    
                    // Tạo màu sắc khác nhau cho từng galaxy để sinh động
                    final colors = [AppColors.macaw, AppColors.cardinal, AppColors.bee, AppColors.beetle];
                    final galaxyColor = colors[index % colors.length];

                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: isCurrent ? null : () => _switchRoadmap(roadmap.roadmapId),
                        child: Card(
                          color: isCurrent ? galaxyColor.withOpacity(0.1) : Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isCurrent ? galaxyColor : Colors.white12,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Fake Mini Galaxy
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: galaxyColor.withOpacity(0.5),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      ),
                                    ),
                                    Icon(
                                      Icons.blur_on,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    if (isCurrent)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.bee,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.star, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  roadmap.roadmap.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isCurrent ? 'ĐANG KHÁM PHÁ' : 'NGỦ ĐÔNG',
                                  style: TextStyle(
                                    color: isCurrent ? AppColors.bee : Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
