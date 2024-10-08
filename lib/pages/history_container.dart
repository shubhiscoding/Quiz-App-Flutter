import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Class/game.dart';

class HistoryPage extends StatefulWidget {
  final int userId;

  HistoryPage({required this.userId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = fetchGames();
  }

  Future<List<Game>> fetchGames() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://quiz-app-go-backend.onrender.com//games?id=${widget.userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> gameData = json.decode(response.body);
        return gameData.map((json) => Game.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load games');
      }
    } catch (error) {
      print(error);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 36, 52),
      appBar: AppBar(
        title: Text('History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 26, 38),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Game>>(
        future: _gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No game history available'));
          }

          final games = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 19, 26, 38),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 20, 25, 37).withOpacity(0.5)
                          .withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    'Game ${index + 1}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Accuracy: ${game.gamePoint}%\nPoints: ${game.point}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  trailing: Text(
                    '🎯', // Target emoji
                    style: TextStyle(
                      fontSize: 40, // Adjust size as needed
                      color: Colors.white, // Adjust color if needed
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
