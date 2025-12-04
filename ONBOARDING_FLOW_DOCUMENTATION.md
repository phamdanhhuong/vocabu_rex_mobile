# Onboarding Flow Documentation

## Tổng quan
Onboarding flow hiện tại có **11 bước** (steps 0-10) để thu thập thông tin người dùng và đăng ký tài khoản.

## Workflow chi tiết

### Step 0: Language Selection (Chọn ngôn ngữ học)
- **Screen**: `LanguageSelectionScreen`
- **Dữ liệu thu thập**: `selectedLanguage` (String)
- **Options**: Tiếng Anh, Tiếng Hoa, Tiếng Ý, Tiếng Pháp, Tiếng Hàn, Tiếng Nhật
- **Validation**: Phải chọn 1 ngôn ngữ
- **Map to DB**: `targetLanguage` (mặc định: 'en')

### Step 1: Experience Level (Trình độ hiện tại)
- **Screen**: `ExperienceLevelScreen`
- **Dữ liệu thu thập**: `proficiencyLevel` (Enum)
- **Options**:
  - `beginner` → `BEGINNER`: Tôi mới học tiếng Anh
  - `elementary` → `ELEMENTARY`: Tôi biết một vài từ thông dụng
  - `intermediate` → `INTERMEDIATE`: Tôi có thể giao tiếp cơ bản
  - `upper_intermediate` → `UPPER_INTERMEDIATE`: Tôi có thể nói về nhiều chủ đề
  - `advanced` → `ADVANCED`: Tôi có thể đi sâu vào hầu hết các chủ đề
  - `proficient` → `PROFICIENT`: Tôi thành thạo tiếng Anh như người bản ngữ
- **Validation**: Phải chọn 1 level
- **Map to DB**: `proficiencyLevel` (Enum)

### Step 2: Learning Goals (Mục tiêu học tập)
- **Screen**: `LearningGoalsScreen` hoặc `GoalSelectionScreen`
- **Dữ liệu thu thập**: `learningGoals` (List<String>)
- **Options** (multi-select):
  - `connect` → `CONNECT`: Kết nối với mọi người
  - `travel` → `TRAVEL`: Chuẩn bị đi du lịch
  - `study` → `STUDY`: Hỗ trợ việc học tập
  - `entertainment` → `ENTERTAINMENT`: Giải trí
  - `career` → `CAREER`: Phát triển sự nghiệp
  - `hobby` → `HOBBY`: Tận dụng thời gian rảnh
- **Validation**: Phải chọn ít nhất 1 mục tiêu
- **Map to DB**: `learningGoals` (Array of Enum)

### Step 3: Daily Goal (Mục tiêu hàng ngày)
- **Screen**: `DailyGoalScreen`
- **Dữ liệu thu thập**: `dailyGoalMinutes` (Integer)
- **Options**:
  - `casual` → 5 phút/ngày (5 minutes)
  - `regular` → 10 phút/ngày (10 minutes)
  - `serious` → 15 phút/ngày (15 minutes)
  - `intense` → 20 phút/ngày (20 minutes)
- **Validation**: Phải chọn 1 mục tiêu
- **Map to DB**: `dailyGoalMinutes` (Integer, default: 15)

### Step 4: Learning Benefits (Lợi ích học tập)
- **Screen**: `LearningBenefitsScreen`
- **Mục đích**: Hiển thị thông tin, không thu thập dữ liệu
- **Nội dung**:
  - 💬 Tự tin giao tiếp
  - 📖 Xây dựng vốn từ
  - ⏰ Tạo thói quen học tập
- **Validation**: Luôn cho phép tiếp tục

### Step 5: Assessment (Đánh giá trình độ)
- **Screen**: `AssessmentScreen`
- **Dữ liệu thu thập**: `assessmentType` (String)
- **Options**:
  - `assessment`: Làm bài test đánh giá (5-10 phút)
  - `beginner`: Tôi là người mới bắt đầu
  - `skip`: Bỏ qua (qua skip button)
- **Validation**: Phải chọn 1 option
- **Map to DB**: Lưu trong onboardingData, không lưu trực tiếp vào User model

### Step 6: Profile Setup - Name (Nhập tên)
- **Screen**: `ProfileSetupScreen` (step: 0)
- **Dữ liệu thu thập**: `name` (String)
- **UI**: Input field với Duo character
- **Validation**: Không được để trống
- **Map to DB**: `fullName` (String)

### Step 7: Profile Setup - Email (Nhập email)
- **Screen**: `ProfileSetupScreen` (step: 1)
- **Dữ liệu thu thập**: `email` (String)
- **UI**: Input field với Duo character
- **Validation**: Không được để trống và phải đúng format email
- **Map to DB**: `email` (String, unique)

