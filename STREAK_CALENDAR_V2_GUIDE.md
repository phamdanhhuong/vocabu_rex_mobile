# Hướng dẫn sử dụng Streak Calendar V2

## Tổng quan thay đổi

### 1. Entities & Models mới (Thuần Dart)

#### Domain Entities:
- `CalendarDayEntity` - Thông tin 1 ngày trong calendar
- `CalendarSummaryEntity` - Thống kê tổng hợp
- `GetStreakCalendarResponseEntity` - Response entity cho calendar API

#### Data Models:
- `CalendarDayModel` - Model với fromJson
- `CalendarSummaryModel` - Model với fromJson  
- `GetStreakCalendarResponseModel` - Model với fromJson

#### Enum DayStatus:
```dart
enum DayStatus {
  active,    // Ngày học
  frozen,    // Ngày dùng freeze
  missed,    // Ngày miss (mất streak)
  noStreak,  // Không có streak
  future,    // Ngày tương lai
}
```

### 2. Data Layer

#### StreakDataSource:
```dart
Future<GetStreakCalendarResponseModel> getStreakCalendar({
  required DateTime startDate,
  required DateTime endDate,
});
```

#### StreakService:
```dart
Future<Map<String, dynamic>> getStreakCalendar({
  required DateTime startDate,
  required DateTime endDate,
});
```

#### StreakRepository:
```dart
Future<GetStreakCalendarResponseEntity> getStreakCalendar({
  required DateTime startDate,
  required DateTime endDate,
});
```

### 3. Domain Layer

#### GetStreakCalendarUseCase:
```dart
Future<GetStreakCalendarResponseEntity> call({
  required DateTime startDate,
  required DateTime endDate,
});
```

### 4. Presentation Layer

#### Bloc Events:
```dart
class GetStreakCalendarEvent extends StreakEvent {
  final DateTime startDate;
  final DateTime endDate;
  GetStreakCalendarEvent({required this.startDate, required this.endDate});
}
```

#### Bloc States:
```dart
class StreakCalendarLoading extends StreakState {}
class StreakCalendarLoaded extends StreakState {
  final GetStreakCalendarResponseEntity calendarResponse;
}
```

#### Widgets:
- `StreakCalendarV2Widget` - Widget mới dùng Calendar API
- `StreakCalendarWidget` - Widget cũ (giữ lại cho backward compatibility)

## Cách sử dụng

### Option 1: Thay thế hoàn toàn (Recommended)

Thay `StreakCalendarWidget` bằng `StreakCalendarV2Widget`:

```dart
// Trước
StreakCalendarWidget(
  month: currentMonth,
  streakDays: streakDays,
  frozenDays: frozenDays,
  onMonthChanged: (month) => setState(() => currentMonth = month),
)

// Sau
StreakCalendarV2Widget(
  initialMonth: currentMonth,
)
```

### Option 2: Dùng cả 2 (Overview + Calendar)

```dart
class StreakScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overview section - dùng GetStreakHistory
            BlocBuilder<StreakBloc, StreakState>(
              builder: (context, state) {
                if (state is StreakLoaded) {
                  return Column(
                    children: [
                      CurrentStreakWidget(
                        currentStreak: state.response.currentStreak,
                      ),
                      StreakStatisticsWidget(
                        statistics: state.response.statistics,
                      ),
                    ],
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            
            Divider(),
            
            // Calendar section - dùng GetStreakCalendar
            StreakCalendarV2Widget(),
          ],
        ),
      ),
    );
  }
}
```

## Setup trong DI Container

Cần inject `GetStreakCalendarUseCase` vào Bloc:

```dart
// get_it setup hoặc provider setup
getIt.registerFactory(() => GetStreakCalendarUseCase(
  getIt<StreakRepository>(),
));

getIt.registerFactory(() => StreakBloc(
  getStreakHistoryUseCase: getIt<GetStreakHistoryUseCase>(),
  useStreakFreezeUseCase: getIt<UseStreakFreezeUseCase>(),
  getStreakCalendarUseCase: getIt<GetStreakCalendarUseCase>(), // Thêm dòng này
));
```

## API Endpoint cần thêm vào Backend

