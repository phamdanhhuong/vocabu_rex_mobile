# Generic Onboarding Framework Design

## Overview
Tạo **config-driven onboarding system** giống UI exercises với các đặc điểm:
- ✅ Generic screen nhận config
- ✅ Progress bar giống exercise header
- ✅ Button với animation giống AppButton (có state selected)
- ✅ Character/images linh hoạt vị trí
- ✅ Chỉ 1-2 files cho toàn bộ onboarding flow

---

## Architecture

### File Structure (Sau refactor: chỉ ~6 files)

```
lib/auth/ui/widgets/onboarding/
├── onboarding_page.dart              ← Main page với PageView
├── onboarding_config.dart            ← Data config cho tất cả steps
├── onboarding_controller.dart        ← Simplified state management (~150 dòng)
│
└── widgets/                          ← Shared widgets
    ├── onboarding_screen.dart        ← Generic screen template
    ├── onboarding_button.dart        ← Button với animation
    ├── onboarding_header.dart        ← Progress bar + back button
    ├── onboarding_option_tile.dart   ← Generic option tile
    └── character_display.dart        ← Character/image với flexible layout
```

**Loại bỏ:** 22 files cũ (giữ lại chỉ 6 files mới)

---

## Component Design

### 1. OnboardingHeader (Progress Bar)

**Inspiration:** `exercise_header.dart`

```dart
class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  
  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Back/Close button
          IconButton(
            icon: Icon(
              currentStep > 0 ? Icons.arrow_back : Icons.close,
              color: AppColors.wolf,
            ),
            onPressed: onBack ?? () => Navigator.pop(context),
          ),
          
          // Progress bar (dùng LessonProgressBar hoặc tạo custom)
          Expanded(
            child: Container(
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(16.w),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.featherGreen,
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 48.w), // Spacer for symmetry
        ],
      ),
    );
  }
}
```

---

### 2. OnboardingButton (Based on AppButton + ProfileButton)

**Features:**
- ✅ Press animation (translate down)
- ✅ Selected state (green background)
- ✅ Disabled state (gray)
- ✅ Shadow effect

```dart
enum OnboardingButtonState {
  enabled,    // White background, green border when pressed
  selected,   // Green background
  disabled,   // Gray background
}

class OnboardingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final OnboardingButtonState state;
  final double? width;
  
  const OnboardingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.state = OnboardingButtonState.enabled,
    this.width,
  }) : super(key: key);

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  Color get _backgroundColor {
    switch (widget.state) {
      case OnboardingButtonState.selected:
        return AppColors.featherGreen;
      case OnboardingButtonState.disabled:
        return AppColors.swan;
      case OnboardingButtonState.enabled:
        return AppColors.snow;
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case OnboardingButtonState.selected:
        return AppColors.snow;
      case OnboardingButtonState.disabled:
        return AppColors.hare;
      case OnboardingButtonState.enabled:
        return AppColors.bodyText;
    }
  }

  Color get _shadowColor {
    switch (widget.state) {
      case OnboardingButtonState.selected:
        return AppColors.polar; // Dark green shadow
      case OnboardingButtonState.disabled:
        return AppColors.hare;
      case OnboardingButtonState.enabled:
        return AppColors.swan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPress = widget.state != OnboardingButtonState.disabled 
                     && widget.onPressed != null;
    
    return GestureDetector(
      onTapDown: canPress ? (_) => setState(() => _pressed = true) : null,
      onTapUp: canPress ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: canPress ? () => setState(() => _pressed = false) : null,
      onTap: canPress ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 4.0 : 0.0, 0),
        width: widget.width ?? double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: AppColors.feedDivider,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _pressed ? Colors.transparent : _shadowColor,
              offset: _pressed ? Offset.zero : Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
```

---

### 3. OnboardingOptionTile (Generic Selection Tile)

**Features:**
- ✅ Multiple layouts (icon, emoji, time badge)
- ✅ Selected state
- ✅ Press animation
- ✅ Progress bar (for level selection)

