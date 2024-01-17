import 'package:task/models/question_model.dart';

import '../../db/questions.dart';

int getCorrectAnswersCount(List<QuestionModel> questions) {
  int correctAnswers = 0;
  for (final question in questions) {
    switch (question.questionType) {
      case QuestionType.select:
        final chosenAnswer = question.options!.firstWhere((element) => element.id == question.chosenAnswerIds.first);
        if (chosenAnswer.isTrueAnswer) {
          correctAnswers++;
        }
        break;
      case QuestionType.checkbox:
        final chosenAnswers = question.options!.where((element) => question.chosenAnswerIds.contains(element.id)).toList();
        final trueAnswers = question.options!.where((element) => element.isTrueAnswer).toList();
        if (chosenAnswers.length == trueAnswers.length && chosenAnswers.every((element) => trueAnswers.contains(element))) {
          correctAnswers++;
        }
        break;
      case QuestionType.input:
        if (question.answerText==question.chosenAnswerIds.first) {
          correctAnswers++;
        }
        break;
      case QuestionType.multiple:
        final chosenAnswers = question.options!.where((element) => question.chosenAnswerIds.contains(element.id)).toList();
        final trueAnswers = question.options!.where((element) => element.isTrueAnswer).toList();
        if (chosenAnswers.length == trueAnswers.length && chosenAnswers.every((element) => trueAnswers.contains(element))) {
          correctAnswers++;
        }
        break;
    }
  }
  return correctAnswers;
}