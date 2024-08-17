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
          print(res.body);
        }catch(e){
          throw Exception('Failed to start quiz '+ e.toString());
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
    setState(() {
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _score += 2; // Assume each question is worth 2 points for level 1
        _correctAnswers++;
      }
      _currentQuestionIndex++;
    });

    if (_currentQuestionIndex >= _questions.length) {
      await _endGame();
    }
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
        title: Text('Quiz'),
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.text,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return ListTile(
                  title: Text(option),
                  onTap: () => _submitAnswer(index),
                );
              }).toList(),
              if (_isAnswerCorrect)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Correct!',
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                )
              else if (_currentQuestionIndex > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Incorrect!',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
