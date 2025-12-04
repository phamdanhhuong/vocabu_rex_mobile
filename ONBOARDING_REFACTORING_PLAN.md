# Onboarding Refactoring Plan

## Mục tiêu
**Giữ nguyên workflow và thông tin thu thập**, chỉ giảm số lượng file và đơn giản hóa code structure.

---

## Phân tích vấn đề hiện tại

### 1. **Duplicate Screens**
```
❌ learning_goals_screen.dart (106 dòng)
❌ goal_selection_screen.dart (128 dòng)
→ Cùng mục đích, chỉ khác UI nhỏ
```

### 2. **Duplicate Components**
```
❌ components/goal_tile.dart (94 dòng) - Dùng cho LearningGoalsScreen
❌ components/goal_option_tile.dart (121 dòng) - Dùng cho DailyGoalScreen
❌ goal_option_tile.dart (root level) - Duplicate
❌ level_option_tile.dart (root level) 
❌ components/level_option_tile.dart - Duplicate
→ Có thể merge thành 1 generic SelectionTile
```

### 3. **Unused/Redundant Files**
```
❌ level_selection_screen.dart - KHÔNG BAO GIỜ SỬ DỤNG (onboarding_page không gọi)
❌ duo_character_with_speech.dart - Đã có components/duo_with_speech.dart tốt hơn
❌ onboarding_header.dart - Logic đã inline trong onboarding_page
❌ onboarding_continue_button.dart - Logic đã inline trong onboarding_page
```

### 4. **Overly Complex Controller**
```
❌ onboarding_controller.dart - 425 dòng
- Quá nhiều mapping methods (70+ dòng chỉ để map enum)
- Duplicate getters (experienceLevel vs proficiencyLevel)
- Unnecessary complexity
```

---

## Kế hoạch Refactoring

### Phase 1: Consolidate Components (Giảm 10+ files → 3-4 files)

#### **1.1. Tạo Generic Selection Tile**
```dart
// lib/auth/ui/widgets/onboarding/shared/selection_tile.dart
class SelectionTile extends StatelessWidget {
  final Widget? leading;      // Icon hoặc Time display
  final String title;
  final String? subtitle;
  final Widget? trailing;     // Badge hoặc custom widget
  final bool isSelected;
  final VoidCallback onTap;
  
  // Support multiple layouts
  final SelectionTileLayout layout;
}

enum SelectionTileLayout {
  iconLeft,    // language, goals, level
  timeLeft,    // daily goal
  simple,      // assessment
}
```

**Loại bỏ:**
- ✅ `components/goal_tile.dart`
- ✅ `components/goal_option_tile.dart`
- ✅ `components/level_option_tile.dart`
- ✅ `components/assessment_option_tile.dart`
- ✅ `goal_option_tile.dart` (root)
- ✅ `level_option_tile.dart` (root)
- ✅ `language_option_tile.dart`

**Thay thế bằng:**
- 1 file: `shared/selection_tile.dart` (~150 dòng)

---

#### **1.2. Consolidate Duo Components**
```dart
// Giữ nguyên components/duo_with_speech.dart (đã tốt)
// Giữ nguyên components/duo_character.dart (đã tốt)
// Giữ nguyên components/speech_bubble.dart (đã tốt)
```

**Loại bỏ:**
- ✅ `duo_character_with_speech.dart` (root level - duplicate)

---

#### **1.3. Shared Components Folder Structure**
```
lib/auth/ui/widgets/onboarding/
├── shared/                      ← MỚI: Components tái sử dụng
│   ├── selection_tile.dart     ← Generic tile cho tất cả options
│   ├── duo_with_speech.dart    ← Di chuyển từ components/
│   ├── duo_character.dart      ← Di chuyển từ components/
│   ├── speech_bubble.dart      ← Di chuyển từ components/
│   ├── profile_input_field.dart ← Di chuyển từ components/
│   ├── benefit_item.dart       ← Giữ nguyên
│   └── skip_button.dart        ← Giữ nguyên
```

