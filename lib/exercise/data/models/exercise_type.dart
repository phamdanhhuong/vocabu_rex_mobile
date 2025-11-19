enum ExerciseType {
  translate('translate'),
  listenChoose('listen_choose'),
  fillBlank('fill_blank'),
  speak('speak'),
  match('match'),
  multipleChoice('multiple_choice'),
  writingPrompt('writing_prompt'),
  imageDescription('image_description'),
  readComprehension('read_comprehension'),
  podcast('podcast'),
  compareWords('compare_words');

  const ExerciseType(this.value);

  final String value;

  static ExerciseType fromString(String value) {
    return ExerciseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown exercise type: $value'),
    );
  }

  @override
  String toString() => value;
}
