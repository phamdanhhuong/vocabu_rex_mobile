# Achievement Module

Module quản lý hệ thống thành tích (Achievements) trong VocabuRex Mobile, được thiết kế theo Clean Architecture pattern.

## 📁 Cấu trúc

```
achievement/
├── data/
│   ├── datasources/          # Nguồn dữ liệu
│   │   ├── achievement_datasource.dart
│   │   └── achievement_datasource_impl.dart
│   ├── models/               # Data models
│   │   └── achievement_model.dart
│   ├── repositories/         # Repository implementations
│   │   └── achievement_repository_impl.dart
│   └── service/              # API services
│       └── achievement_service.dart
├── domain/
│   ├── entities/             # Domain entities
│   │   └── achievement_entity.dart
│   ├── repositories/         # Repository interfaces
│   │   └── achievement_repository.dart
│   └── usecases/             # Business logic use cases
│       ├── get_achievements_usecase.dart
│       ├── get_achievements_by_category_usecase.dart
│       └── get_recent_achievements_usecase.dart
├── ui/
│   ├── blocs/                # BLoC state management
│   │   └── achievement_bloc.dart
│   ├── pages/                # Full screen pages
│   └── widgets/              # Reusable widgets
│       ├── achievement_record_card.dart
│       ├── achievement_tile.dart
│       ├── achievement_detail_dialog.dart
│       └── all_achievements_view.dart
└── achievement.dart          # Barrel file for exports
```

## 🚀 Features

### Backend Integration
- ✅ Lấy danh sách achievements từ API
- ✅ Hỗ trợ filter theo trạng thái (unlocked/all)
- ✅ Phân loại theo category (streak, lessons, xp, social)
- ✅ Theo dõi tiến độ và tự động unlock
- ✅ Hệ thống thưởng (XP và Gems)

### UI Components
- **AchievementRecordCard**: Card hiển thị achievement đã mở khóa gần đây
- **AchievementTile**: Tile hiển thị achievement trong grid
- **AchievementDetailDialog**: Dialog chi tiết achievement
- **AllAchievementsView**: Màn hình đầy đủ hiển thị tất cả achievements

### State Management
- Sử dụng BLoC pattern
- Hỗ trợ loading, error, và success states
- Real-time filtering và statistics

## 📊 Achievement Categories

- **🔥 Streak**: Thành tích liên quan đến streak (chuỗi ngày học)
- **📚 Lessons**: Thành tích hoàn thành bài học
- **⭐ XP**: Thành tích kinh nghiệm (milestones)
- **👥 Social**: Thành tích tương tác xã hội

## 🎯 Tier System

1. **Tier 1**: Bronze - Cấp độ cơ bản
2. **Tier 2**: Silver - Cấp độ trung bình
3. **Tier 3**: Gold - Cấp độ cao
4. **Tier 4**: Platinum - Cấp độ chuyên gia
5. **Tier 5**: Diamond - Cấp độ master

## 💻 Usage

### Import Module

```dart
import 'package:vocabu_rex_mobile/achievement/achievement.dart';
```

### Sử dụng trong Navigation

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AllAchievementsView(),
  ),
);
```

### Sử dụng BLoC trong Custom Widget

```dart
// Initialize dependencies
final achievementService = AchievementService();
final achievementDataSource = AchievementDataSourceImpl(achievementService);
final achievementRepository = AchievementRepositoryImpl(achievementDataSource);

final getAchievementsUsecase = GetAchievementsUsecase(achievementRepository);
final getAchievementsByCategoryUsecase = GetAchievementsByCategoryUsecase(achievementRepository);
final getRecentAchievementsUsecase = GetRecentAchievementsUsecase(achievementRepository);

BlocProvider(
  create: (context) => AchievementBloc(
    getAchievementsUsecase: getAchievementsUsecase,
    getAchievementsByCategoryUsecase: getAchievementsByCategoryUsecase,
    getRecentAchievementsUsecase: getRecentAchievementsUsecase,
  )..add(LoadAchievementsByCategoryEvent()),
  child: YourWidget(),
);
```

### Listen to BLoC State

```dart
BlocBuilder<AchievementBloc, AchievementState>(
  builder: (context, state) {
    if (state is AchievementLoading) {
      return CircularProgressIndicator();
    }
    
    if (state is AchievementError) {
      return Text('Error: ${state.message}');
    }
    
    if (state is AchievementLoaded) {
      return ListView.builder(
        itemCount: state.achievements.length,
        itemBuilder: (context, index) {
          return AchievementTile(
            achievement: state.achievements[index],
          );
        },
      );
    }
    
    return SizedBox.shrink();
  },
);
```

## 🎨 UI Screenshots Features

1. **Statistics Section**: Hiển thị tổng quan (tổng số, đã mở, đang làm, XP/Gems earned)
2. **Recent Achievements**: Danh sách cuộn ngang các achievement mới mở khóa
3. **Achievements by Category**: Grid 3 cột phân theo category
4. **Filter Toggle**: Nút filter hiển thị tất cả hoặc chỉ đã mở khóa
5. **Achievement Detail**: Dialog chi tiết với progress bar, rewards, tier info

## 🔄 State Flow

```
User Action
    ↓
Event (LoadAchievementsByCategoryEvent)
    ↓
BLoC processes event
    ↓
UseCase executes
    ↓
Repository fetches data
    ↓
DataSource calls API
    ↓
Model transforms to Entity
    ↓
State updated (AchievementLoaded)
    ↓
UI rebuilds
```

## 📝 Clean Architecture Layers

### Domain Layer (Business Logic)
- **Entities**: Pure Dart objects với business logic
- **Repositories**: Abstract interfaces
- **UseCases**: Single responsibility business operations

### Data Layer (Data Management)
- **Models**: Data transfer objects với JSON serialization
- **DataSources**: API communication
- **Repositories**: Implementation của domain repositories

### UI Layer (Presentation)
- **BLoC**: State management
- **Widgets**: Reusable UI components
- **Pages**: Full screen views

## 🔗 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  dio: # For API calls
  intl: # For date formatting
```

## 🚦 API Endpoints

### GET `/api/v1/users/achievements`
Lấy tất cả achievements của user

**Query Parameters:**
- `unlocked`: `true` để chỉ lấy achievements đã mở khóa (optional)

**Response:**
```json
{
  "success": true,
  "message": "User achievements retrieved successfully",
  "data": [
    {
      "id": "uuid",
      "userId": "user-id",
      "achievementId": "achievement-id",
      "progress": 7,
      "isUnlocked": true,
      "unlockedAt": "2025-10-29T...",
      "achievement": {
        "id": "achievement-id",
        "key": "streak_7",
        "name": "7 Day Streak",
        "description": "Maintain a 7 day learning streak",
        "iconUrl": "...",
        "badgeUrl": "...",
        "category": "streak",
        "tier": 1,
        "requirement": 7,
        "rewardXp": 100,
        "rewardGems": 10
      }
    }
  ]
}
```

## 🎯 Future Enhancements

- [ ] Local caching với Hive/SharedPreferences
- [ ] Push notifications khi unlock achievement
- [ ] Animation khi unlock achievement
- [x] Share achievement lên social media
- [ ] Achievement search và sort
- [ ] Custom achievement badges upload

## 🤝 Contributing

Khi thêm tính năng mới:
1. Tuân thủ Clean Architecture pattern
2. Tạo unit tests cho use cases
3. Update README với examples
4. Follow Dart/Flutter style guide

## 📄 License

VocabuRex Internal Module