---

### Phase 2: Consolidate Screens (Giảm 9 screens → 6 screens)

#### **2.1. Loại bỏ Duplicate Screen**
```dart
❌ XÓA: goal_selection_screen.dart
✅ GIỮ: learning_goals_screen.dart (sử dụng SelectionTile mới)
```

#### **2.2. Loại bỏ Unused Screen**
```dart
❌ XÓA: level_selection_screen.dart (không bao giờ được gọi)
```

#### **2.3. Screens còn lại (6 screens)**
```
✅ language_selection_screen.dart      - Step 0
✅ experience_level_screen.dart        - Step 1
✅ learning_goals_screen.dart          - Step 2
✅ daily_goal_screen.dart              - Step 3
✅ learning_benefits_screen.dart       - Step 4
✅ assessment_screen.dart              - Step 5
✅ profile_setup_screen.dart           - Steps 6-8
✅ notification_permission_screen.dart - Step 10 (optional)
```

---

### Phase 3: Simplify Controller (425 dòng → ~250 dòng)

#### **3.1. Loại bỏ Duplicate/Unnecessary Code**

**Before:**
```dart
// Duplicate getters
String? get experienceLevel => _mapEnumToExperience(_proficiencyLevel);
String? get proficiencyLevel => _proficiencyLevel;

// Duplicate setters
void setExperienceLevel(String level) {
  _proficiencyLevel = _mapExperienceToEnum(level);
}
void setExperienceLevelEnum(String enumLevel) {
  _proficiencyLevel = enumLevel;
}

// 70+ dòng mapping methods
String? _mapExperienceToEnum(String? experience) { ... }
String? _mapEnumToExperience(String? proficiencyEnum) { ... }
// ... nhiều mapping methods khác
```

**After:**
```dart
// Chỉ giữ 1 getter/setter, screens sẽ trực tiếp sử dụng enum values
String? proficiencyLevel;
void setProficiencyLevel(String level) {
  proficiencyLevel = level;
  notifyListeners();
}

// Data constants trong screen files, không trong controller
// Ví dụ: experience_level_screen.dart sẽ có:
const EXPERIENCE_LEVELS = [
  {'value': 'BEGINNER', 'title': 'Tôi mới học tiếng Anh', ...},
  {'value': 'ELEMENTARY', 'title': 'Tôi biết một vài từ', ...},
  ...
];
```

#### **3.2. Simplify State Management**

**Before (425 dòng):**
- 25+ state variables
- 15+ getters
- 20+ setters
- 10+ mapping methods
- 5+ validation methods

**After (~250 dòng):**
- 12 state variables (chỉ cần thiết)
- 12 getters
- 12 setters (đơn giản)
- 3 validation methods (consolidate)
- 1 getUserData() method

---

### Phase 4: Update Imports & References

#### **4.1. Update Screen Imports**
```dart
// Tất cả screens sẽ import từ shared/
import 'shared/selection_tile.dart';
import 'shared/duo_with_speech.dart';
import 'shared/duo_character.dart';
```

#### **4.2. Update onboarding_page.dart**
```dart
// Loại bỏ unused imports
// Update screen references nếu cần
```

---

## Kết quả sau Refactoring

### **File Count Reduction**

