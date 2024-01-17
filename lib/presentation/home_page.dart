import 'package:flutter/material.dart';
import 'package:task/db/questions.dart';
import 'package:task/models/question_model.dart';
import 'package:task/presentation/result_page/result_page.dart';

import '../main.dart';
import 'add_question_page/add_question_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Question> questionsDB = [];
  List<QuestionModel> questions = [];
  bool allQuestionsAnswered = false;

  @override
  void initState() {
    questionsDB = box.get('questions', defaultValue: <Question>[]) ?? [];
    initializeQuestions();
    super.initState();
  }

  initializeQuestions() {
    questions = questionsDB.map((e) {
      return QuestionModel(
        questionText: e.questionText,
        questionType: e.questionType,
        options: e.options,
        chosenAnswerIds: [],
        answerText: e.answerText,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    allQuestionsAnswered = questions.every((element) => element.chosenAnswerIds.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xffeeeeee),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffffffff),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestionPage())).then((value) {
            setState(() {
              questionsDB = box.get('questions', defaultValue: <Question>[]) ?? [];
              initializeQuestions();
            });
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return getQuestionWidget(questions[index]);
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                    onPressed: () {
                      for (int i = 0; i < questions.length; i++) {
                        print(questions[i].chosenAnswerIds);
                      }
                      if (questions.every((element) => element.chosenAnswerIds.isNotEmpty == true)) {
                        print("All questions answered");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResultPage(
                                      questions: questions,
                                    ))).then((value) {
                          setState(() {
                            initializeQuestions();
                          });
                        });
                      } else {
                        print("All questions not answered");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: allQuestionsAnswered ? const Color(0xff3377f0) : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        minimumSize: Size(MediaQuery.of(context).size.width, 50.0)),
                    child: const Text('Submit', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getQuestionWidget(QuestionModel question, {int? index}) {
    switch (question.questionType) {
      case QuestionType.checkbox:
        return radioQuestion(question: question, index: questions.indexOf(question) + 1);
      case QuestionType.input:
        return inputQuestion(question: question, index: questions.indexOf(question) + 1);
      case QuestionType.multiple:
        return checkboxQuestion(question: question, index: questions.indexOf(question) + 1);
      case QuestionType.select:
        return selectQuestion(question: question, index: questions.indexOf(question) + 1);
    }
  }

  Widget checkboxQuestion({required QuestionModel question, required int index}) {
    return Card(
      elevation: 1.0,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Text(
                "${index}.  ${question.questionText}",
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Column(
              children: [
                for (int index = 0; index < question.options!.length; index++)
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    value: question.chosenAnswerIds.contains(question.options![index].id),
                    controlAffinity: ListTileControlAffinity.leading,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    activeColor: const Color(0xff3377f0),
                    side: const BorderSide(color: Color(0xff3377f0), width: 2.0),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          question.chosenAnswerIds = [...question.chosenAnswerIds, question.options![index].id];
                        } else {
                          question.chosenAnswerIds.remove(question.options![index].id);
                        }
                      });
                      print("1");
                      print(question.chosenAnswerIds);
                    },
                    title: Text(
                      question.options![index].text,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget inputQuestion({required QuestionModel question, required int index}) {
    TextEditingController controller = TextEditingController();
    controller.text = question.chosenAnswerIds.isNotEmpty == true ? question.chosenAnswerIds.first : "";
    return Card(
      elevation: 1.0,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Text(
                "${index}.  ${question.questionText}",
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: controller,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: "Answer of the question",
                  hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Color(0xff3377f0), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Color(0xff3377f0), width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Color(0xff3377f0), width: 1.0),
                  ),
                ),
                onChanged: (value) {
                  if (controller.text.isNotEmpty) {
                      question.chosenAnswerIds = [controller.text];
                  } else {
                      question.chosenAnswerIds = [];
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget radioQuestion({required QuestionModel question, required int index}) {
    return Card(
      elevation: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Text(
                "${index}.  ${question.questionText}",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: [
                for (int index = 0; index < question.options!.length; index++)
                  RadioListTile(
                    value: question.options![index].id,
                    groupValue: question.chosenAnswerIds.isNotEmpty == true ? question.chosenAnswerIds.first : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    fillColor: MaterialStateProperty.all(const Color(0xff3377f0)),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        question.chosenAnswerIds = [];
                        question.chosenAnswerIds.add(value!);
                      });
                      print(question.chosenAnswerIds);
                    },
                    title: Text(question.options![index].text, style: const TextStyle(fontSize: 14.0)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //select from dropdown

  Widget selectQuestion({required QuestionModel question, required int index}) {
    return Card(
      elevation: 1.0,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index}.  ${question.questionText}",
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff3377f0)),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: question.chosenAnswerIds.isNotEmpty == true ? question.chosenAnswerIds.first : null,
                  dropdownColor: const Color(0xffd6e6f0),
                  borderRadius: BorderRadius.circular(12.0),
                  elevation: 0,
                  iconEnabledColor: const Color(0xff3377f0),
                  hint: const Text(
                    'Select',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  onChanged: (value) {
                    setState(() {
                      question.chosenAnswerIds = [];
                      question.chosenAnswerIds.add(value!);
                    });
                    print(question.chosenAnswerIds);
                  },
                  items: question.options!.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(
                        e.text,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