### Step 8: Profile Setup - Password (Nhập mật khẩu)
- **Screen**: `ProfileSetupScreen` (step: 2)
- **Dữ liệu thu thập**: `password` (String)
- **UI**: Password input field với show/hide toggle
- **Validation**: Tối thiểu 6 ký tự
- **Map to DB**: Hash password trước khi lưu
- **Action**: Khi nhấn "TẠO TÀI KHOẢN" → Gọi `RegisterEvent` với AuthBloc

### Step 9: Profile Setup - Date of Birth (Ngày sinh)
- **Screen**: `ProfileSetupScreen` (step: 3)
- **Dữ liệu thu thập**: `dateOfBirth` (DateTime)
- **UI**: Date picker
- **Validation**: Optional (có thể skip)
- **Map to DB**: `dateOfBirth` (DateTime, nullable)

### Step 10: Notification Permission (Quyền thông báo)
- **Screen**: `NotificationPermissionScreen`
- **Dữ liệu thu thập**: `notificationsEnabled` (Boolean)
- **Options**: Cho phép / Không cho phép
- **Map to DB**: Cấu hình reminder settings
- **Action**: Sau khi chọn → Navigate to OTP Verification

## Flow điều hướng

```
Step 0 (Language)
  ↓ [TIẾP TỤC]
Step 1 (Experience Level)
  ↓ [TIẾP TỤC]
Step 2 (Learning Goals)
  ↓ [TIẾP TỤC]
Step 3 (Daily Goal)
  ↓ [TIẾP TỤC]
Step 4 (Learning Benefits)
  ↓ [TÔI QUYẾT TÂM]
Step 5 (Assessment)
  ↓ [TIẾP TỤC / SKIP]
Step 6 (Name)
  ↓ [TIẾP TỤC]
Step 7 (Email)
  ↓ [TIẾP TỤC]
Step 8 (Password)
  ↓ [TẠO TÀI KHOẢN] → Call AuthBloc.RegisterEvent
  → On success: Navigate to OTP Verification
  → On failure: Show error message
Step 9 (Date of Birth) - KHÔNG BAO GIỜ ĐẾN ĐÂY (vì step 8 đã register)
Step 10 (Notification) - KHÔNG BAO GIỜ ĐẾN ĐÂY
```

## Dữ liệu cần thiết cho đăng ký

### Bắt buộc (Required):
1. **email** (String) - Step 7
2. **password** (String) - Step 8
3. **fullName** (String) - Step 6

### Tùy chọn nhưng có giá trị mặc định:
4. **nativeLanguage** (String) - Default: 'vi'
5. **targetLanguage** (String) - Default: 'en' (từ Step 0)
6. **proficiencyLevel** (Enum) - Từ Step 1 hoặc default: 'BEGINNER'
7. **learningGoals** (Array) - Từ Step 2 hoặc default: ['PERSONAL']
8. **dailyGoalMinutes** (Integer) - Từ Step 3 hoặc default: 15
9. **studyReminder** (String) - Default: 'DAILY'
10. **reminderTime** (String) - Default: '09:00'
11. **timezone** (String) - Default: 'Asia/Ho_Chi_Minh'
12. **gender** (String) - Default: 'PREFER_NOT_TO_SAY'
13. **profilePictureUrl** (String) - Default avatar URL
14. **isEmailVerified** (Boolean) - Default: false
15. **isActive** (Boolean) - Default: true

### Tùy chọn (Optional):
16. **dateOfBirth** (DateTime) - Step 9 (không bao giờ đến)
17. **notificationsEnabled** (Boolean) - Step 10 (không bao giờ đến)

## Vấn đề hiện tại (Over-complex)

### 1. **Quá nhiều bước không cần thiết cho registration**
- Step 0-5: Thu thập thông tin về học tập (6 bước)
- Step 6-8: Thông tin đăng ký cơ bản (3 bước)
- Step 9-10: Không bao giờ được thực hiện

### 2. **Logic phức tạp**
- OnboardingController có quá nhiều state variables
- Mapping phức tạp giữa UI values và DB enum values
- Nhiều screens chỉ để hiển thị thông tin (Step 4)

### 3. **UX không tối ưu**
- User phải trải qua 8 bước chỉ để đăng ký
- Step 9-10 bị bỏ qua nhưng vẫn tồn tại trong code
- Assessment screen (Step 5) không rõ ràng mục đích

### 4. **Duplicate components**
- Có cả `LearningGoalsScreen` và `GoalSelectionScreen`
- Nhiều component tiles giống nhau (goal_option_tile.dart vs components/goal_option_tile.dart)

## Thông tin cần giữ lại cho refactoring

### Màn hình tối thiểu cần thiết:
1. **Welcome/Intro Screen** - Giới thiệu app
2. **Registration Screen** - Email, Password, Name (1 form duy nhất)
3. **OTP Verification** - Xác thực email

