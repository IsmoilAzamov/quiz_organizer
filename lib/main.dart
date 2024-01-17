import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task/presentation/home_page.dart';

import 'db/questions.dart';

late Box box;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();


  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(QuestionObjectAdapter());
  Hive.registerAdapter(QuestionTypeAdapter());
  box = await Hive.openBox('box');
  await generateBaseQuestions();
  runApp(const MyApp());
}

 generateBaseQuestions()async {
  await Future.delayed(const Duration(seconds: 1));
  List<Question> questions= [
    Question(
        questionText: 'Which framework use dart?',
        questionType: QuestionType.checkbox,
        options: [QuestionObject(id: '1', text: 'Flutter',isTrueAnswer: true), QuestionObject( id: '2', text: 'Angular'), QuestionObject(id: '3', text: 'React'), QuestionObject( id: '4', text: 'Vue')]),
    Question(
        questionText: 'Dart is an?',
        questionType: QuestionType.multiple,
        options: [QuestionObject(id: '1', text: 'Object-oriented',isTrueAnswer: true), QuestionObject(isTrueAnswer: true, id: '2', text: 'Client-optimized'), QuestionObject(id: '3', text: 'Multi Threaded'), QuestionObject(isTrueAnswer: true, id: '4', text: 'AOT-compiled')]),
    Question( questionText: 'Dart is originally developed by', questionType: QuestionType.checkbox, options: [QuestionObject(id: '1', text: 'Google', isTrueAnswer: true), QuestionObject(id: '2', text: 'Facebook'), QuestionObject(id: '3', text: 'Microsoft'), QuestionObject(id: '4', text: 'Apple')]),
    Question( questionText: "Dart numbers come in two flavors:", questionType: QuestionType.multiple, options: [QuestionObject(id: '1', text: 'int', isTrueAnswer: true), QuestionObject(id: '2', text: 'double', isTrueAnswer: true), QuestionObject(id: '3', text: 'num'), QuestionObject(id: '4', text: 'float')]),
    Question( questionText: "What is the extension of dart file?", questionType: QuestionType.select, options: [QuestionObject(id: '1', text: '.dart', isTrueAnswer: true), QuestionObject(id: '2', text: '.js'), QuestionObject(id: '3', text: '.java'), QuestionObject(id: '4', text: '.kt')]),
    Question( questionText: "The package import pub command is", questionType: QuestionType.input, answerText: 'pub get'),
  ];
  box.put('questions', questions);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: ThemeData(
        hintColor: Colors.grey,
        cardTheme: const CardTheme(
          color: Colors.white, // The background color for Material cards
        ),
        indicatorColor: const Color(0xff3377f0), // The color of the selected tab indicator in a tab bar
        scaffoldBackgroundColor: Colors.white, // The default color for the Material Scaffold background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // The background color for app bars
        ),
        cardColor: Colors.white, // The background color for cards
      ),
      home: const HomePage(),
    );
  }
}
