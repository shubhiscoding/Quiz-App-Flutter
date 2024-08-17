// lib/leaderboard_container.dart
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardContainer extends StatefulWidget {
  final User currentUser;

  LeaderboardContainer({required this.currentUser});

  @override
  _LeaderboardContainerState createState() => _LeaderboardContainerState();
}

class _LeaderboardContainerState extends State<LeaderboardContainer> {
  late Future<List<User>> _usersFuture;
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://quiz-app-go-backend.onrender.com/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> userData = json.decode(response.body);
        return userData.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      print(error);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        users = snapshot.data ?? [];
        users.sort((a, b) => b.points.compareTo(a.points)); // Sort users by points

        int currentUserRank = 0;
        for (int i = 0; i < users.length; i++) {
          if (users[i].id == widget.currentUser.id) {
            currentUserRank = i + 1;
            break;
          }
        }

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
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...List.generate(5, (index) {
                if (index >= users.length) return SizedBox.shrink();
                final user = users[index];
                return ListTile(
                  title: Text('${index + 1}. ${user.name}'),
                  trailing: Text('${user.points} points'),
                );
              }),
              SizedBox(height: 20),
              if (users.isNotEmpty && currentUserRank >= 6)
                Text(
                  'You are ranked #$currentUserRank',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        );
      },
    );
  }
}
