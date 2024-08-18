// lib/leaderboard_container.dart
import 'package:flutter/material.dart';
import '../pages/auth_screen.dart';
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
        users.sort(
            (a, b) => b.points.compareTo(a.points)); // Sort users by points

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
            color: const Color.fromARGB(255, 19, 26, 38),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 20, 25, 37).withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
              children: [
                Container(
                  color: Colors.transparent, // Background color of the container
                  child: Icon(
                    Icons.leaderboard,
                    color: const Color.fromARGB(255, 254, 196, 37), // Color of the icon
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Leaderboard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
              ),
              SizedBox(height: 10),
              ...List.generate(5, (index) {
                if (index >= users.length) return SizedBox.shrink();
                final user = users[index];
                return ListTile(
                  title: Text(
                    '${index + 1}. ${user.name}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white), // Apply the text style here
                  ),
                  trailing: Text(
                    '${user.points} points',
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            Colors.white), // Apply the text style here as well
                  ),
                );
              }),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: const Color.fromARGB(255, 254, 196, 37),
                  ),
                  SizedBox(width: 10),
                  Text(
                  'You are ranked #$currentUserRank',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
