import 'package:flutter/material.dart';
import 'question.dart';
import 'quiz_screen.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Quiz App!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Start Quiz'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(questions: questions),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final List<Question> questions = [
  Question(
    questionText: "What is the capital of France?",
    options: ["London", "Berlin", "Paris", "Madrid"],
    correctAnswerIndex: 2,
  ),
  Question(
    questionText: "Which planet is known as the Red Planet?",
    options: ["Mars", "Jupiter", "Venus", "Saturn"],
    correctAnswerIndex: 0,
  ),
  Question(
    questionText: "What is the largest mammal in the world?",
    options: ["Elephant", "Blue Whale", "Giraffe", "Hippopotamus"],
    correctAnswerIndex: 1,
  ),
];