#### Before: 28 files
```
Screens: 9 files
├── language_selection_screen.dart
├── experience_level_screen.dart
├── learning_goals_screen.dart
├── goal_selection_screen.dart          ← DUPLICATE
├── daily_goal_screen.dart
├── learning_benefits_screen.dart
├── assessment_screen.dart
├── profile_setup_screen.dart
├── notification_permission_screen.dart
└── level_selection_screen.dart         ← UNUSED

Components (root): 5 files
├── language_option_tile.dart           ← CÓ THỂ MERGE
├── goal_option_tile.dart               ← CÓ THỂ MERGE
├── level_option_tile.dart              ← CÓ THỂ MERGE
├── duo_character_with_speech.dart      ← DUPLICATE
└── onboarding_header.dart              ← UNUSED
└── onboarding_continue_button.dart     ← UNUSED

Components (subfolder): 10 files
├── assessment_option_tile.dart         ← CÓ THỂ MERGE
├── benefit_item.dart
├── duo_character.dart
├── duo_with_speech.dart
├── goal_option_tile.dart               ← CÓ THỂ MERGE
├── goal_tile.dart                      ← CÓ THỂ MERGE
├── level_option_tile.dart              ← CÓ THỂ MERGE
├── profile_input_field.dart
├── skip_button.dart
└── speech_bubble.dart

Controller: 1 file
└── onboarding_controller.dart (425 dòng)

Other: 1 file
└── onboarding_page.dart
```

#### After: 16 files (giảm 43%)
```
Screens: 7 files (giảm 2 files)
├── language_selection_screen.dart
├── experience_level_screen.dart
├── learning_goals_screen.dart
├── daily_goal_screen.dart
├── learning_benefits_screen.dart
├── assessment_screen.dart
├── profile_setup_screen.dart
└── notification_permission_screen.dart

Shared Components: 7 files (giảm 13 files)
shared/
├── selection_tile.dart                 ← MỚI: Consolidate 7 tiles
├── duo_character.dart
├── duo_with_speech.dart
├── speech_bubble.dart
├── profile_input_field.dart
├── benefit_item.dart
└── skip_button.dart

Controller: 1 file (giảm 175 dòng)
└── onboarding_controller.dart (~250 dòng)

Other: 1 file
└── onboarding_page.dart
```

---

## Chi tiết Implementation

### Step 1: Tạo SelectionTile Generic Component

```dart
// lib/auth/ui/widgets/onboarding/shared/selection_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

enum SelectionTileLayout {
  iconLeft,   // For language, goals, level
  timeLeft,   // For daily goal
  simple,     // For assessment
}

class SelectionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final SelectionTileLayout layout;
  
  // For iconLeft layout
  final IconData? icon;
  final String? emoji;
  
  // For timeLeft layout
  final String? timeText;
  final Color? badgeColor;
  final String? badgeText;
  
  // For simple layout (assessment)
  final bool hasBlueAccent;
  final String? buttonText;
  
  // For level layout
  final double? progressValue;

  const SelectionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.layout = SelectionTileLayout.iconLeft,
    this.icon,
    this.emoji,
    this.timeText,
    this.badgeColor,
    this.badgeText,
    this.hasBlueAccent = false,
    this.buttonText,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16.w),
          border: isSelected 
            ? Border.all(color: AppColors.featherGreen, width: 2.w)
            : (hasBlueAccent && !isSelected)
                ? Border.all(color: Colors.blue, width: 2.w)
                : null,
        ),
        child: Row(
          children: [
            _buildLeading(),
            SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (layout) {
      case SelectionTileLayout.iconLeft:
        return _buildIconLeading();
      case SelectionTileLayout.timeLeft:
        return _buildTimeLeading();
      case SelectionTileLayout.simple:
        return _buildEmojiLeading();
    }
  }

  Widget _buildIconLeading() {
    if (emoji != null) {
      return Text(emoji!, style: TextStyle(fontSize: 32.sp));
    }
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: isSelected 
          ? AppColors.featherGreen.withOpacity(0.2) 
          : Colors.grey[700],
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Icon(
        icon ?? Icons.check,
        color: isSelected ? AppColors.featherGreen : Colors.grey[400],
        size: 24.sp,
      ),
    );
  }

  Widget _buildTimeLeading() {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: isSelected 
          ? AppColors.featherGreen.withOpacity(0.2)
          : Colors.grey[700],
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Center(
        child: Text(
          timeText ?? '',
          style: TextStyle(
            color: isSelected ? AppColors.featherGreen : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiLeading() {
    return Text(
      emoji ?? '📝',
      style: TextStyle(fontSize: 40.sp),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.featherGreen : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ],
        if (progressValue != null) ...[
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              isSelected ? AppColors.featherGreen : Colors.grey[500]!,
            ),
          ),
        ],
        if (badgeText != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: (badgeColor ?? Colors.grey).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              badgeText!,
              style: TextStyle(
                color: badgeColor ?? Colors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing() {
    if (buttonText != null && !isSelected) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: hasBlueAccent ? Colors.blue : AppColors.featherGreen,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Text(
          buttonText!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (isSelected) {
      return Icon(
        Icons.check_circle,
        color: AppColors.featherGreen,
        size: 24.sp,
      );
    }
    return const SizedBox.shrink();
  }
}
```

