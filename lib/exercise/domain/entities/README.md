# Exercise Meta Entity Documentation

## Overview

The `meta` field in `ExerciseEntity` has been refactored from a generic `Map<String, dynamic>?` to a type-safe entity system using `ExerciseMetaEntity` and its specialized subclasses.

## Benefits

1. **Type Safety**: No more casting or runtime errors when accessing meta properties
2. **IntelliSense Support**: Full IDE support with autocomplete and type checking
3. **Maintainability**: Clear structure and easier to modify
4. **Validation**: Compile-time validation of meta structures

## Meta Entity Types

Based on your seed data, the following meta entity types are supported:

### 1. ListenChooseMetaEntity

For listening exercises with multiple choice answers.

```dart
ListenChooseMetaEntity(
  audioUrl: 'http://example.com/audio.mp3',
  correctAnswer: 'correct answer',
  options: ['option1', 'option2', 'option3', 'option4'],
  word: 'vocabulary_word', // optional
)
```

### 2. MultipleChoiceMetaEntity

For multiple choice questions.

```dart
MultipleChoiceMetaEntity(
  word: 'vocabulary_word',
  correctAnswer: 'correct answer',
  options: ['option1', 'option2', 'option3', 'option4'],
)
```

### 3. TranslateMetaEntity

For translation exercises.

```dart
TranslateMetaEntity(
  word: 'vocabulary_word',
  correctAnswer: 'translated_answer',
)
```

### 4. FillBlankMetaEntity

For fill-in-the-blank exercises.

```dart
FillBlankMetaEntity(
  sentence: 'The _____ is important.',
  correctAnswer: 'answer',
  hint: 'optional hint', // optional
  rule: 'Present Simple', // optional
  explanation: 'grammar explanation', // optional
  example: 'example sentence', // optional
)
```

### 5. MatchMetaEntity

For matching exercises.

```dart
MatchMetaEntity(
  pairs: [
    WordMeaningPair(
      word: 'word1',
      meaning: 'meaning1',
      pronunciation: 'pronunciation1', // optional
    ),
    // ... more pairs
  ],
)
```

### 6. PodcastMetaEntity

For podcast listening exercises.

```dart
PodcastMetaEntity(
  audioUrl: 'http://example.com/podcast.mp3',
  duration: '10:30',
  transcript: 'Full transcript...',
  questions: [
    PodcastQuestion(
      question: 'What is the topic?',
      answer: 'Answer here',
    ),
    // ... more questions
  ],
)
```

### 7. WritingPromptMetaEntity

For writing exercises.

```dart
WritingPromptMetaEntity(
  minWords: 100,
  maxWords: 200,
  requiredWords: ['word1', 'word2', 'word3'],
  rubric: WritingRubric(
    vocabulary: 'Use of learned vocabulary',
    grammar: 'Correct grammar usage',
    coherence: 'Clear and coherent writing',
  ),
)
```

### 8. GenericMetaEntity

For unknown or flexible meta types (fallback).

```dart
GenericMetaEntity(
  data: {'key': 'value', ...},
)
```

## Usage Examples

### Creating Exercises

```dart
// Using factory constructors
final exercise = ExerciseEntity.listenChoose(
  id: 'ex_1',
  lessonId: 'lesson_1',
  prompt: 'Listen and choose',
  position: 1,
  createdAt: DateTime.now(),
  isInteractive: true,
  isContentBased: false,
  meta: ListenChooseMetaEntity(/* ... */),
);

// Using regular constructor
final exercise2 = ExerciseEntity(
  id: 'ex_2',
  lessonId: 'lesson_1',
  exerciseType: 'match',
  prompt: 'Match words',
  meta: MatchMetaEntity(/* ... */),
  position: 2,
  createdAt: DateTime.now(),
  isInteractive: true,
  isContentBased: false,
);
```

### Type-Safe Access

```dart
// Type-safe getters
if (exercise.listenChooseMeta != null) {
  final audioUrl = exercise.listenChooseMeta!.audioUrl;
  final options = exercise.listenChooseMeta!.options;
}

// Helper methods
if (exercise.hasAudio) {
  print('Audio URL: ${exercise.audioUrl}');
}

if (exercise.hasOptions) {
  print('Options: ${exercise.options?.join(', ')}');
}

final correctAnswer = exercise.correctAnswer; // Works for most exercise types
```

### Converting from API/Database

```dart
// The fromModel factory automatically converts Map<String, dynamic> meta
// to the appropriate ExerciseMetaEntity subclass based on exerciseType
final exercise = ExerciseEntity.fromModel(apiResponseModel);
```

### Serialization

```dart
// Convert meta back to JSON for API calls
final metaJson = exercise.metaAsJson;
```

## Migration Notes

If you have existing code that uses `Map<String, dynamic>? meta`:

1. **Reading**: Replace `exercise.meta?['key']` with type-safe getters like `exercise.listenChooseMeta?.audioUrl`
2. **Creating**: Use factory constructors or create appropriate meta entities
3. **Serializing**: Use `exercise.metaAsJson` instead of `exercise.meta`

## Files Changed

- `exercise_entity.dart`: Updated to use `ExerciseMetaEntity?` instead of `Map<String, dynamic>?`
- `exercise_meta_entity.dart`: New file containing all meta entity classes
- `entities.dart`: Barrel export file for easy imports
- `exercise_entity_examples.dart`: Usage examples and demonstrations
