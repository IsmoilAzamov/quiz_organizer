import 'package:flutter/material.dart';

import '../../db/questions.dart';
import '../../main.dart';
import '../widgrets/text_ixon.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  AddQuestionPageState createState() => AddQuestionPageState();
}

class AddQuestionPageState extends State<AddQuestionPage> {
  QuestionType questionType = QuestionType.checkbox;
  TextEditingController questionTextController = TextEditingController();
  List<QuestionObject> selectOptions = [];
  List<QuestionObject> checkboxOptions = [];
  List<QuestionObject> multipleOptions = [];
  String? answerText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      appBar: AppBar(
        title: const Text('Add Question', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              bool isFormValid = true;
              switch (questionType) {
                case QuestionType.select:
                  if (selectOptions.where((element) => element.isTrueAnswer).toList().isEmpty) {
                    isFormValid = false;
                    customAlertDialog('True answer must not be empty');
                  }
                  break;
                case QuestionType.checkbox:
                  if (checkboxOptions.where((element) => element.isTrueAnswer).toList().isEmpty) {
                    isFormValid = false;
                    customAlertDialog('There must be at least one true answer');
                  }
                  break;
                case QuestionType.input:
                  if (answerText == null || answerText!.isEmpty) {
                    isFormValid = false;
                    customAlertDialog('Answer text must not be empty');
                  }
                  break;
                case QuestionType.multiple:
                  if (multipleOptions.where((element) => element.isTrueAnswer).toList().isEmpty) {
                    isFormValid = false;
                    customAlertDialog("There must be at least one true answer");
                  }
                  break;
              }
              // if question text is empty then show error
              if (questionTextController.text.trim().isEmpty && isFormValid) {
                isFormValid = false;
                customAlertDialog('Question text must not be empty');
              }

              //save question to hive
              if (isFormValid) {
                final question = Question(
                  questionType: questionType,
                  questionText: questionTextController.text.trim(),

                  options: getOptions(questionType),
                  answerText: answerText,
                );
                box.put('questions', [...box.get('questions', defaultValue: <Question>[]) as List<Question>, question]);
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.done, color: Color(0xff3377f0), size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: questionTextController,
                        decoration: const InputDecoration(
                          hintText: 'Text of question',
                          hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff3377f0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      //select question type from dropdown
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xff3377f0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<QuestionType>(
                                  value: questionType,
                                  dropdownColor: const Color(0xffd6e6f0),
                                  borderRadius: BorderRadius.circular(12.0),
                                  elevation: 0,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  iconEnabledColor: const Color(0xff3377f0),
                                  onChanged: (value) {
                                    setState(() {
                                      questionType = value!;
                                    });
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: QuestionType.checkbox,
                                      child: Text("checkbox"),
                                    ),
                                    DropdownMenuItem(
                                      value: QuestionType.multiple,
                                      child: Text("multiple"),
                                    ),
                                    DropdownMenuItem(
                                      value: QuestionType.input,
                                      child: Text("input"),
                                    ),
                                    DropdownMenuItem(
                                      value: QuestionType.select,
                                      child: Text("select"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: IconButton(
                              onPressed: () {
                                //show dialog to add options
                                addOptionDialog();
                              },
                              icon: const Icon(Icons.add, size:28, color: Color(0xff3377f0)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                //options
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: questionType != QuestionType.input
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: getOptions(questionType).length,
                            itemBuilder: (context, index) {
                              final option = getOptions(questionType)[index];
                              return generateOptionsCard(option: option);
                            },
                          )
                        : answerText != null
                            ? generateTextInputCard(answerText: answerText ?? "")
                            : const SizedBox(),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void addOptionDialog() {
    TextEditingController textController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'The answer is incomplete';
                    }
                    return null; // Return null if the input is valid
                  },
                  style: const TextStyle(color: Colors.black),
                  // Set text color

                  decoration: const InputDecoration(
                      hintText: 'Text of answer',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
                      errorStyle: TextStyle(color: Colors.red),
                      // Set text color for the error message
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff3377f0)),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff3377f0)),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff3377f0)),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      filled: true,
                      focusColor: Colors.white,
                      fillColor: Colors.white),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.maxFinite,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        String optionText = textController.text.trim();
                        setState(() {
                          switch (questionType) {
                            case QuestionType.select:
                              selectOptions.add(QuestionObject(id: selectOptions.length.toString(), text: optionText, isTrueAnswer: false));
                              break;
                            case QuestionType.checkbox:
                              checkboxOptions.add(QuestionObject(id: checkboxOptions.length.toString(), text: optionText, isTrueAnswer: false));
                              break;
                            case QuestionType.input:
                              {
                                answerText = optionText;
                              }
                              break;
                            case QuestionType.multiple:
                              multipleOptions.add(QuestionObject(id: multipleOptions.length.toString(), text: optionText, isTrueAnswer: false));
                              break;
                          }
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget generateOptionsCard({required QuestionObject option}) {
    late Widget optionCard;
    switch (questionType) {
      case QuestionType.select:
        optionCard = generateSingleChoiceOptionCard(option: option);
      case QuestionType.checkbox:
        optionCard = generateCheckBoxOptionCard(option: option);
      case QuestionType.input:
        optionCard = generateTextInputCard(answerText: answerText ?? "");
      case QuestionType.multiple:
        optionCard = generateMultipleChoiceOptionCard(option: option);
    }
    return optionCard;
  }

  getOptions(QuestionType questionType) {
    switch (questionType) {
      case QuestionType.select:
        return selectOptions;
      case QuestionType.checkbox:
        return checkboxOptions;
      case QuestionType.input:
        return null;
      case QuestionType.multiple:
        return multipleOptions;
    }
  }

  Widget generateCheckBoxOptionCard({required QuestionObject option}) {
    // radio button contains true answer will be checked, radio button contains false answer will be unchecked
    //trailing is remove button
    return Row(
      children: [
        Radio(
          value: option.isTrueAnswer,
          groupValue: true,
          onChanged: (value) {
            setState(() {
              for (var element in checkboxOptions) {
                element.isTrueAnswer = false;
              }
              option.isTrueAnswer = true;
            });
          },
        ),
        Expanded(
          child: Text(option.text),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              checkboxOptions.remove(option);
            });
          },
          icon: const Icon(Icons.delete_forever, color: Colors.red),
        ),
      ],
    );
  }

