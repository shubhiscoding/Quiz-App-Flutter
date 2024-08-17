// lib/user_info_container.dart
import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Import the User class

class UserInfoContainer extends StatelessWidget {
  final User user;
  final VoidCallback onStartQuiz;

  UserInfoContainer({required this.user, required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${user.name}!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                'Points: ${user.points}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: onStartQuiz,
                child: Text('Start Quiz'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: onStartQuiz,
                child: Text('History'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
