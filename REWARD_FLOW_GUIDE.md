# Hệ thống Hiển thị Phần Thưởng Sau Bài Học

Hệ thống này cung cấp một flow hoàn chỉnh để hiển thị các phần thưởng và thành tựu sau khi người dùng hoàn thành bài học.

## Các Trang Hiển Thị (Theo Thứ Tự)

### 1. Trang Kết Quả Bài Học (`LessonResultPage`)
Hiển thị kết quả chi tiết của bài học:
- ✨ Badge hoàn hảo (nếu perfect) hoặc icon hoàn thành
- ⏱️ Thời gian hoàn thành
- 🌟 Kinh nghiệm nhận được (bao gồm bonus nếu perfect)
- 🎯 Độ chính xác
- ✅ Số câu đúng/tổng số câu
- 📚 Số từ vựng và ngữ pháp đã cập nhật

### 2. Trang Cập Nhật Streak (`StreakUpdatePage`)
Hiển thị khi streak được cập nhật:
- 🔥 Animation đếm từ streak cũ lên streak mới
- ⬆️ Hiển thị số ngày tăng (+X ngày)
- 💬 Thông điệp khích lệ dựa trên số ngày streak
- ⭐ Hiệu ứng đặc biệt nếu bài học hoàn hảo

### 3. Trang Nhận Đá Quý/Coin (`RewardCollectPage`)
Hiển thị phần thưởng vật chất:
- 💎 Đá quý (gems)
- 🪙 Coin
- 🌟 XP (nếu không có gems/coins)
- Có thể tùy chỉnh icon/hình ảnh

### 4. Trang Quest Hoàn Thành (`QuestCompletedPage`)
Hiển thị các quest đã hoàn thành:
- 🏆 Danh sách quest vừa hoàn thành
- ⚡ Nút claim nhanh cho từng quest
- 🎁 Hiển thị phần thưởng (XP + gems)
- 🚀 Nút "Nhận tất cả phần thưởng" để claim hàng loạt
- ✅ Trạng thái đã nhận phần thưởng

## Cách Sử Dụng

### Sử dụng Flow Hoàn Chỉnh (Khuyến Nghị)

```dart
import 'package:vocabu_rex_mobile/exercise/ui/coordinators/reward_flow_coordinator.dart';

// Sau khi submit bài học thành công
void _handleLessonComplete(SubmitResponseEntity response) async {
  final completed = await RewardFlowCoordinator.showRewardFlow(
    context: context,
    response: response,
    completionTime: Duration(minutes: 5, seconds: 30),
    streakData: {
      'previousStreak': 5,
      'newStreak': 6,
    },
    completedQuests: completedQuests, // List<UserQuestEntity>
  );
  
  if (completed) {
    // User đã xem hết tất cả các trang
    // Navigate về màn hình chính
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
```

### Sử dụng Từng Trang Riêng Lẻ

#### Hiển thị chỉ kết quả bài học
```dart
await RewardFlowCoordinator.showLessonResult(
  context: context,
  response: response,
  completionTime: completionTime,
);
```

#### Hiển thị chỉ streak update
```dart
await RewardFlowCoordinator.showStreakUpdate(
  context: context,
  previousStreak: 5,
  newStreak: 6,
  isPerfect: true,
);
```

#### Hiển thị chỉ một reward đơn lẻ
```dart
await RewardFlowCoordinator.showSingleRewardPage(
  context: context,
  amount: 50,
  label: 'ĐÁ QUÝ',
  imageAsset: 'assets/images/gem.png',
);
```

#### Hiển thị chỉ quest completed
```dart
await RewardFlowCoordinator.showQuestCompleted(
  context: context,
  completedQuests: completedQuests,
);
```

## Logic Hiển Thị

Flow sẽ tự động skip các trang không cần thiết:

1. **Lesson Result**: Luôn hiển thị
2. **Streak Update**: Chỉ hiển thị nếu:
   - `streakData` không null
   - `newStreak` > `previousStreak`
3. **Rewards**: Hiển thị theo thứ tự:
   - Gems (nếu có)
   - Coins (nếu có)
   - XP (nếu không có gems/coins nhưng có XP)
4. **Quest Completed**: Chỉ hiển thị nếu:
   - `completedQuests` không null và không rỗng
   - Có ít nhất 1 quest `canClaim` (status = COMPLETED và chưa claim)

## Tích Hợp với Quest Bloc

Trang `QuestCompletedPage` sử dụng `QuestBloc` để claim rewards. Đảm bảo bạn đã:

1. Thêm event `ClaimQuestRewardEvent` vào quest bloc:
```dart
class ClaimQuestRewardEvent extends QuestEvent {
  final String questId;
  const ClaimQuestRewardEvent({required this.questId});
}
```

2. Thêm state `QuestClaimed` và `QuestError`:
```dart
class QuestClaimed extends QuestState {
  final String questId;
  const QuestClaimed({required this.questId});
}

class QuestError extends QuestState {
  final String message;
  const QuestError({required this.message});
}
```

3. Xử lý event trong bloc:
```dart
on<ClaimQuestRewardEvent>((event, emit) async {
  try {
    await questRepository.claimQuest(event.questId);
    emit(QuestClaimed(questId: event.questId));
    // Reload quests
    add(LoadUserQuestsEvent());
  } catch (e) {
    emit(QuestError(message: e.toString()));
  }
});
```

## Customization

### Thay đổi màu sắc
Các màu được sử dụng từ `AppColors`:
- `AppColors.macaw` - Màu chính
- `AppColors.polar` - Background
- `AppColors.featherGreen` - Success/positive
- `AppColors.goldenRod` - Rewards/achievements
- `AppColors.alizarin` - Errors

### Thêm hình ảnh
```dart
RewardCollectPage(
  customAmount: 100,
  customLabel: 'ĐÁ QUÝ',
  imageAsset: 'assets/images/rewards/gem_pile.png', // Thêm asset path
);
```

### Custom animation duration
Sửa trong `StreakUpdatePage._initState()`:
```dart
_controller = AnimationController(
  duration: const Duration(milliseconds: 2000), // Tăng từ 1500ms
  vsync: this,
);
```

## Các File Liên Quan

```
lib/exercise/ui/
├── pages/
│   ├── lesson_result_page.dart           # Trang kết quả bài học
│   ├── streak_update_page.dart           # Trang cập nhật streak
│   ├── reward_collect_page.dart          # Trang nhận rewards
│   └── quest_completed_page.dart         # Trang quest hoàn thành
└── coordinators/
    └── reward_flow_coordinator.dart      # Coordinator điều phối flow
```

## Dependencies

Các package cần thiết đã có trong project:
- `flutter_bloc` - State management cho quest claiming
- Material Design widgets - UI components

## Testing

### Test flow hoàn chỉnh
```dart
// Mock data
final response = SubmitResponseEntity(...);
final streakData = {'previousStreak': 5, 'newStreak': 6};
final quests = [UserQuestEntity(...)];

// Run flow
final result = await RewardFlowCoordinator.showRewardFlow(
  context: context,
  response: response,
  completionTime: Duration(minutes: 3),
  streakData: streakData,
  completedQuests: quests,
);
```

### Test từng trang riêng
Tham khảo phần "Sử dụng Từng Trang Riêng Lẻ" ở trên.

## Notes

- Tất cả các trang sử dụng `fullscreenDialog: true` để có animation slide-up
- User có thể bấm nút "TIẾP TỤC" để chuyển sang trang tiếp theo
- Nếu user dismiss (swipe down/back), flow sẽ dừng lại
- Quest claiming là async và có loading indicator
- Có feedback (SnackBar) khi claim quest thành công/thất bại
