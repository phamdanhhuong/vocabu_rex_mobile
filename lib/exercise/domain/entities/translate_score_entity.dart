import 'package:equatable/equatable.dart';

class TranslateScoreEntity extends Equatable {
  final bool isCorrect;
  final String feedback;

  const TranslateScoreEntity({required this.isCorrect, required this.feedback});

  @override
  List<Object?> get props => [isCorrect, feedback];
}