```dart
enum OptionTileLayout {
  icon,       // Icon on left (goals, level)
  emoji,      // Emoji on left (language, assessment)
  timeBadge,  // Time display on left (daily goal)
  simple,     // No icon (simple text)
}

class OnboardingOptionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final OptionTileLayout layout;
  
  // Layout-specific props
  final IconData? icon;
  final String? emoji;
  final String? timeBadge;
  final Color? badgeColor;
  final String? badgeText;
  final double? progressValue;
  
  const OnboardingOptionTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.layout = OptionTileLayout.icon,
    this.icon,
    this.emoji,
    this.timeBadge,
    this.badgeColor,
    this.badgeText,
    this.progressValue,
  }) : super(key: key);

  @override
  State<OnboardingOptionTile> createState() => _OnboardingOptionTileState();
}

class _OnboardingOptionTileState extends State<OnboardingOptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _pressed ? 2.0 : 0, 0),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16.w),
          border: widget.isSelected
              ? Border.all(color: AppColors.featherGreen, width: 2.5)
              : null,
        ),
        child: Row(
          children: [
            _buildLeading(),
            SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            if (widget.isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.featherGreen,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (widget.layout) {
      case OptionTileLayout.emoji:
        return Text(widget.emoji ?? '🎯', style: TextStyle(fontSize: 32.sp));
      
      case OptionTileLayout.timeBadge:
        return Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.featherGreen.withOpacity(0.2)
                : Colors.grey[700],
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Center(
            child: Text(
              widget.timeBadge ?? '0',
              style: TextStyle(
                color: widget.isSelected 
                    ? AppColors.featherGreen 
                    : AppColors.snow,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      
      case OptionTileLayout.icon:
        return Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.featherGreen.withOpacity(0.2)
                : Colors.grey[700],
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Icon(
            widget.icon ?? Icons.check,
            color: widget.isSelected 
                ? AppColors.featherGreen 
                : Colors.grey[400],
            size: 24.sp,
          ),
        );
      
      case OptionTileLayout.simple:
        return SizedBox.shrink();
    }
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: widget.isSelected 
                ? AppColors.featherGreen 
                : AppColors.snow,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.subtitle!,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
              height: 1.3,
            ),
          ),
        ],
        if (widget.progressValue != null) ...[
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: widget.progressValue,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isSelected 
                  ? AppColors.featherGreen 
                  : Colors.grey[500]!,
            ),
          ),
        ],
        if (widget.badgeText != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: (widget.badgeColor ?? Colors.grey).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              widget.badgeText!,
              style: TextStyle(
                color: widget.badgeColor ?? Colors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

---

### 4. CharacterDisplay (Flexible Character/Image)

**Features:**
- ✅ Support nhiều layouts (horizontal, vertical, top, bottom)
- ✅ Speech bubble
- ✅ Gif/static image
- ✅ Optional skip button

```dart
enum CharacterPosition {
  top,        // Character ở trên, content ở dưới
  bottom,     // Content ở trên, character ở dưới
  left,       // Character bên trái, speech bên phải (horizontal)
  right,      // Speech bên trái, character bên phải
}

class CharacterDisplay extends StatelessWidget {
  final String? imageUrl;      // URL của character image/gif
  final String? speechText;    // Text trong speech bubble
  final CharacterPosition position;
  final bool showSkipButton;
  final VoidCallback? onSkip;
  