  Widget generateSingleChoiceOptionCard({required QuestionObject option}) {
    //like checkbox but radio button but at center check icon appears instead of filled circle
    return Row(children: [
      //select icon
      IconButton(
        onPressed: () {
          setState(() {
            for (var element in selectOptions) {
              element.isTrueAnswer = false;
            }
            option.isTrueAnswer = true;

          });
        },
        icon: Icon(option.isTrueAnswer ? Icons.check_circle : Icons.check_circle_outline, color: const Color(0xff3377f0)),
      ),
      Expanded(
        child: Text(option.text),
      ),
      IconButton(
        onPressed: () {
          setState(() {
            selectOptions.remove(option);
          });
        },
        icon: const Icon(Icons.delete_forever, color: Colors.red),
      ),
    ]);
  }

  Widget generateTextInputCard({required String answerText}) {
    //there is only text and leading icon if option changes the answer will be changed
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          textIcon(color: const Color(0xff3377f0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(answerText),
          ),
        ],
      ),
    );
  }

  Widget generateMultipleChoiceOptionCard({required QuestionObject option}) {
    // checkboxes contains true answers will be checked, checkbox contains false answer will be unchecked
    //trailing is remove button
    return Row(
      children: [
        Checkbox(
          value: option.isTrueAnswer,
          checkColor: Colors.white,
          activeColor: const Color(0xff3377f0),
          side: const BorderSide(color: Color(0xff3377f0), width: 2),
          onChanged: (value) {
            setState(() {
              option.isTrueAnswer = value!;
            });
          },
        ),
        Expanded(
          child: Text(option.text),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              multipleOptions.remove(option);
            });
          },
          icon: const Icon(Icons.delete_forever, color: Colors.red),
        ),
      ],
    );
  }

  void customAlertDialog(String s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(s),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