---

### Step 2: Refactor Screens to Use SelectionTile

#### **2.1. Language Selection Screen**
```dart
// BEFORE
LanguageOptionTile(
  flag: language['flag'],
  name: language['name'],
  isSelected: isSelected,
  onTap: () => _selectLanguage(language['name']),
)

// AFTER
SelectionTile(
  emoji: language['flag'],
  title: language['name'],
  isSelected: isSelected,
  onTap: () => _selectLanguage(language['name']),
  layout: SelectionTileLayout.iconLeft,
)
```

#### **2.2. Experience Level Screen**
```dart
// BEFORE
LevelOptionTile(
  title: level['title'],
  description: level['description'],
  progress: level['progress'],
  isSelected: isSelected,
  onTap: () => _selectLevel(level['value']),
)

// AFTER
SelectionTile(
  title: level['title'],
  subtitle: level['description'],
  progressValue: level['progress'],
  isSelected: isSelected,
  onTap: () => _selectLevel(level['value']),
  layout: SelectionTileLayout.iconLeft,
)
```

#### **2.3. Learning Goals Screen**
```dart
// BEFORE
GoalTile(
  icon: goal['icon'],
  title: goal['title'],
  description: goal['description'],
  isSelected: isSelected,
  onTap: () => widget.onGoalToggled(goal['id']),
)

// AFTER
SelectionTile(
  icon: goal['icon'],
  title: goal['title'],
  subtitle: goal['description'],
  isSelected: isSelected,
  onTap: () => widget.onGoalToggled(goal['id']),
  layout: SelectionTileLayout.iconLeft,
)
```

#### **2.4. Daily Goal Screen**
```dart
// BEFORE
GoalOptionTile(
  time: goal.$1,
  title: goal.$2,
  subtitle: goal.$3,
  difficulty: goal.$3,
  difficultyColor: goal.$5,
  isSelected: isSelected,
  onTap: () => onGoalSelected(goal.$4),
)

// AFTER
SelectionTile(
  timeText: goal.$1,
  title: goal.$2,
  subtitle: goal.$3,
  badgeText: goal.$3,
  badgeColor: goal.$5,
  isSelected: isSelected,
  onTap: () => onGoalSelected(goal.$4),
  layout: SelectionTileLayout.timeLeft,
)
```

#### **2.5. Assessment Screen**
```dart
// BEFORE
AssessmentOptionTile(
  icon: '📝',
  title: 'Tôi muốn làm bài test đánh giá',
  description: '...',
  buttonText: 'Bắt đầu',
  value: 'assessment',
  hasBlueAccent: true,
  isSelected: isSelected,
  onTap: () => _selectOption('assessment'),
)

// AFTER
SelectionTile(
  emoji: '📝',
  title: 'Tôi muốn làm bài test đánh giá',
  subtitle: '...',
  buttonText: 'Bắt đầu',
  hasBlueAccent: true,
  isSelected: isSelected,
  onTap: () => _selectOption('assessment'),
  layout: SelectionTileLayout.simple,
)
```

---

### Step 3: Simplify OnboardingController

#### **3.1. Remove Mapping Methods**

