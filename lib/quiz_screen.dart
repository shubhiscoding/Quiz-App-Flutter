import 'package:flutter/material.dart';
import 'question.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  QuizScreen({required this.questions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;

  void answerQuestion(int selectedIndex) {
    if (selectedIndex == widget.questions[currentQuestionIndex].correctAnswerIndex) {
      score++;
    }

    setState(() {
      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // Quiz finished, show result
        showResult();
      }
    });
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Finished'),
          content: Text('Your score: $score / ${widget.questions.length}'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.questions[currentQuestionIndex].questionText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...widget.questions[currentQuestionIndex].options.asMap().entries.map((entry) {
              return ElevatedButton(
                child: Text(entry.value),
                onPressed: () => answerQuestion(entry.key),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}