```typescript
// vocabu-rex-user-service
GET /api/v1/users/streak/calendar?startDate=2024-11-01&endDate=2024-11-30

Response:
{
  "data": {
    "userId": "user123",
    "startDate": "2024-11-01T00:00:00+07:00",
    "endDate": "2024-11-30T00:00:00+07:00",
    "days": [
      {
        "date": "2024-11-01T00:00:00+07:00",
        "status": "active",
        "streakCount": 1,
        "isStreakStart": true,
        "isStreakEnd": false,
        "freezeUsed": false
      },
      // ... more days
    ],
    "summary": {
      "totalDays": 30,
      "activeDays": 20,
      "frozenDays": 2,
      "missedDays": 3,
      "currentStreak": 5,
      "longestStreakInRange": 15
    },
    "success": true
  }
}
```

## Features của StreakCalendarV2Widget

### 1. Month Navigation
- Nút prev/next month
- Disable next nếu là tháng hiện tại
- Auto-fetch data khi đổi tháng

### 2. Calendar Grid
- 7 cột (S M T W T F S)
- Màu sắc theo status:
  - 🔥 Orange: Active (study day)
  - ❄️ Blue: Frozen
  - ❌ Red: Missed
  - ⚪ Gray: No streak
  - 🔒 Light gray: Future

### 3. Day Details
- Tap vào ngày → Hiện bottom sheet
- Hiển thị:
  - Status (active/frozen/missed)
  - Streak count vào ngày đó
  - Freeze used indicator
  - Streak start/end markers

### 4. Summary Statistics
- Study Days count
- Freezes used count
- Missed days count

## Migration Plan

### Phase 1: Backend Implementation ⏳
1. Implement `DailyActivity` table
2. Update `UpdateStreakUseCase` để log daily activity
3. Implement `GetStreakCalendarUseCase`
4. Add controller endpoint

### Phase 2: Flutter Integration ✅
1. ✅ Create entities & models
2. ✅ Update datasource & repository
3. ✅ Create usecase
4. ✅ Update Bloc
5. ✅ Create StreakCalendarV2Widget
6. ⏳ Update DI container
7. ⏳ Replace old widget

### Phase 3: Testing ⏳
1. Test API integration
2. Test month navigation
3. Test day detail display
4. Test error handling

## So sánh 2 widgets

| Feature | StreakCalendarWidget (Cũ) | StreakCalendarV2Widget (Mới) |
|---------|---------------------------|------------------------------|
| Data source | GetStreakHistory | GetStreakCalendar |
| Day info | Chỉ có streak/frozen | Full status (active/frozen/missed/no_streak) |
| Freeze tracking | List of frozen days | Per-day freeze indicator |
| Streak count | Không có | Hiện streak count từng ngày |
| Day detail | Không có | Bottom sheet với full info |
| Summary stats | Không có | Active/Frozen/Missed counts |
| Backend dependency | Existing API | Cần API mới |

## Lưu ý quan trọng

1. **Backend phải implement trước**: Widget mới cần API `/streak/calendar`

2. **Backward compatibility**: Widget cũ vẫn hoạt động bình thường cho đến khi backend ready

3. **Data accuracy**: Calendar API chỉ chính xác khi có `DailyActivity` tracking

4. **Performance**: Mỗi lần đổi tháng gọi 1 API call mới

5. **Caching**: Có thể thêm cache để giảm số lần gọi API

## Checklist hoàn thành

Backend:
- [ ] Run Prisma migration
- [ ] Implement DailyActivityRepository
- [ ] Update UpdateStreakUseCase
- [ ] Update UseStreakFreezeUseCase
- [ ] Implement GetStreakCalendarUseCase
- [ ] Add controller endpoint
- [ ] Test API

Flutter:
- [x] Create domain entities
- [x] Create data models
- [x] Update datasource
- [x] Update repository
- [x] Create usecase
- [x] Update Bloc events/states
- [x] Create StreakCalendarV2Widget
- [ ] Update DI container
- [ ] Replace old widget usage
- [ ] Test UI

## Kết luận

StreakCalendarV2Widget cung cấp **calendar visualization chi tiết như Duolingo**, với:
- ✅ Thông tin từng ngày cụ thể
- ✅ Phân biệt rõ study/freeze/missed days
- ✅ Streak count theo từng ngày
- ✅ Summary statistics
- ✅ Interactive day details

Kết hợp với `StreakHeaderWidget` (dùng GetStreakHistory) sẽ có được **complete streak experience**!