### Dữ liệu bắt buộc:
- Email (unique, validated)
- Password (min 6 chars)
- Full Name (not empty)

### Dữ liệu tùy chọn có thể thu thập sau:
- Learning preferences (goals, daily target, etc.)
- Profile information (date of birth, avatar)
- Assessment/placement test

### Components có thể tái sử dụng:
- `DuoCharacter` - Mascot character
- `SpeechBubble` - Speech bubble component
- Input fields styling
- Continue button styling

## Đề xuất refactoring

### Cách tiếp cận 1: Simplified Onboarding
```
Screen 1: Welcome + Language Selection
Screen 2: Registration Form (Name, Email, Password)
Screen 3: OTP Verification
→ Navigate to Main App
→ Show optional profile setup later
```

### Cách tiếp cận 2: Progressive Disclosure
```
Screen 1: Quick Registration (Email + Password)
Screen 2: OTP Verification
Screen 3: Basic Profile (Name)
Screen 4: Welcome to app
→ Collect learning preferences during first use
```

### Cách tiếp cận 3: Social-first
```
Screen 1: Continue with Google/Facebook OR Email
Screen 2: If email → Name + Password
Screen 3: OTP Verification (if needed)
Screen 4: Quick profile completion
```

## Component Inventory

### Screens (sắp xếp theo thứ tự sử dụng):
1. `LanguageSelectionScreen` - Step 0
2. `ExperienceLevelScreen` - Step 1
3. `LearningGoalsScreen` / `GoalSelectionScreen` - Step 2 (duplicate)
4. `DailyGoalScreen` - Step 3
5. `LearningBenefitsScreen` - Step 4
6. `AssessmentScreen` - Step 5
7. `ProfileSetupScreen` - Steps 6, 7, 8, 9 (multi-purpose)
8. `NotificationPermissionScreen` - Step 10
9. `LevelSelectionScreen` - KHÔNG SỬ DỤNG

### Components:
- `DuoCharacter` - Character display
- `DuoWithSpeech` / `DuoCharacterWithSpeech` - Character + speech bubble
- `SpeechBubble` - Speech bubble only
- `ProfileInputField` - Input field component
- `SkipButton` - Skip button
- `AssessmentOptionTile` - Assessment options
- `BenefitItem` - Benefit list item
- `GoalTile` / `GoalOptionTile` - Goal selection tiles (duplicate)
- `LevelOptionTile` - Level selection tile

### Supporting widgets:
- `OnboardingContinueButton` - Continue button
- `OnboardingHeader` - Header with progress bar
- `LanguageOptionTile` - Language selection tile

### Controller:
- `OnboardingController` - State management (425 lines!)

## Database Schema Reference

```prisma
model User {
  id                  String       @id @default(uuid())
  email               String       @unique
  fullName            String
  password            String       // Hashed
  profilePictureUrl   String       @default("default-avatar-url")
  dateOfBirth         DateTime?
  gender              Gender       @default(PREFER_NOT_TO_SAY)
  nativeLanguage      String       @default("vi")
  targetLanguage      String       @default("en")
  proficiencyLevel    ProficiencyLevel @default(BEGINNER)
  learningGoals       LearningGoal[]
  dailyGoalMinutes    Int          @default(15)
  studyReminder       StudyReminder @default(DAILY)
  reminderTime        String?      @default("09:00")
  timezone            String       @default("Asia/Ho_Chi_Minh")
  isEmailVerified     Boolean      @default(false)
  isActive            Boolean      @default(true)
  createdAt           DateTime     @default(now())
  updatedAt           DateTime     @updatedAt
}

enum Gender {
  MALE
  FEMALE
  OTHER
  PREFER_NOT_TO_SAY
}

enum ProficiencyLevel {
  BEGINNER
  ELEMENTARY
  INTERMEDIATE
  UPPER_INTERMEDIATE
  ADVANCED
  PROFICIENT
}

enum LearningGoal {
  CONNECT
  TRAVEL
  STUDY
  ENTERTAINMENT
  CAREER
  HOBBY
  PERSONAL
}

enum StudyReminder {
  DAILY
  WEEKDAYS
  WEEKENDS
  CUSTOM
  NONE
}
```

## Theme Colors Reference

```dart
// From AppColors theme
- AppColors.featherGreen - Primary action color
- AppColors.snow - White/text color
- AppColors.wolf - Gray color
- Background: Color(0xFF2B3A4A) - Dark blue
```

## Next Steps for Refactoring

1. ✅ **Document current flow** (DONE)
2. **Choose refactoring approach** (cần quyết định)
3. **Create simplified screens using theme colors**
4. **Remove unused screens and components**
5. **Simplify OnboardingController**
6. **Update navigation flow**
7. **Test registration flow**
8. **Clean up unused files**

---

**Generated**: 2025-12-04
**Purpose**: Document onboarding flow trước khi refactor
