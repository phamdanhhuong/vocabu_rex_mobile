import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';

class Podcast extends StatefulWidget {
  final PodcastMetaEntity meta;
  final String exerciseId;
  const Podcast({super.key, required this.meta, required this.exerciseId});

  @override
  State<Podcast> createState() => _PodcastState();
}

class _PodcastState extends State<Podcast> {
  PodcastMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  bool isPlaying = false;
  int currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late FlutterTts flutterTts;

  PodcastQuestion? currentQuestion;
  bool answeredCorrectly = false;

  Future<void> setVoice(String gender) async {
    if (gender == 'male') {
      await flutterTts.setVoice({
        "name": "Google UK English Male",
        "locale": "en-GB",
      });
    } else {
      await flutterTts.setVoice({
        "name": "Google UK English Female",
        "locale": "en-GB",
      });
    }
  }

  Future<void> speakSegments(List<PodcastSegment> segments) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(1);
    await flutterTts.setVolume(1.0);
    await flutterTts.awaitSpeakCompletion(true);

    setState(() {
      isPlaying = true;
      answeredCorrectly = false;
      currentQuestion = null;
    });

    while (currentIndex < segments.length) {
      if (!isPlaying) break;

      await setVoice(segments[currentIndex].voiceGender);
      await flutterTts.stop(); // tránh lặp câu cuối

      // Gọi speak và CHỜ hoàn thành (vì đã bật awaitSpeakCompletion)
      await flutterTts.speak(segments[currentIndex].transcript);
      _scrollToCurrent();
      setState(() {});

      // Nếu có câu hỏi giữa chừng → xử lý ở đây
      if (segments[currentIndex].questions != null &&
          segments[currentIndex].questions!.isNotEmpty) {
        await flutterTts.stop();
        setState(() {
          currentQuestion = segments[currentIndex].questions!.first;
          isPlaying = false; // pause playback
        });
        return;
      }
      currentIndex++;
      if (currentIndex == segments.length) {
        handleSubmit();
      }
    }
    setState(() {
      isPlaying = false;
      currentQuestion = null;
    });
  }

  void handleAnswer(String answer) {
    if (currentQuestion == null) return;

    bool correct =
        answer.trim().toLowerCase() ==
        currentQuestion!.correctAnswer.trim().toLowerCase();

    if (correct) {
      setState(() {
        answeredCorrectly = true;
        currentQuestion = null;
        currentIndex++; // qua đoạn tiếp
        isPlaying = true;
      });
      // Tiếp tục phát đoạn kế tiếp
      speakSegments(_meta.segments);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Good job !!!!!",
            style: TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Try again!",
            style: TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
    setState(() => isPlaying = false);
  }

  void handleSubmit() {
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: "done",
        correctAnswer: "done",
        exerciseId: _exerciseId,
      ),
    );
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    // Mỗi item cao tầm 80 pixel, có thể điều chỉnh theo UI thực tế
    final offset = currentIndex * 80.0;
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.awaitSpeakCompletion(true);
    speakSegments(_meta.segments);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExercisesLoaded) {
          return Column(
              children: [
                SizedBox(height: 20.h),
                Text(
                  _meta.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    controller: _scrollController,
                    itemCount: _meta.segments.length,
                    itemBuilder: (context, index) {
                      final segment = _meta.segments[index];
                      final isActive = index == currentIndex;
                      final isMale = segment.voiceGender == 'male';
                      if (index > currentIndex) return SizedBox.shrink();
                      return Align(
                        alignment: isMale
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            await setVoice(segment.voiceGender);
                            await flutterTts.stop();
                            await flutterTts.speak(segment.transcript);
                            _scrollToCurrent();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 16.w,
                            ),
                            constraints: BoxConstraints(maxWidth: 0.75.sw),
                            decoration: BoxDecoration(
                              color: isMale
                                  ? Colors.grey.shade200
                                  : AppColors.primaryBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(16.r),
                                bottomLeft: Radius.circular(isMale ? 0 : 16.r),
                                bottomRight: Radius.circular(isMale ? 16.r : 0),
                              ),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isMale) ...[
                                  Icon(
                                    Icons.volume_up,
                                    color: AppColors.primaryBlue,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Flexible(
                                  child: Text(
                                    "${index + 1}.",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                ),
                                if (!isMale) ...[
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.volume_up,
                                    color: AppColors.primaryBlue,
                                    size: 20.sp,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (currentQuestion != null) ...[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentQuestion!.question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        for (var opt in currentQuestion!.options)
                          _buildOptionButton(
                            text: opt,
                            color: Colors.white,
                            onTap: () => handleAnswer(opt),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildOptionButton({
    required String text,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryBlue),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textBlue,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
