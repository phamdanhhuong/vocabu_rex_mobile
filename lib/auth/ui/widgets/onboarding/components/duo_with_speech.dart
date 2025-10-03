import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'duo_character.dart';
import 'speech_bubble.dart';

enum DuoWithSpeechLayout {
  vertical,   // Duo trên, speech dưới (cho screens có ít content)
  horizontal, // Duo bên trái, speech bên phải (cho screens có nhiều content/scroll)
}

class DuoWithSpeech extends StatelessWidget {
  final String speechText;
  final DuoCharacterType duoType;
  final DuoWithSpeechLayout layout;
  final double? duoSize;
  final Color? speechBackgroundColor;
  final Color? speechTextColor;
  final double? speechFontSize;
  final FontWeight? speechFontWeight;
  final TextAlign? speechTextAlign;

  const DuoWithSpeech({
    super.key,
    required this.speechText,
    this.duoType = DuoCharacterType.normal,
    this.layout = DuoWithSpeechLayout.vertical,
    this.duoSize,
    this.speechBackgroundColor,
    this.speechTextColor,
    this.speechFontSize,
    this.speechFontWeight,
    this.speechTextAlign,
  });

  @override
  Widget build(BuildContext context) {
    final duoWidget = DuoCharacter(
      type: duoType,
      width: duoSize,
      height: duoSize,
    );

    final speechWidget = SpeechBubble(
      text: speechText,
      direction: layout == DuoWithSpeechLayout.vertical 
        ? SpeechBubbleDirection.down 
        : SpeechBubbleDirection.right, // Mũi tên trỏ về phía Duo (bên trái)
      backgroundColor: speechBackgroundColor,
      textColor: speechTextColor,
      fontSize: speechFontSize,
      fontWeight: speechFontWeight,
      textAlign: speechTextAlign,
      margin: layout == DuoWithSpeechLayout.horizontal 
        ? EdgeInsets.only(right: 20.w) // Chỉ cần margin phải
        : EdgeInsets.symmetric(horizontal: 32.w),
    );

    switch (layout) {
      case DuoWithSpeechLayout.vertical:
        return Column(
          children: [
            SizedBox(height: 20.h),
            duoWidget,
            SizedBox(height: 40.h),
            speechWidget,
            SizedBox(height: 40.h),
          ],
        );

      case DuoWithSpeechLayout.horizontal:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duo character (smaller fixed width for better proportion)
              SizedBox(
                width: (duoSize ?? 100.w) + 20.w, // Smaller padding
                child: Align(
                  alignment: Alignment.topCenter,
                  child: duoWidget,
                ),
              ),
              
              SizedBox(width: 12.w), // Smaller gap
              
              // Speech bubble (takes up more space - about 70% of width)
              Expanded(
                flex: 3, // Give bubble more space
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h), // Less top padding
                  child: speechWidget,
                ),
              ),
            ],
          ),
        );
    }
  }
}

// Factory constructors for common use cases
extension DuoWithSpeechFactory on DuoWithSpeech {
  /// For screens without scrollable content (few elements)
  static DuoWithSpeech vertical({
    required String speechText,
    DuoCharacterType duoType = DuoCharacterType.normal,
    double? duoSize,
    Color? speechBackgroundColor,
    Color? speechTextColor,
    double? speechFontSize,
    FontWeight? speechFontWeight,
    TextAlign? speechTextAlign,
  }) {
    return DuoWithSpeech(
      speechText: speechText,
      duoType: duoType,
      layout: DuoWithSpeechLayout.vertical,
      duoSize: duoSize,
      speechBackgroundColor: speechBackgroundColor,
      speechTextColor: speechTextColor,
      speechFontSize: speechFontSize,
      speechFontWeight: speechFontWeight,
      speechTextAlign: speechTextAlign,
    );
  }

  /// For screens with scrollable content (many elements, lists)
  static DuoWithSpeech horizontal({
    required String speechText,
    DuoCharacterType duoType = DuoCharacterType.normal,
    double? duoSize,
    Color? speechBackgroundColor,
    Color? speechTextColor,
    double? speechFontSize,
    FontWeight? speechFontWeight,
    TextAlign? speechTextAlign,
  }) {
    return DuoWithSpeech(
      speechText: speechText,
      duoType: duoType,
      layout: DuoWithSpeechLayout.horizontal,
      duoSize: duoSize ?? 100.w, // Smaller size for horizontal layout
      speechBackgroundColor: speechBackgroundColor,
      speechTextColor: speechTextColor,
      speechFontSize: speechFontSize,
      speechFontWeight: speechFontWeight,
      speechTextAlign: speechTextAlign ?? TextAlign.left, // Left align for horizontal
    );
  }
}