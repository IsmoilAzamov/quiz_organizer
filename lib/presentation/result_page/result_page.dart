import 'package:flutter/material.dart';
import 'package:task/models/question_model.dart';
import 'package:task/presentation/widgrets/text_ixon.dart';

import '../../db/questions.dart';
import '../utils/get_correct_answers_count.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.questions});

  final List<QuestionModel> questions;

  @override
  Widget build(BuildContext context) {
    int correctAnswers = getCorrectAnswersCount(questions);
    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      appBar: AppBar(
        title: const Text('Result', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xff3377f0)),
                ),
                child: Center(
                    child: Text(
                  'You got $correctAnswers correct out of ${questions.length} tests',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff3377f0), fontSize: 18),
                )),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return generateResultWidget(question);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget generateResultWidget(QuestionModel question) {
    switch (question.questionType) {
      case QuestionType.select:
        return generateSelectChoiceResultWidget(question: question, index: questions.indexOf(question) + 1);
      case QuestionType.checkbox:
        return generateSingleChoiceResultWidget(question: question, index: questions.indexOf(question) + 1);
      case QuestionType.input:
        return generateTextResultWidget(question: question, index: questions.indexOf(question) + 1);
      case QuestionType.multiple:
        return generateMultipleChoiceResultWidget(question: question, index: questions.indexOf(question) + 1);
    }
  }

  Widget generateMultipleChoiceResultWidget({required QuestionModel question, required int index}) {
    final chosenAnswers = question.options!.where((element) => question.chosenAnswerIds.contains(element.id)).toList();
    final trueAnswers = question.options!.where((element) => element.isTrueAnswer).toList();
    return Card(
      // Choose your preferred background color
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          //if all the true answers are chosen, the border will be green, otherwise will be red
          border: Border.all(color: chosenAnswers.length == trueAnswers.length && chosenAnswers.every((element) => trueAnswers.contains(element)) ? Colors.green : Colors.red),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Text("$index. ${question.questionText}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options!.length,
              itemBuilder: (context, index) {
                final option = question.options![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: chosenAnswers.contains(option) || trueAnswers.contains(option),
                        // checkBox contains true answer will be green, checkBox contains false answer will be red, otherwise will be white
                        fillColor: option.isTrueAnswer
                            ? MaterialStateProperty.all(Colors.green)
                            : chosenAnswers.contains(option)
                                ? MaterialStateProperty.all(Colors.red)
                                : MaterialStateProperty.all(Colors.white),
                        side: const BorderSide(color: Color(0xff3377f0), width: 2),
                        onChanged: (value) {},
                      ),
                      Expanded(
                        child: Text(option.text),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget generateSingleChoiceResultWidget({required QuestionModel question, required int index}) {
    final chosenAnswer = question.options!.firstWhere((element) => element.id == question.chosenAnswerIds.first);
    final trueAnswer = question.options!.firstWhere((element) => element.isTrueAnswer);
    // only one answer can be chosen, so we don't need to check the type of question
    //use radio button to show the answer
    return Card(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          //if the answer is true, the border will be green, otherwise will be red
          border: Border.all(color: chosenAnswer.isTrueAnswer ? Colors.green : Colors.red),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text("$index. ${question.questionText}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options!.length,
              itemBuilder: (context, index) {
                final option = question.options![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Radio(
                        value: option.id==chosenAnswer.id || option.id==trueAnswer.id,
                        groupValue: true,
                        visualDensity: const VisualDensity(vertical: -4),
                        // radio button contains true answer will be green, radio button contains false answer will be red, otherwise will be white
                        fillColor: option.isTrueAnswer
                            ? MaterialStateProperty.all(Colors.green)
                            : option.id == chosenAnswer.id
                                ? MaterialStateProperty.all(Colors.red)
                                : MaterialStateProperty.all(const Color(0xff3377f0)),
                        onChanged: (value) {},
                      ),
                      Expanded(
                        child: Text(option.text),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget generateSelectChoiceResultWidget({required QuestionModel question, required int index}) {
    final chosenAnswer = question.options!.firstWhere((element) => element.id == question.chosenAnswerIds.first);
    final trueAnswer = question.options!.firstWhere((element) => element.isTrueAnswer);
    // only one answer can be chosen, so we don't need to check the type of question
    //use radio button to show the answer
    return Card(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          //if the answer is true, the border will be green, otherwise will be red
          border: Border.all(color: chosenAnswer.isTrueAnswer ? Colors.green : Colors.red),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text("$index. ${question.questionText}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options!.length,
              itemBuilder: (context, index) {
                final option = question.options![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),

                        child: Icon(
                          option.isTrueAnswer
                              ? Icons.check_circle
                              : option.id == chosenAnswer.id
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline_outlined,
                          color: option.isTrueAnswer
                              ? Colors.green
                              : option.id == chosenAnswer.id
                                  ? Colors.red
                                  : const Color(0xff3377f0),
                        ),
                      ),
                      Expanded(
                        child: Text(option.text),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


//there is only one type of question that is input, so we don't need to check the type of question
  Widget generateTextResultWidget({required QuestionModel question, required int index}) {
    final trueAnswer = question.chosenAnswerIds.first;

    return Card(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          //if the answer is true, the border will be green, otherwise will be red
          border: Border.all(color: question.answerText == trueAnswer ? Colors.green : Colors.red),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text("$index. ${question.questionText}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Row(
                children: [
                  textIcon(color: Colors.green),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(question.answerText!),
                  ),
                ],
              ),
            ),
            if (question.answerText != trueAnswer)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Row(
                  children: [
                    textIcon(color: Colors.red),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(trueAnswer),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
