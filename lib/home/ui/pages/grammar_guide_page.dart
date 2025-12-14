import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/grammar_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GrammarGuidePage extends StatefulWidget {
  final SkillEntity skillEntity;
  final String skillTitle;
  final int? partPosition;

  const GrammarGuidePage({
    super.key,
    required this.skillEntity,
    required this.skillTitle,
    this.partPosition,
  });

  @override
  State<GrammarGuidePage> createState() => _GrammarGuidePageState();
}

class _GrammarGuidePageState extends State<GrammarGuidePage> {
  late final FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = true);
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.bodyText, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. PHẦN HEADER (Nhân vật & Title) ---
            const SizedBox(height: 10),
            _buildCharacterImage(),
            const SizedBox(height: 16),
            
            // Subtitle: PHẦN X, CỬA Y (động)
            if (widget.partPosition != null || widget.skillEntity.position > 0)
              Text(
                widget.partPosition != null
                    ? 'PHẦN ${widget.partPosition}, CỬA ${widget.skillEntity.position}'
                    : 'CỬA ${widget.skillEntity.position}',
                style: AppTypography.defaultTextTheme(AppColors.hare).labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.hare,
                  letterSpacing: 1.0,
                ),
              ),
            if (widget.partPosition != null || widget.skillEntity.position > 0)
              const SizedBox(height: 8),

            // Title chính
            Text(
              widget.skillTitle,
              style: AppTypography.defaultTextTheme(AppColors.bodyText).headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.bodyText,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            const Divider(color: AppColors.swan, thickness: 1.5),
            const SizedBox(height: 24),

            // --- 2. PHẦN BODY (Cụm từ chính) ---
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label xanh dương: CỤM TỪ CHÍNH
                  Text(
                    'CỤM TỪ CHÍNH',
                    style: AppTypography.defaultTextTheme(AppColors.macaw).titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.macaw,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Title lặp lại
                  // Text(
                  //   skillTitle,
                  //   style: AppTypography.defaultTextTheme(AppColors.bodyText).titleLarge?.copyWith(
                  //     fontWeight: FontWeight.w700,
                  //     color: AppColors.bodyText,
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // Danh sách các thẻ
                  if (widget.skillEntity.grammars == null || widget.skillEntity.grammars!.isEmpty)
                     const Center(
                       child: Padding(
                         padding: EdgeInsets.all(32.0),
                         child: Text(
                           'Không có ngữ pháp nào cho skill này',
                           style: TextStyle(color: AppColors.bodyText, fontSize: 16),
                         ),
                       ),
                     )
                  else
                    ...widget.skillEntity.grammars!.map((grammar) => _buildPhraseCard(grammar)),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/logo.png',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.school, size: 60, color: AppColors.primary);
        },
      ),
    );
  }

  Widget _buildPhraseCard(GrammarEntity grammar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gộp rule và explanation thành 1 khối
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.macawLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.macaw.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rule (Tiêu đề ngữ pháp)
                Text(
                  grammar.rule,
                  style: AppTypography.defaultTextTheme(AppColors.bodyText).titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 8),
                // Explanation (Giải thích)
                Text(
                  grammar.explanation,
                  style: AppTypography.defaultTextTheme(AppColors.bodyText).bodyMedium?.copyWith(
                    color: AppColors.bodyText.withOpacity(0.7),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Hiển thị examples với SpeechBubble
          if (grammar.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...grammar.examples.map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SpeechBubble(
                variant: SpeechBubbleVariant.neutral,
                tailDirection: SpeechBubbleTailDirection.left,
                tailOffset: 20,
                showShadow: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon loa bên trái
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _speak(example);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.macaw.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSpeaking ? Icons.volume_up : Icons.volume_up_rounded,
                          color: AppColors.macaw,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nội dung ví dụ
                    Expanded(
                      child: Text(
                        example,
                        style: AppTypography.defaultTextTheme(AppColors.bodyText)
                            .bodyMedium
                            ?.copyWith(
                              color: AppColors.bodyText,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }
}
