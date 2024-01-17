import 'package:hive/hive.dart';

part 'questions.g.dart';

@HiveType(typeId: 0)
class Question extends HiveObject {
  @HiveField(0)
  final String questionText;
  @HiveField(1)
  final QuestionType questionType;
  @HiveField(2)
  final List<QuestionObject>? options;
  @HiveField(3)
  @HiveField(4)
  String? answerText;

  Question({required this.questionType, required this.questionText, this.options, this.answerText});
}

@HiveType(typeId: 1)
class QuestionObject extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String text;
  @HiveField(2)
  bool isTrueAnswer;

  QuestionObject({required this.id, required this.text, this.isTrueAnswer = false});
}

@HiveType(typeId: 2)
enum QuestionType {
  @HiveField(0)
  checkbox,
  @HiveField(1)
  multiple,
  @HiveField(2)
  input,
  @HiveField(3)
  select,
}
