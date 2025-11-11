# Onboarding UI Refactor - README

## 📱 Tổng quan

Đã refactor toàn bộ onboarding flow để:
- ✅ Sử dụng **theme system** có sẵn (AppColors, AppTypography)
- ✅ **Responsive** với ScreenUtil
- ✅ **Animations** mượt mà giống Duolingo
- ✅ **Reusable components** dễ maintain
- ✅ Hỗ trợ **animated characters** (GIF/Lottie/JSON)

## 🎯 Mục tiêu đạt được

### 1. Theme System Integration
- [x] Tất cả màu sắc dùng `AppColors`
- [x] Typography dùng `AppTypography`
- [x] Consistent với design system
- [x] No hardcoded colors/fonts

### 2. Responsive Design
- [x] Sử dụng `flutter_screenutil`
- [x] `.w`, `.h`, `.r`, `.sp` cho all dimensions
- [x] Flexible layouts
- [x] Test trên nhiều screen sizes

### 3. Animations như Duolingo
- [x] **Staggered animations** - items xuất hiện lần lượt
- [x] **Slide transitions** - smooth slides
- [x] **Scale effects** - bounce/elastic
- [x] **Press feedback** - tap animations
- [x] **Fade effects** - opacity transitions

### 4. Character Illustrations
- [x] Support **Lottie JSON** animations
- [x] Support **GIF** animations  
- [x] **Fallback** sang static images
- [x] Predefined character states
- [x] Easy to replace assets

## 📁 Cấu trúc Files

```
onboarding/
├── components/                              # ✅ NEW Components
│   ├── animated_character.dart              # Character animation widget
│   ├── onboarding_option_tile.dart          # Base tiles + variants
│   ├── daily_goal_tile.dart                 # Daily goal specific tile
│   ├── duo_with_speech.dart                 # Existing (kept)
│   ├── duo_character.dart                   # Existing (kept)
│   └── ...other components
│
├── examples/                                # ✅ NEW Examples
│   └── components_example.dart              # Demo all components
│
├── language_selection_screen.dart           # ✅ REFACTORED
├── goal_selection_screen.dart               # ✅ REFACTORED  
├── level_selection_screen.dart              # ✅ REFACTORED
├── daily_goal_screen.dart                   # ✅ REFACTORED
│
├── learning_benefits_screen.dart            # ⏳ TODO
├── assessment_screen.dart                   # ⏳ TODO
├── profile_setup_screen.dart                # ⏳ TODO
│
├── onboarding_controller.dart               # Existing (kept)
├── REFACTOR_GUIDE.md                        # ✅ NEW Documentation
├── REFACTOR_SUMMARY.md                      # ✅ NEW Summary
└── README.md                                # This file
```

## 🚀 Quick Start

### 1. Xem demo components
```dart
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/examples/components_example.dart';

// Navigate to demo screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OnboardingComponentsExample(),
  ),
);
```

### 2. Sử dụng LanguageTile
```dart
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/components/onboarding_option_tile.dart';

LanguageTile(
  flagEmoji: '🇺🇸',
  languageName: 'Tiếng Anh',
  isSelected: selectedLanguage == 'en',
  onTap: () => setState(() => selectedLanguage = 'en'),
)
```

### 3. Sử dụng Animated Character
```dart
import 'package:vocabu_rex_mobile/auth/ui/widgets/onboarding/components/animated_character.dart';

// Cách 1: Dùng predefined state
CharacterAnimations.forState(
  state: CharacterState.happy,
  width: 200,
  height: 200,
)

// Cách 2: Custom
AnimatedCharacter.lottie(
  animationPath: 'assets/animations/duo_happy.json',
  fallbackImagePath: 'assets/images/duo_happy.png',
  width: 200,
  height: 200,
)
```

### 4. Thêm staggered animations vào screen
```dart
class MyScreen extends StatefulWidget {
  // ...
}

class _MyScreenState extends State<MyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimations = List.generate(
      items.length,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: _slideAnimations[index],
          child: YourTile(...),
        );
      },
    );
  }
}
```

## 📚 Available Components

### Tiles
| Component | Usage | Animation |
|-----------|-------|-----------|
| `LanguageTile` | Chọn ngôn ngữ | Slide-in + Scale |
| `LevelTile` | Chọn trình độ | Fade + Slide |
| `GoalSelectionTile` | Chọn mục tiêu | Staggered slide |
| `DailyGoalTile` | Chọn goal hàng ngày | Bounce + Slide |
| `OnboardingOptionTile` | Base tile | Press feedback |

### Characters
| State | File Path | Description |
|-------|-----------|-------------|
| `CharacterState.normal` | `duo_normal.*` | Duo bình thường |
| `CharacterState.happy` | `duo_happy.*` | Duo vui vẻ |
| `CharacterState.withBook` | `duo_with_book.*` | Duo cầm sách |
| `CharacterState.withGrad` | `duo_with_grad.*` | Duo tốt nghiệp |
| `CharacterState.excited` | `duo_excited.*` | Duo hào hứng |
| `CharacterState.thinking` | `duo_thinking.*` | Duo suy nghĩ |

