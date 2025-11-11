import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Animated character widget that supports multiple animation formats:
/// - Lottie JSON animations (recommended)
/// - GIF animations
/// - Static image fallback
///
/// Usage:
/// ```dart
/// AnimatedCharacter(
///   animationPath: 'assets/animations/duo_happy.json', // Lottie
///   fallbackImagePath: 'assets/images/duo_placeholder.png',
///   width: 200,
///   height: 200,
/// )
/// 
/// AnimatedCharacter.gif(
///   animationPath: 'assets/animations/duo_happy.gif',
///   fallbackImagePath: 'assets/images/duo_placeholder.png',
///   width: 200,
///   height: 200,
/// )
/// ```
class AnimatedCharacter extends StatelessWidget {
  final String? animationPath; // Path to Lottie JSON or GIF
  final String? fallbackImagePath; // Fallback static image
  final double? width;
  final double? height;
  final BoxFit fit;
  final AnimationCharacterType type;
  final bool repeat;
  final bool autoPlay;

  const AnimatedCharacter({
    super.key,
    this.animationPath,
    this.fallbackImagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.type = AnimationCharacterType.lottie,
    this.repeat = true,
    this.autoPlay = true,
  });

  const AnimatedCharacter.gif({
    Key? key,
    required String animationPath,
    String? fallbackImagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
  }) : this(
          key: key,
          animationPath: animationPath,
          fallbackImagePath: fallbackImagePath,
          width: width,
          height: height,
          fit: fit,
          type: AnimationCharacterType.gif,
          repeat: repeat,
        );

  const AnimatedCharacter.lottie({
    Key? key,
    required String animationPath,
    String? fallbackImagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool autoPlay = true,
  }) : this(
          key: key,
          animationPath: animationPath,
          fallbackImagePath: fallbackImagePath,
          width: width,
          height: height,
          fit: fit,
          type: AnimationCharacterType.lottie,
          repeat: repeat,
          autoPlay: autoPlay,
        );

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? 200.w;
    final effectiveHeight = height ?? 200.h;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: _buildCharacter(),
    );
  }

  Widget _buildCharacter() {
    // If no animation path provided, show fallback
    if (animationPath == null || animationPath!.isEmpty) {
      return _buildFallback();
    }

    // Try to load animation based on type
    switch (type) {
      case AnimationCharacterType.lottie:
        return _buildLottie();
      case AnimationCharacterType.gif:
        return _buildGif();
      case AnimationCharacterType.static:
        return _buildFallback();
    }
  }

  Widget _buildLottie() {
    // TODO: Implement Lottie animation when lottie package is added
    // For now, show fallback with a note
    // 
    // When implemented:
    // return Lottie.asset(
    //   animationPath!,
    //   width: width,
    //   height: height,
    //   fit: fit,
    //   repeat: repeat,
    //   animate: autoPlay,
    //   errorBuilder: (context, error, stackTrace) => _buildFallback(),
    // );
    
    return _buildFallback();
  }

  Widget _buildGif() {
    // GIF support using Image.asset
    try {
      return Image.asset(
        animationPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } catch (e) {
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    if (fallbackImagePath != null && fallbackImagePath!.isNotEmpty) {
      return Image.asset(
        fallbackImagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    // Default placeholder with character icon
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Icon(
          Icons.psychology_outlined,
          size: (width ?? 200.w) * 0.4,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

enum AnimationCharacterType {
  lottie,
  gif,
  static,
}

/// Predefined character states for easy usage
class CharacterAnimations {
  // Placeholder paths - replace with actual animation files
  static const String duoNormal = 'assets/animations/duo_normal.json';
  static const String duoHappy = 'assets/animations/duo_happy.json';
  static const String duoWithBook = 'assets/animations/duo_with_book.json';
  static const String duoWithGrad = 'assets/animations/duo_with_grad.json';
  static const String duoExcited = 'assets/animations/duo_excited.json';
  static const String duoThinking = 'assets/animations/duo_thinking.json';

  // Fallback static images
  static const String duoNormalStatic = 'assets/images/duo_normal.png';
  static const String duoHappyStatic = 'assets/images/duo_happy.png';
  static const String duoWithBookStatic = 'assets/images/duo_with_book.png';
  static const String duoWithGradStatic = 'assets/images/duo_with_grad.png';
  static const String duoExcitedStatic = 'assets/images/duo_excited.png';
  static const String duoThinkingStatic = 'assets/images/duo_thinking.png';

  /// Get character widget by state
  static Widget forState({
    required CharacterState state,
    double? width,
    double? height,
    bool useGif = false,
  }) {
    final paths = _getPathsForState(state);
    
    if (useGif) {
      return AnimatedCharacter.gif(
        animationPath: paths['gif']!,
        fallbackImagePath: paths['fallback'],
        width: width,
        height: height,
      );
    }
    
    return AnimatedCharacter.lottie(
      animationPath: paths['lottie']!,
      fallbackImagePath: paths['fallback'],
      width: width,
      height: height,
    );
  }

  static Map<String, String> _getPathsForState(CharacterState state) {
    switch (state) {
      case CharacterState.normal:
        return {
          'lottie': duoNormal,
          'gif': duoNormal.replaceAll('.json', '.gif'),
          'fallback': duoNormalStatic,
        };
      case CharacterState.happy:
        return {
          'lottie': duoHappy,
          'gif': duoHappy.replaceAll('.json', '.gif'),
          'fallback': duoHappyStatic,
        };
      case CharacterState.withBook:
        return {
          'lottie': duoWithBook,
          'gif': duoWithBook.replaceAll('.json', '.gif'),
          'fallback': duoWithBookStatic,
        };
      case CharacterState.withGrad:
        return {
          'lottie': duoWithGrad,
          'gif': duoWithGrad.replaceAll('.json', '.gif'),
          'fallback': duoWithGradStatic,
        };
      case CharacterState.excited:
        return {
          'lottie': duoExcited,
          'gif': duoExcited.replaceAll('.json', '.gif'),
          'fallback': duoExcitedStatic,
        };
      case CharacterState.thinking:
        return {
          'lottie': duoThinking,
          'gif': duoThinking.replaceAll('.json', '.gif'),
          'fallback': duoThinkingStatic,
        };
    }
  }
}

enum CharacterState {
  normal,
  happy,
  withBook,
  withGrad,
  excited,
  thinking,
}
