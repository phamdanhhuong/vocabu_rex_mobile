import '../entities/entities.dart';

// Example usage of the new type-safe meta entities
class ExerciseEntityExamples {
  // Example 1: Creating a listen and choose exercise
  static ExerciseEntity createListenChooseExample() {
    final meta = ListenChooseMetaEntity(
      audioUrl:
          'http://lopngoaingu.com/vocabulary/3000-Oxford-Words/audio.php?id=ability',
      correctAnswer: 'khả năng, năng lực',
      options: [
        'khả năng, năng lực',
        'có năng lực, có tài',
        'khoảng, về',
        'ở trên, lên trên',
      ],
      word: 'ability',
    );

    return ExerciseEntity.listenChoose(
      id: 'ex_1',
      lessonId: 'lesson_1',
      prompt: 'Listen to the pronunciation and choose the correct meaning',
      position: 1,
      createdAt: DateTime.now(),
      isInteractive: true,
      isContentBased: false,
      meta: meta,
    );
  }

  // Example 2: Creating a multiple choice exercise
  static ExerciseEntity createMultipleChoiceExample() {
    final meta = MultipleChoiceMetaEntity(
      word: 'ability',
      correctAnswer: 'khả năng, năng lực',
      options: [
        'khả năng, năng lực',
        'có năng lực, có tài',
        'khoảng, về',
        'ở trên, lên trên',
      ],
    );

    return ExerciseEntity.multipleChoice(
      id: 'ex_2',
      lessonId: 'lesson_1',
      prompt: 'What does "ability" mean?',
      position: 2,
      createdAt: DateTime.now(),
      isInteractive: true,
      isContentBased: false,
      meta: meta,
    );
  }

  // Example 3: Creating a fill blank exercise
  static ExerciseEntity createFillBlankExample() {
    final meta = FillBlankMetaEntity(
      sentence: 'The _____ is important.',
      correctAnswer: 'ability',
      hint: 'khả năng, năng lực',
      rule: 'Present Simple',
      explanation: 'Dùng để diễn tả thói quen, sự thật hiển nhiên',
      example: 'I work every day.',
    );

    return ExerciseEntity.fillBlank(
      id: 'ex_3',
      lessonId: 'lesson_1',
      prompt: 'Fill in the blank using Present Simple',
      position: 3,
      createdAt: DateTime.now(),
      isInteractive: true,
      isContentBased: false,
      meta: meta,
    );
  }

  // Example 4: Creating a matching exercise
  static ExerciseEntity createMatchExample() {
    final meta = MatchMetaEntity(
      pairs: [
        WordMeaningPair(
          word: 'ability',
          meaning: 'khả năng, năng lực',
          pronunciation: "ə'biliti",
        ),
        WordMeaningPair(
          word: 'able',
          meaning: 'có năng lực, có tài',
          pronunciation: "'eibl",
        ),
        WordMeaningPair(
          word: 'about',
          meaning: 'khoảng, về',
          pronunciation: "ə'baut",
        ),
      ],
    );

    return ExerciseEntity(
      id: 'ex_4',
      lessonId: 'lesson_1',
      exerciseType: 'match',
      prompt: 'Match the words with their correct meanings',
      meta: meta,
      position: 4,
      createdAt: DateTime.now(),
      isInteractive: true,
      isContentBased: false,
    );
  }

  // Example 5: Working with existing data (from API/database)
  static ExerciseEntity fromApiResponse(Map<String, dynamic> apiData) {
    // Mock API response structure
    final mockModel = MockExerciseModel(
      id: apiData['id'],
      lessonId: apiData['lesson_id'],
      exerciseType: apiData['exercise_type'],
      prompt: apiData['prompt'],
      meta: apiData['meta'],
      position: apiData['position'],
      createdAt: DateTime.parse(apiData['created_at']),
      isInteractive: apiData['is_interactive'],
      isContentBased: apiData['is_content_based'],
    );

    return ExerciseEntity.fromModel(mockModel);
  }

  // Example 6: Demonstrating type-safe meta access
  static void demonstrateTypeSafeAccess(ExerciseEntity exercise) {
    // Safe access to specific meta types
    if (exercise.listenChooseMeta != null) {
      final meta = exercise.listenChooseMeta!;
      print('Audio URL: ${meta.audioUrl}');
      print('Options: ${meta.options.join(', ')}');
      print('Correct Answer: ${meta.correctAnswer}');
    }

    if (exercise.multipleChoiceMeta != null) {
      final meta = exercise.multipleChoiceMeta!;
      print('Word: ${meta.word}');
      print('Options: ${meta.options.join(', ')}');
      print('Correct Answer: ${meta.correctAnswer}');
    }

    // Using helper methods
    if (exercise.hasAudio) {
      print('This exercise has audio: ${exercise.audioUrl}');
    }

    if (exercise.hasOptions) {
      print('This exercise has options: ${exercise.options?.join(', ')}');
    }

    // Convert back to JSON for API calls
    final metaJson = exercise.metaAsJson;
    if (metaJson != null) {
      print('Meta as JSON: $metaJson');
    }
  }
}

// Mock model class to demonstrate fromModel usage
class MockExerciseModel {
  final String id;
  final String lessonId;
  final String exerciseType;
  final String? prompt;
  final Map<String, dynamic>? meta;
  final int position;
  final DateTime createdAt;
  final bool isInteractive;
  final bool isContentBased;

  MockExerciseModel({
    required this.id,
    required this.lessonId,
    required this.exerciseType,
    this.prompt,
    this.meta,
    required this.position,
    required this.createdAt,
    required this.isInteractive,
    required this.isContentBased,
  });
}