**DELETE 70+ dòng:**
```dart
❌ _mapExperienceToEnum()
❌ _mapEnumToExperience()
❌ _mapGoalToEnum()
❌ _mapEnumToGoals()
❌ _mapMinutesToDailyGoal()
❌ _mapDailyGoalToMinutes()
```

**Lý do:** Screens sẽ trực tiếp sử dụng enum values từ data constants

#### **3.2. Consolidate State Variables**

**BEFORE:**
```dart
String? _selectedLanguage;      // UI logic
String _targetLanguage = 'en';  // DB field
String? _experienceLevel;       // UI logic  
String? _proficiencyLevel;      // DB field
List<String> _selectedGoals;    // UI logic
List<String> _learningGoals;    // DB field
String? _dailyGoal;             // UI logic
int _dailyGoalMinutes = 15;     // DB field
```

**AFTER:**
```dart
// Chỉ giữ DB fields, không cần UI fields riêng
String _targetLanguage = 'en';
String? _proficiencyLevel;
List<String> _learningGoals = [];
int _dailyGoalMinutes = 15;
```

#### **3.3. Simplified Controller Structure**

```dart
class OnboardingController extends ChangeNotifier {
  // ========== NAVIGATION ==========
  int _currentStep = 0;
  int get currentStep => _currentStep;
  
  void nextStep() { ... }
  void previousStep() { ... }
  void goToStep(int step) { ... }
  
  // ========== USER DATA (DB FIELDS) ==========
  String? _email;
  String? _password;
  String? _fullName;
  DateTime? _dateOfBirth;
  String _gender = 'PREFER_NOT_TO_SAY';
  String _nativeLanguage = 'vi';
  String _targetLanguage = 'en';
  String? _proficiencyLevel;
  List<String> _learningGoals = [];
  int _dailyGoalMinutes = 15;
  String _studyReminder = 'DAILY';
  String? _reminderTime = '09:00';
  String _timezone = 'Asia/Ho_Chi_Minh';
  String? _assessmentType;
  
  // ========== GETTERS ==========
  String? get email => _email;
  String? get password => _password;
  // ... (12 getters total)
  
  // ========== SETTERS ==========
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }
  // ... (12 setters total)
  
  // ========== VALIDATION ==========
  bool canProceedFromStep(int step) { ... }
  
  // ========== DATA EXPORT ==========
  Map<String, dynamic> getUserData() { ... }
  
  // ========== RESET ==========
  void reset() { ... }
}
```

**Kết quả:** 425 dòng → ~250 dòng (giảm 41%)

---

## Migration Steps

### Step 1: Create new shared/ folder
```bash
mkdir lib/auth/ui/widgets/onboarding/shared
```

### Step 2: Create SelectionTile
```bash
# Tạo file mới
touch lib/auth/ui/widgets/onboarding/shared/selection_tile.dart
# Implement code như trên
```

### Step 3: Move existing good components to shared/
```bash
mv lib/auth/ui/widgets/onboarding/components/duo_character.dart lib/auth/ui/widgets/onboarding/shared/
mv lib/auth/ui/widgets/onboarding/components/duo_with_speech.dart lib/auth/ui/widgets/onboarding/shared/
mv lib/auth/ui/widgets/onboarding/components/speech_bubble.dart lib/auth/ui/widgets/onboarding/shared/
mv lib/auth/ui/widgets/onboarding/components/profile_input_field.dart lib/auth/ui/widgets/onboarding/shared/
mv lib/auth/ui/widgets/onboarding/components/benefit_item.dart lib/auth/ui/widgets/onboarding/shared/
mv lib/auth/ui/widgets/onboarding/components/skip_button.dart lib/auth/ui/widgets/onboarding/shared/
```

### Step 4: Update screen imports
```dart
// Update tất cả 7 screens để import từ shared/
```

### Step 5: Refactor OnboardingController
```dart
// Remove mapping methods
// Consolidate state variables
```

