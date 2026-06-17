import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'models/onboarding_models.dart';

/// Central configuration for all onboarding steps
class OnboardingConfig {
  // Character image URLs (có thể thay bằng assets sau)
  static const String duoNormalUrl =
      'https://d35aaqx5ub95lt.cloudfront.net/images/path/icons/owl.svg';
  static const String duoHappyUrl =
      'https://d35aaqx5ub95lt.cloudfront.net/images/path/icons/owl.svg';
  static const String duoBookUrl =
      'https://d35aaqx5ub95lt.cloudfront.net/images/path/icons/owl.svg';
  static const String duoGradUrl =
      'https://d35aaqx5ub95lt.cloudfront.net/images/path/icons/owl.svg';

  static final List<OnboardingStepConfig> steps = [
    // Step 0: Language Selection
    OnboardingStepConfig(
      id: 'language',
      character: CharacterConfig(
        imageUrl: duoNormalUrl,
        speechText: 'Bạn muốn học gì nhỉ?',
        position: CharacterPosition.left,
      ),
      options: [
        OptionConfig(value: 'en', emoji: '🇺🇸', title: 'Tiếng Anh'),
        OptionConfig(value: 'zh', emoji: '🇨🇳', title: 'Tiếng Hoa'),
        OptionConfig(value: 'it', emoji: '🇮🇹', title: 'Tiếng Ý'),
        OptionConfig(value: 'fr', emoji: '🇫🇷', title: 'Tiếng Pháp'),
        OptionConfig(value: 'ko', emoji: '🇰🇷', title: 'Tiếng Hàn'),
        OptionConfig(value: 'ja', emoji: '🇯🇵', title: 'Tiếng Nhật'),
      ],
      optionLayout: OptionTileLayout.emoji,
      validator: (value) => value != null,
      validationMessage: 'Vui lòng chọn ngôn ngữ!',
    ),

    // Step 1: Experience Level
    OnboardingStepConfig(
      id: 'proficiency_level',
      character: CharacterConfig(
        imageUrl: duoBookUrl,
        speechText: 'Trình độ tiếng Anh của bạn ở mức nào?',
        position: CharacterPosition.left,
      ),
      options: [
        OptionConfig(
          value: 'BEGINNER',
          title: 'Tôi mới học tiếng Anh',
          subtitle: 'Hoàn toàn mới bắt đầu',
          progressValue: 0.2,
        ),
        OptionConfig(
          value: 'ELEMENTARY',
          title: 'Tôi biết một vài từ thông dụng',
          subtitle: 'Hiểu được một số từ cơ bản',
          progressValue: 0.4,
        ),
        OptionConfig(
          value: 'INTERMEDIATE',
          title: 'Tôi có thể giao tiếp cơ bản',
          subtitle: 'Có thể tạo câu đơn giản',
          progressValue: 0.6,
        ),
        OptionConfig(
          value: 'UPPER_INTERMEDIATE',
          title: 'Tôi có thể nói về nhiều chủ đề',
          subtitle: 'Giao tiếp tự nhiên ở mức độ tốt',
          progressValue: 0.8,
        ),
        OptionConfig(
          value: 'ADVANCED',
          title: 'Tôi có thể đi sâu vào hầu hết các chủ đề',
          subtitle: 'Thành thạo trong hầu hết các tình huống',
          progressValue: 0.9,
        ),
        OptionConfig(
          value: 'PROFICIENT',
          title: 'Tôi thành thạo tiếng Anh như người bản ngữ',
          subtitle: 'Giao tiếp tự nhiên và chính xác',
          progressValue: 1.0,
        ),
      ],
      optionLayout: OptionTileLayout.icon,
      validator: (value) => value != null,
      validationMessage: 'Vui lòng chọn trình độ!',
    ),

    // Step 2: Learning Goals (multi-select)
    OnboardingStepConfig(
      id: 'learning_goals',
      character: CharacterConfig(
        imageUrl: duoGradUrl,
        speechText: 'Bạn muốn học tiếng Anh để làm gì?',
        position: CharacterPosition.left,
      ),
      options: [
        OptionConfig(
          value: 'CONNECT',
          icon: Icons.chat_bubble_outline,
          title: 'Giao tiếp hàng ngày',
          subtitle: 'Học từ vựng và cụm từ thông dụng',
        ),
        OptionConfig(
          value: 'CAREER',
          icon: Icons.business_center_outlined,
          title: 'Tiếng Anh công sở',
          subtitle: 'Phát triển kỹ năng giao tiếp trong công việc',
        ),
        OptionConfig(
          value: 'TRAVEL',
          icon: Icons.flight_takeoff_outlined,
          title: 'Du lịch',
          subtitle: 'Từ vựng và câu hỏi hữu ích khi đi du lịch',
        ),
        OptionConfig(
          value: 'STUDY',
          icon: Icons.school_outlined,
          title: 'Học thuật',
          subtitle: 'Chuẩn bị cho các kỳ thi và nghiên cứu',
        ),
        OptionConfig(
          value: 'ENTERTAINMENT',
          icon: Icons.movie_outlined,
          title: 'Giải trí',
          subtitle: 'Hiểu phim, nhạc và nội dung giải trí',
        ),
        OptionConfig(
          value: 'HOBBY',
          icon: Icons.favorite_border_outlined,
          title: 'Sở thích cá nhân',
          subtitle: 'Học để phục vụ đam mê và sở thích',
        ),
      ],
      optionLayout: OptionTileLayout.icon,
      allowMultiSelect: true,
      validator: (value) => value is List && value.isNotEmpty,
      validationMessage: 'Vui lòng chọn ít nhất 1 mục tiêu!',
    ),

    // Step 3: Daily Goal
    OnboardingStepConfig(
      id: 'daily_goal',
      character: CharacterConfig(
        imageUrl: duoHappyUrl,
        speechText: 'Chọn mục tiêu học tập hàng ngày của bạn!',
        position: CharacterPosition.left,
      ),
      options: [
        OptionConfig(
          value: 5,
          timeBadge: '5',
          title: '5 phút/ngày',
          subtitle: 'Thư giãn',
          badgeText: 'Thư giãn',
          badgeColor: AppColors.featherGreen,
        ),
        OptionConfig(
          value: 10,
          timeBadge: '10',
          title: '10 phút/ngày',
          subtitle: 'Đều đặn',
          badgeText: 'Đều đặn',
          badgeColor: AppColors.macaw,
        ),
        OptionConfig(
          value: 15,
          timeBadge: '15',
          title: '15 phút/ngày',
          subtitle: 'Nghiêm túc',
          badgeText: 'Nghiêm túc',
          badgeColor: AppColors.fox,
        ),
        OptionConfig(
          value: 20,
          timeBadge: '20',
          title: '20 phút/ngày',
          subtitle: 'Cường độ cao',
          badgeText: 'Cường độ cao',
          badgeColor: AppColors.cardinal,
        ),
      ],
      optionLayout: OptionTileLayout.timeBadge,
      validator: (value) => value != null,
      validationMessage: 'Vui lòng chọn mục tiêu!',
    ),

    // Step 4: Learning Benefits (info only)
    OnboardingStepConfig(
      id: 'benefits',
      character: CharacterConfig(
        imageUrl: duoBookUrl,
        speechText: 'Và đây là những gì bạn có thể đạt được sau 3 tháng!',
        position: CharacterPosition.left,
      ),
      options: [
        OptionConfig(
          value: 'continue',
          emoji: '💬',
          title: 'Tự tin giao tiếp',
          subtitle: 'Luyện nghe nói không áp lực',
        ),
        OptionConfig(
          value: 'continue',
          emoji: '📖',
          title: 'Xây dựng vốn từ',
          subtitle: 'Các từ và cụm từ phổ biến, thiết thực trong đời sống',
        ),
        OptionConfig(
          value: 'continue',
          emoji: '⏰',
          title: 'Tạo thói quen học tập',
          subtitle: 'Nhắc nhở thông minh, thử thách vui nhộn',
        ),
      ],
      optionLayout: OptionTileLayout.emoji,
      validator: (value) => true, // Always valid
    ),

    // Step 5: Assessment Choice
    OnboardingStepConfig(
      id: 'assessment',
      character: CharacterConfig(
        imageUrl: duoGradUrl,
        speechText: 'Tôi muốn đánh giá khả năng tiếng Anh hiện tại của bạn!',
        position: CharacterPosition.left,
        showSkip: true,
      ),
      options: [
        OptionConfig(
          value: 'assessment',
          emoji: '📝',
          title: 'Tôi muốn làm bài test đánh giá',
          subtitle:
              'Làm bài test ngắn để đánh giá chính xác trình độ (5-10 phút)',
        ),
        OptionConfig(
          value: 'beginner',
          emoji: '🌱',
          title: 'Tôi là người mới bắt đầu',
          subtitle:
              'Tôi chưa có kiến thức gì về tiếng Anh hoặc chỉ biết một chút cơ bản',
        ),
      ],
      optionLayout: OptionTileLayout.emoji,
      validator: (value) => true, // Optional
    ),

    // Step 6: Create Account
    OnboardingStepConfig(
      id: 'create_account',
      character: CharacterConfig(
        imageUrl: duoHappyUrl,
        speechText: 'Hãy tạo tài khoản để lưu trữ quá trình học của bạn nhé!',
        position: CharacterPosition.top,
      ),
      options: [], // Will be handled with custom form in UI
      optionLayout: OptionTileLayout.simple,
      validator: (value) => true, // Validation will be handled by the form
    ),
  ];

  /// Get step by ID
  static OnboardingStepConfig? getStepById(String id) {
    try {
      return steps.firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get step index by ID
  static int getStepIndex(String id) {
    return steps.indexWhere((step) => step.id == id);
  }

  /// Check if step requires custom form input
  static bool isTextInputStep(String id) {
    return id == 'create_account';
  }
}
