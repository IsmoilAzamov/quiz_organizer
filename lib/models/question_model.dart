import '../db/questions.dart';

class QuestionModel   {
  final String questionText;
  final QuestionType questionType;
  final List<QuestionObject>? options;
  List<String> chosenAnswerIds = [];
  String? answerText;

  QuestionModel({required this.questionType, required this.questionText, this.options, this.chosenAnswerIds = const [], this.answerText});
}

class QuestionObjectModel   {
  String id;
  String text;
  bool isTrueAnswer;

  QuestionObjectModel({required this.id, required this.text, this.isTrueAnswer = false});
}
