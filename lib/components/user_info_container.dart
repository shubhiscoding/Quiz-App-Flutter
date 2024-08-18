import 'package:flutter/material.dart';
import '../pages/auth_screen.dart'; // Import the User class
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfoContainer extends StatefulWidget {
  final User user;

  UserInfoContainer({required this.user});

  @override
  _UserInfoContainerState createState() => _UserInfoContainerState();
}

class _UserInfoContainerState extends State<UserInfoContainer> {
  late Future<User> _userDetails;

  @override
  void initState() {
    super.initState();
    _userDetails = fetchUserDetails(widget.user.id);
  }

  void onStartQuiz() {
    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: widget.user.id,
    );
  }

  void onHistory() {
    Navigator.pushNamed(
      context,
      '/history',
      arguments: widget.user.id,
    );
  }

  Future<User> fetchUserDetails(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://quiz-app-go-backend.onrender.com/users/user?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to fetch user details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final user = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 19, 26, 38),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 20, 25, 37).withOpacity(0.5),
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
                    '👋 Welcome, ${user.name}!',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '🏆 Points: ${user.points}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: onStartQuiz,
                    child: Text('Start Quiz', style: TextStyle(color: const Color.fromARGB(255, 19, 26, 38), fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: onHistory,
                    child: Text('History', style: TextStyle(color: const Color.fromARGB(255, 19, 26, 38), fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
