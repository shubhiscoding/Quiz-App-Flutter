// lib/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'question.dart'; // Ensure this is your Question model

class QuizScreen extends StatefulWidget {
  final int userId;

  QuizScreen({required this.userId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Map<String, dynamic>> _quizFuture;
  List<Question> _questions = []; // Initialize with an empty list
  late int _gameId;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _quizFuture = fetchQuiz();
  }

  Future<Map<String, dynamic>> fetchQuiz() async {
    try {
      final response = await http.post(
        Uri.parse('https://quiz-app-go-backend.onrender.com/games'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'level': 1}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Check----------------------------------------------------------------");
        print(data);

        setState(() {
          _gameId = data['game']['id'];
          final questionsData = data['questions'] as List;
          _questions = questionsData.map((json) => Question.fromJson(json)).toList();
        });
        try{
          final res = await http.post(
            Uri.parse('https://quiz-app-go-backend.onrender.com/user-games'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({'user_id': widget.userId, 'game_id': _gameId}),
          );
          if(res.statusCode == 200){
            print("User game created");
          }else{
            throw Exception('Failed to start quiz '+res.body);
          }
        }catch(e){
          return {};
        }
        return data;
      } else {
        throw Exception('Failed to load quiz');
      }
    } catch (error) {
      print(error);
      return {};
    }
  }

  void _submitAnswer(int selectedIndex) async {
   final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question.correctAnswerIndex;
    if (isCorrect) {
      _score += 2; // Assume each question is worth 2 points for level 1
      _correctAnswers++;
    }

    // Show explanation dialog
    await _showExplanationDialog(isCorrect, question.explanation);

    setState(() {
      _currentQuestionIndex++;
    });

    if (_currentQuestionIndex >= _questions.length) {
      await _endGame();
    }
  }

  Future<void> _showExplanationDialog(bool isCorrect, String explanation) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isCorrect ? 'Correct!' : 'Incorrect',
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explanation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(explanation),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _endGame() async {
    final totalPoints = _questions.length * 2; // 2 points per question
    final gamePoints = (_correctAnswers / _questions.length) * 100;
    final roundedGamePoints = double.parse(gamePoints.toStringAsFixed(2)).toInt();

    try {
      final response = await http.post(
        Uri.parse('https://quiz-app-go-backend.onrender.com/game-end'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'game_id': _gameId,
          'point': _score,
          'gamePoint': roundedGamePoints,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.popAndPushNamed(context, '/home');
      } else {
        throw Exception('Failed to end game '+response.body+' '+_gameId.toString());
      }
    } catch (error) {
      print(error);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Quiz', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (_questions.isEmpty) {
          return Center(child: Text('No questions available'));
        }

        if (_currentQuestionIndex >= _questions.length) {
          return Center(child: Text('Quiz finished'));
        }

        final question = _questions[_currentQuestionIndex];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    question.text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ElevatedButton(
                    child: Text(
                      option,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _submitAnswer(index),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    ),
  );
}
}