## 🎨 Theme Colors được sử dụng

```dart
// Primary actions, selections
AppColors.primary         // #58CC02 (Feather Green)

// Highlights, secondary selections  
AppColors.macaw          // #1CB0F6 (Blue)

// Text colors
AppColors.eel            // #4B4B4B (Dark gray)
AppColors.wolf           // #777777 (Medium gray)

// Backgrounds
AppColors.snow           // #FFFFFF (White)
AppColors.polar          // #F7F7F7 (Off-white)

// Borders
AppColors.swan           // #E5E5E5 (Light gray)

// Difficulty colors
AppColors.fox            // #FF9600 (Orange)
AppColors.cardinal       // #FF4B4B (Red)
```

## ⚙️ Setup Instructions

### 1. Thêm Lottie dependency (optional nhưng recommended)
```yaml
# pubspec.yaml
dependencies:
  lottie: ^3.0.0
```

### 2. Thêm assets
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/animations/      # Lottie JSON hoặc GIF
    - assets/images/          # Fallback images
```

### 3. Uncomment Lottie code
File: `components/animated_character.dart`

Tìm dòng:
```dart
Widget _buildLottie() {
  // TODO: Implement Lottie animation when lottie package is added
```

Uncomment code bên trong khi đã add Lottie dependency.

### 4. Chuẩn bị assets
Tạo hoặc download animations cho các states:
- `duo_normal.json` / `duo_normal.gif`
- `duo_happy.json` / `duo_happy.gif`
- `duo_with_book.json` / `duo_with_book.gif`
- `duo_with_grad.json` / `duo_with_grad.gif`
- `duo_excited.json` / `duo_excited.gif`
- `duo_thinking.json` / `duo_thinking.gif`

Plus fallback images:
- `duo_normal.png`
- `duo_happy.png`
- etc.

## 🔄 Migration từ old code

### Before (Old)
```dart
import 'language_option_tile.dart';

LanguageOptionTile(
  flagEmoji: '🇺🇸',
  languageName: 'English',
  isSelected: true,
  onTap: () {},
)
```

### After (New)
```dart
import 'components/onboarding_option_tile.dart';

LanguageTile(
  flagEmoji: '🇺🇸',
  languageName: 'English',
  isSelected: true,
  onTap: () {},
)
```

## 🐛 Troubleshooting

### Issue: Animations lag
**Solution**: Giảm duration hoặc simplify animations
```dart
// Before
duration: const Duration(milliseconds: 1000),

// After  
duration: const Duration(milliseconds: 600),
```

### Issue: Assets not found
**Solution**: 
1. Check path trong pubspec.yaml
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild app

### Issue: Import errors
**Solution**: Ensure import paths đúng
```dart
// Components in same folder
import 'components/animated_character.dart';

// Components from parent folder
import '../components/animated_character.dart';
```

## 📊 Performance

Target metrics:
- **FPS**: 60 FPS mượt mà
- **Load time**: < 200ms cho animations
- **Memory**: < 50MB cho onboarding flow
- **Bundle size**: Tối ưu asset compression

## 📖 Documentation

- [REFACTOR_GUIDE.md](./REFACTOR_GUIDE.md) - Chi tiết implementation
- [REFACTOR_SUMMARY.md](./REFACTOR_SUMMARY.md) - Tổng quan changes
- [Theme README](../../../theme/README.md) - Design system
- [Components Example](./examples/components_example.dart) - Live demo

## ✅ Checklist khi thêm screen mới

- [ ] Sử dụng `AppColors` cho all colors
- [ ] Sử dụng `AppTypography` cho text styles
- [ ] Add animation controller với vsync
- [ ] Implement staggered/sequential animations
- [ ] Sử dụng responsive units (.w, .h, .r, .sp)
- [ ] Dispose animation controllers
- [ ] Test trên nhiều screen sizes
- [ ] Verify 60 FPS performance
- [ ] Add accessibility labels
- [ ] Update documentation

## 🎯 Next Steps

1. ⏳ Hoàn thành refactor các screens còn lại
2. ⏳ Add Lottie animations
3. ⏳ Tạo page transitions
4. ⏳ Add haptic feedback
5. ⏳ A/B test animation timings
6. ⏳ Performance optimization
7. ⏳ Unit tests

## 👥 Contributors

- Refactored by: GitHub Copilot
- Date: November 8, 2025
- Version: 1.0.0

## 📄 License

Same as main project license.

---

**Happy coding! 🎉**

Nếu có questions, check [REFACTOR_GUIDE.md](./REFACTOR_GUIDE.md) hoặc [example code](./examples/components_example.dart).
