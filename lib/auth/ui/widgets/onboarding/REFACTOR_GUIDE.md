# Onboarding UI Refactor - Hướng dẫn sử dụng

## Tổng quan
Đã refactor toàn bộ onboarding screens để sử dụng theme system có sẵn, responsive layout và animations giống Duolingo.

## Các thay đổi chính

### 1. Animated Character Widget
**File**: `components/animated_character.dart`

Widget mới hỗ trợ nhiều định dạng animation:
- **Lottie JSON** (recommended) - animations mượt mà
- **GIF animations** - animations đơn giản hơn
- **Static images** - fallback khi không có animation

#### Cách sử dụng:

```dart
// Sử dụng Lottie animation
AnimatedCharacter.lottie(
  animationPath: 'assets/animations/duo_happy.json',
  fallbackImagePath: 'assets/images/duo_happy.png',
  width: 200,
  height: 200,
)

// Sử dụng GIF
AnimatedCharacter.gif(
  animationPath: 'assets/animations/duo_happy.gif',
  fallbackImagePath: 'assets/images/duo_happy.png',
  width: 200,
  height: 200,
)

// Sử dụng helper với predefined states
CharacterAnimations.forState(
  state: CharacterState.happy,
  width: 200,
  height: 200,
  useGif: false, // true để dùng GIF thay vì Lottie
)
```

#### Các states có sẵn:
- `CharacterState.normal` - Duo thường
- `CharacterState.happy` - Duo vui vẻ
- `CharacterState.withBook` - Duo cầm sách
- `CharacterState.withGrad` - Duo mặc lễ phục tốt nghiệp
- `CharacterState.excited` - Duo hào hứng
- `CharacterState.thinking` - Duo đang suy nghĩ

### 2. Onboarding Tiles với Theme System
**File**: `components/onboarding_option_tile.dart`

Tất cả tiles giờ đây sử dụng:
- **AppColors** - màu sắc theo design system
- **AppTypography** - phông chữ Duolingo-style
- **Press animations** - hiệu ứng nhấn mượt mà
- **Scale & shadow effects** - giống tiles trong app chính

#### Base tile - OnboardingOptionTile
```dart
OnboardingOptionTile(
  leading: Icon(Icons.language),
  title: 'Tiếng Anh',
  subtitle: 'English',
  isSelected: true,
  onTap: () {},
  selectedColor: AppColors.macaw,
)
```

#### Language tile
```dart
LanguageTile(
  flagEmoji: '🇺🇸',
  languageName: 'Tiếng Anh',
  isSelected: true,
  onTap: () {},
)
```

#### Level tile (với bars indicator)
```dart
LevelTile(
  title: 'Tôi mới học tiếng Anh',
  description: '',
  level: 1, // 1-5 bars
  isSelected: true,
  onTap: () {},
)
```

#### Goal tile
```dart
GoalSelectionTile(
  icon: Icons.people,
  title: 'Kết nối với mọi người',
  description: 'Giao tiếp và làm quen bạn bè mới',
  isSelected: true,
  onTap: () {},
)
```

#### Daily goal tile
**File**: `components/daily_goal_tile.dart`
```dart
DailyGoalTile(
  time: '15',
  title: '15 phút/ngày',
  subtitle: '',
  difficulty: 'Nghiêm túc',
  difficultyColor: AppColors.fox,
  isSelected: true,
  onTap: () {},
)
```

### 3. Animations trong Screens

Mỗi screen giờ đây có animations đặc trưng:

#### LanguageSelectionScreen
- **Staggered slide-in** từ phải sang
- **Fade-in** từ trong suốt
- Smooth transitions giữa states

#### GoalSelectionScreen
- **Staggered slide-in** từ trái sang
- **Scale animations** khi xuất hiện
- Multiple selection support

#### DailyGoalScreen
- **Bounce animations** (elastic curve)
- **Slide from bottom**
- Playful feel phù hợp với daily goal selection

## Cấu trúc thư mục

```
onboarding/
├── components/
│   ├── animated_character.dart          # NEW - Character animations
│   ├── onboarding_option_tile.dart      # NEW - Reusable tiles
│   ├── daily_goal_tile.dart             # NEW - Daily goal tile
│   ├── duo_with_speech.dart             # Existing
│   ├── duo_character.dart               # Existing
│   └── ...
├── language_selection_screen.dart       # UPDATED - Với animations
├── goal_selection_screen.dart           # UPDATED - Với animations
├── level_selection_screen.dart          # TO UPDATE
├── daily_goal_screen.dart               # UPDATED - Với animations
├── learning_benefits_screen.dart        # TO UPDATE
├── assessment_screen.dart               # TO UPDATE
├── profile_setup_screen.dart            # TO UPDATE
└── onboarding_controller.dart           # Existing
```

