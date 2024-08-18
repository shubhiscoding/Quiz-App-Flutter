// lib/models.dart
class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['questionText'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
    );
  }
}