  const CharacterDisplay({
    Key? key,
    this.imageUrl,
    this.speechText,
    this.position = CharacterPosition.top,
    this.showSkipButton = false,
    this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final character = imageUrl != null
        ? Image.network(
            imageUrl!,
            height: 120.h,
            fit: BoxFit.contain,
          )
        : SizedBox.shrink();
    
    final speech = speechText != null
        ? Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(color: AppColors.swan, width: 2),
            ),
            child: Text(
              speechText!,
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : SizedBox.shrink();
    
    Widget content;
    switch (position) {
      case CharacterPosition.top:
        content = Column(
          children: [
            character,
            if (speechText != null) ...[
              SizedBox(height: 16.h),
              speech,
            ],
          ],
        );
        break;
      
      case CharacterPosition.bottom:
        content = Column(
          children: [
            if (speechText != null) ...[
              speech,
              SizedBox(height: 16.h),
            ],
            character,
          ],
        );
        break;
      
      case CharacterPosition.left:
        content = Row(
          children: [
            character,
            SizedBox(width: 16.w),
            if (speechText != null) Expanded(child: speech),
          ],
        );
        break;
      
      case CharacterPosition.right:
        content = Row(
          children: [
            if (speechText != null) Expanded(child: speech),
            SizedBox(width: 16.w),
            character,
          ],
        );
        break;
    }
    
    return Stack(
      children: [
        content,
        if (showSkipButton && onSkip != null)
          Positioned(
            top: 0,
            right: 0,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Bỏ qua',
                style: TextStyle(
                  color: AppColors.wolf,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

### 5. OnboardingScreen (Generic Screen Template)

**Features:**
- ✅ Nhận config để render
- ✅ Auto layout based on config
- ✅ Handle single/multi-select
- ✅ Scrollable content

```dart
class OnboardingScreen extends StatelessWidget {
  final OnboardingStepConfig config;
  final dynamic currentValue;
  final Function(dynamic) onValueChanged;
  
  const OnboardingScreen({
    Key? key,
    required this.config,
    required this.currentValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Character/Image section
        if (config.character != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: CharacterDisplay(
              imageUrl: config.character!.imageUrl,
              speechText: config.character!.speechText,
              position: config.character!.position,
              showSkipButton: config.character!.showSkip,
              onSkip: config.character!.onSkip,
            ),
          ),
        
        // Main content (scrollable options)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (if no character)
                if (config.character == null && config.title != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Text(
                      config.title!,
                      style: TextStyle(
                        color: AppColors.snow,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                
                // Options list
                ...config.options.map((option) {
                  final isSelected = _isSelected(option.value);
                  
                  return OnboardingOptionTile(
                    title: option.title,
                    subtitle: option.subtitle,
                    isSelected: isSelected,
                    onTap: () => _handleOptionTap(option.value),
                    layout: config.optionLayout,
                    icon: option.icon,
                    emoji: option.emoji,
                    timeBadge: option.timeBadge,
                    badgeColor: option.badgeColor,
                    badgeText: option.badgeText,
                    progressValue: option.progressValue,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isSelected(dynamic value) {
    if (config.allowMultiSelect && currentValue is List) {
      return (currentValue as List).contains(value);
    }
    return currentValue == value;
  }

  void _handleOptionTap(dynamic value) {
    if (config.allowMultiSelect) {
      final current = List.from(currentValue as List? ?? []);
      if (current.contains(value)) {
        current.remove(value);
      } else {
        current.add(value);
      }
      onValueChanged(current);
    } else {
      onValueChanged(value);
    }
  }
}
```

---

## Data Models

### OnboardingStepConfig

```dart
class OnboardingStepConfig {
  final String id;
  final String? title;
  final CharacterConfig? character;
  final List<OptionConfig> options;
  final OptionTileLayout optionLayout;
  final bool allowMultiSelect;
  final String? validationMessage;
  final bool Function(dynamic)? validator;
  
  const OnboardingStepConfig({
    required this.id,
    this.title,
    this.character,
    required this.options,
    this.optionLayout = OptionTileLayout.icon,
    this.allowMultiSelect = false,
    this.validationMessage,
    this.validator,
  });
}

class CharacterConfig {
  final String? imageUrl;
  final String? speechText;
  final CharacterPosition position;
  final bool showSkip;
  final VoidCallback? onSkip;
  
  const CharacterConfig({
    this.imageUrl,
    this.speechText,
    this.position = CharacterPosition.top,
    this.showSkip = false,
    this.onSkip,
  });
}

class OptionConfig {
  final dynamic value;         // Actual value to store
  final String title;
  final String? subtitle;
  
  // Layout-specific
  final IconData? icon;
  final String? emoji;
  final String? timeBadge;
  final Color? badgeColor;
  final String? badgeText;
  final double? progressValue;
  
  const OptionConfig({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    this.timeBadge,
    this.badgeColor,
    this.badgeText,
    this.progressValue,
  });
}
```

---

## Config Example

```dart
// lib/auth/ui/widgets/onboarding/onboarding_config.dart

class OnboardingConfig {
  static const String duoNormalUrl = 'https://...'; // Character images
  static const String duoHappyUrl = 'https://...';
  static const String duoBookUrl = 'https://...';
  
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
        OptionConfig(
          value: 'en',
          emoji: '🇺🇸',
          title: 'Tiếng Anh',
        ),
        OptionConfig(
          value: 'zh',
          emoji: '🇨🇳',
          title: 'Tiếng Hoa',
        ),
        OptionConfig(
          value: 'it',
          emoji: '🇮🇹',
          title: 'Tiếng Ý',
        ),
        // ... more languages
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
        // ... more levels
      ],
      optionLayout: OptionTileLayout.icon,
      validator: (value) => value != null,
    ),
    
    // Step 2: Learning Goals (multi-select)
    OnboardingStepConfig(
      id: 'learning_goals',
      character: CharacterConfig(
        imageUrl: duoHappyUrl,
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
        // ... more goals
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
          badgeColor: Colors.green,
        ),
        OptionConfig(
          value: 10,
          timeBadge: '10',
          title: '10 phút/ngày',
          subtitle: 'Đều đặn',
          badgeText: 'Đều đặn',
          badgeColor: Colors.blue,
        ),
        // ... more goals
      ],
      optionLayout: OptionTileLayout.timeBadge,
      validator: (value) => value != null,
    ),
    
    // ... more steps (benefits, assessment, profile, etc.)
  ];
  
  // Helper to get step by ID
  static OnboardingStepConfig? getStepById(String id) {
    return steps.firstWhere((step) => step.id == id);
  }
}
```

---

## Main Page Implementation

```dart
// lib/auth/ui/widgets/onboarding/onboarding_page.dart

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Store values for each step
  final Map<String, dynamic> _stepValues = {};

  @override
  Widget build(BuildContext context) {
    final config = OnboardingConfig.steps[_currentStep];
    final currentValue = _stepValues[config.id];
    final canContinue = config.validator?.call(currentValue) ?? true;
    
    return Scaffold(
      backgroundColor: Color(0xFF2B3A4A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            OnboardingHeader(
              currentStep: _currentStep,
              totalSteps: OnboardingConfig.steps.length,
              onBack: _currentStep > 0 ? _handleBack : null,
            ),
            
            // Main content (PageView for smooth transitions)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(), // Disable swipe
                itemCount: OnboardingConfig.steps.length,
                itemBuilder: (context, index) {
                  final stepConfig = OnboardingConfig.steps[index];
                  return OnboardingScreen(
                    config: stepConfig,
                    currentValue: _stepValues[stepConfig.id],
                    onValueChanged: (value) {
                      setState(() {
                        _stepValues[stepConfig.id] = value;
                      });
                    },
                  );
                },
              ),
            ),
            
            // Continue button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: OnboardingButton(
                text: _getButtonText(),
                onPressed: canContinue ? _handleContinue : null,
                state: canContinue 
                    ? OnboardingButtonState.enabled 
                    : OnboardingButtonState.disabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    if (_currentStep == OnboardingConfig.steps.length - 1) {
      return 'HOÀN THÀNH';
    }
    return 'TIẾP TỤC';
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleContinue() {
    if (_currentStep < OnboardingConfig.steps.length - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last step - register user
      _registerUser();
    }
  }

  void _registerUser() {
    final userData = {
      'email': _stepValues['email'],
      'password': _stepValues['password'],
      'fullName': _stepValues['name'],
      'targetLanguage': _stepValues['language'] ?? 'en',
      'proficiencyLevel': _stepValues['proficiency_level'] ?? 'BEGINNER',
      'learningGoals': _stepValues['learning_goals'] ?? ['PERSONAL'],
      'dailyGoalMinutes': _stepValues['daily_goal'] ?? 15,
      // ... other fields with defaults
    };
    
    context.read<AuthBloc>().add(RegisterEvent(userData: userData));
  }
}
```

---

## Benefits của Design này

### ✅ **Cực kỳ đơn giản**
- 28 files → 6 files (giảm 79%!)
- 1 screen component cho tất cả steps
- Config-driven, không cần code cho mỗi screen

### ✅ **Flexible & Maintainable**
- Thêm/xóa/sửa steps chỉ cần edit config
- Thay đổi UI chỉ cần sửa component
- Dễ test từng component riêng

### ✅ **Consistent UX**
- Giống UI exercises (familiar)
- Animation consistent
- Visual design consistent

### ✅ **Easy to Extend**
- Thêm layout mới? Chỉ cần update enum
- Thêm validation? Chỉ cần thêm validator function
- Thêm custom component? Conditional render trong OnboardingScreen

---

## Migration Steps

1. **Create new structure** (Day 1)
   - [ ] Create widgets/ folder
   - [ ] Implement OnboardingButton
   - [ ] Implement OnboardingHeader
   - [ ] Implement OnboardingOptionTile
   - [ ] Implement CharacterDisplay
   - [ ] Implement OnboardingScreen

2. **Create config** (Day 2)
   - [ ] Define all step configs
   - [ ] Add character images URLs
   - [ ] Add validation logic

3. **Implement main page** (Day 2-3)
   - [ ] Create OnboardingPage with PageView
   - [ ] Wire up navigation
   - [ ] Connect to AuthBloc

4. **Cleanup** (Day 3)
   - [ ] Delete 22 old files
   - [ ] Update imports
   - [ ] Test full flow

5. **Polish** (Day 4)
   - [ ] Add page transitions
   - [ ] Add animations
   - [ ] Handle edge cases

---

**Total time:** ~3-4 days
**Total files:** 6 files (vs 28 files hiện tại)
**Lines of code:** ~1200 dòng (vs ~2500 dòng hiện tại)

Bạn muốn tôi bắt đầu implement không? 🚀
