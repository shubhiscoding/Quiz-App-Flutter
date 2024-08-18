// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_screen.dart';
import '../components/leaderboard_container.dart'; // Import the new component
import '../components/user_info_container.dart';

class HomePage extends StatelessWidget {
  Future<User?> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 26, 38),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await SharedPreferences.getInstance()
                ..clear();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(
            255, 30, 36, 52), // Set the background color hereR
        child: Center(
          child: FutureBuilder<User?>(
            future: _getUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final user = snapshot.data;
              if (user == null) {
                return Text('No user data found');
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserInfoContainer(user: user),
                  LeaderboardContainer(currentUser: user),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