## Assets cần thêm

### Lottie animations (recommended)
Thêm vào `pubspec.yaml`:
```yaml
dependencies:
  lottie: ^latest_version
```

Tạo folder structure:
```
assets/
  animations/
    duo_normal.json
    duo_happy.json
    duo_with_book.json
    duo_with_grad.json
    duo_excited.json
    duo_thinking.json
  images/
    duo_normal.png      # Fallback
    duo_happy.png       # Fallback
    duo_with_book.png   # Fallback
    duo_with_grad.png   # Fallback
    duo_excited.png     # Fallback
    duo_thinking.png    # Fallback
```

### Hoặc GIF animations
```
assets/
  animations/
    duo_normal.gif
    duo_happy.gif
    duo_with_book.gif
    duo_with_grad.gif
    duo_excited.gif
    duo_thinking.gif
```

## Next Steps

### 1. Thêm Lottie package (nếu dùng Lottie)
```bash
flutter pub add lottie
```

### 2. Uncomment Lottie code trong AnimatedCharacter
File: `components/animated_character.dart`

Tìm và uncomment:
```dart
Widget _buildLottie() {
  return Lottie.asset(
    animationPath!,
    width: width,
    height: height,
    fit: fit,
    repeat: repeat,
    animate: autoPlay,
    errorBuilder: (context, error, stackTrace) => _buildFallback(),
  );
}
```

### 3. Thêm assets vào pubspec.yaml
```yaml
flutter:
  assets:
    - assets/animations/
    - assets/images/
```

### 4. Thay thế character illustrations cũ
Tìm và thay thế các references đến:
- `DuoCharacter` → `AnimatedCharacter`
- `CharacterIllustration` → `AnimatedCharacter.lottie()` hoặc `.gif()`

### 5. Test animations
- Test trên nhiều kích thước màn hình
- Verify performance (đặc biệt với Lottie)
- Check fallback behavior khi assets không tồn tại

## Best Practices

### 1. Animation Performance
- Sử dụng `const` constructors khi có thể
- Dispose animation controllers trong `dispose()`
- Giới hạn số lượng animations đồng thời

### 2. Responsive Design
- Sử dụng `ScreenUtil` cho all spacing/sizing
- Test trên nhiều screen sizes
- Ensure text không bị overflow

### 3. Theme Consistency
- Luôn dùng `AppColors` thay vì hardcoded colors
- Sử dụng `AppTypography` cho text styles
- Follow Duolingo design guidelines

### 4. Accessibility
- Ensure sufficient contrast ratios
- Provide meaningful descriptions
- Support screen readers

## Troubleshooting

### Animations không chạy
- Check animation controller được khởi tạo đúng
- Verify `vsync` parameter
- Ensure `forward()` được gọi

### Assets không load
- Check path trong pubspec.yaml
- Verify file tồn tại
- Run `flutter clean` và rebuild

### Performance issues
- Giảm complexity của Lottie animations
- Sử dụng GIF thay vì Lottie
- Cache images khi có thể

## Migration Guide

### Để migrate từ old tiles sang new tiles:

1. **LanguageOptionTile** → **LanguageTile**
```dart
// Old
LanguageOptionTile(
  flagEmoji: '🇺🇸',
  languageName: 'Tiếng Anh',
  isSelected: true,
  onTap: () {},
)

// New
LanguageTile(
  flagEmoji: '🇺🇸',
  languageName: 'Tiếng Anh',
  isSelected: true,
  onTap: () {},
)
```

2. **GoalTile** → **GoalSelectionTile**
```dart
// Old
GoalTile(
  icon: Icons.people,
  title: 'Title',
  description: 'Desc',
  isSelected: true,
  onTap: () {},
)

// New
GoalSelectionTile(
  icon: Icons.people,
  title: 'Title',
  description: 'Desc',
  isSelected: true,
  onTap: () {},
)
```

3. **LevelOptionTile** → **LevelTile**
```dart
// Old
LevelOptionTile(
  icon: Icons.signal_cellular_alt,
  title: 'Tôi mới học',
  description: '',
  isSelected: true,
  onTap: () {},
)

// New
LevelTile(
  title: 'Tôi mới học',
  level: 1,
  isSelected: true,
  onTap: () {},
)
```

## Resources

- [Duolingo Design Guidelines](../../../theme/README.md)
- [Animation Best Practices](https://docs.flutter.dev/development/ui/animations)
- [Lottie Documentation](https://pub.dev/packages/lottie)
- [ScreenUtil Usage](https://pub.dev/packages/flutter_screenutil)
