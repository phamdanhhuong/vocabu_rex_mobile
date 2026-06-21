import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/post_lesson_flow_page.dart';

/// Coordinator điều phối luồng kết thúc bài học mượt mà (Cinematic Flow)
class RewardFlowCoordinator {
  static Future<bool> showRewardFlow({
    required BuildContext context,
    required SubmitResponseEntity response,
    Duration? completionTime,
  }) async {
    
    // Gọi thẳng sang trang Flow duy nhất
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PostLessonFlowPage(
          response: response,
          completionTime: completionTime,
        ),
        fullscreenDialog: true,
      ),
    );

    return result ?? false;
  }
}