### Step 6: Delete old files
```bash
# Delete duplicates
rm lib/auth/ui/widgets/onboarding/goal_selection_screen.dart
rm lib/auth/ui/widgets/onboarding/level_selection_screen.dart
rm lib/auth/ui/widgets/onboarding/duo_character_with_speech.dart
rm lib/auth/ui/widgets/onboarding/onboarding_header.dart
rm lib/auth/ui/widgets/onboarding/onboarding_continue_button.dart

# Delete old tile components
rm lib/auth/ui/widgets/onboarding/goal_option_tile.dart
rm lib/auth/ui/widgets/onboarding/level_option_tile.dart
rm lib/auth/ui/widgets/onboarding/language_option_tile.dart

# Delete old components folder (empty)
rm -rf lib/auth/ui/widgets/onboarding/components/
```

### Step 7: Test registration flow
```bash
# Run app và test từng bước
flutter run
```

---

## Benefits của Refactoring này

### ✅ **Code Quality**
- Giảm duplicate code
- Single Responsibility: 1 component cho tất cả selection tiles
- DRY (Don't Repeat Yourself)
- Dễ maintain hơn

### ✅ **File Organization**
- 28 files → 16 files (giảm 43%)
- Rõ ràng hơn: shared/ cho components tái sử dụng
- Loại bỏ unused/duplicate files

### ✅ **Performance**
- Ít file hơn = build time nhanh hơn
- Controller đơn giản hơn = ít computation hơn

### ✅ **Developer Experience**
- Dễ tìm file hơn
- Dễ hiểu structure hơn
- Dễ thêm tính năng mới hơn

### ✅ **Maintainability**
- Thay đổi UI chỉ cần sửa 1 component (SelectionTile)
- Logic rõ ràng hơn
- Ít bugs hơn

---

## Giữ nguyên

### ✅ **Workflow hoàn toàn giống nhau**
- 8 bước onboarding (Step 0-8)
- Thứ tự các màn hình không đổi
- Navigation flow không đổi

### ✅ **Thông tin thu thập không đổi**
- Tất cả fields vẫn được thu thập
- Validation rules không đổi
- Database schema mapping không đổi

### ✅ **UI/UX không đổi**
- Giao diện giống hệt
- Tương tác giống hệt
- Animations/transitions giống hệt

### ✅ **Backend integration không đổi**
- getUserData() vẫn trả về đúng format
- AuthBloc.RegisterEvent vẫn nhận đúng data
- OTP flow vẫn hoạt động như cũ

---

## Timeline

### Day 1: Setup & Component Creation
- [ ] Create shared/ folder
- [ ] Implement SelectionTile component
- [ ] Move existing components to shared/

### Day 2: Refactor Screens
- [ ] Update language_selection_screen.dart
- [ ] Update experience_level_screen.dart
- [ ] Update learning_goals_screen.dart
- [ ] Update daily_goal_screen.dart
- [ ] Update assessment_screen.dart

### Day 3: Simplify Controller & Cleanup
- [ ] Refactor onboarding_controller.dart
- [ ] Delete unused/duplicate files
- [ ] Update imports trong onboarding_page.dart

### Day 4: Testing
- [ ] Test full onboarding flow
- [ ] Test data collection
- [ ] Test registration & OTP
- [ ] Fix any issues

---

## Risks & Mitigation

### Risk 1: Breaking existing functionality
**Mitigation:** 
- Test từng screen riêng lẻ
- Giữ backup của code cũ
- Use git branches

### Risk 2: Import errors
**Mitigation:**
- Update imports systematically
- Use IDE refactoring tools
- Test build sau mỗi step

### Risk 3: Data mapping issues
**Mitigation:**
- Print/log data ở mỗi step
- Verify getUserData() output
- Test với backend

---

**Tóm lại:** Refactoring này giữ nguyên 100% logic và UX, chỉ cải thiện code structure và giảm số lượng file để dễ maintain hơn. 🎯
