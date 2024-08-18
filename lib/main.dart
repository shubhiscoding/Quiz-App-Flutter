import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/auth_screen.dart';
import 'pages/home_page.dart';
import 'pages/quiz_screen.dart';
import 'pages/history_container.dart';

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
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final prefs = snapshot.data as SharedPreferences;
            final userData = prefs.getString('user');
            if (userData != null) {
              return HomePage();
            } else {
              return AuthScreen();
            }
          }
          return CircularProgressIndicator();
        },
      ),
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomePage(),
        '/quiz': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as int;
          return QuizScreen(userId: userId);
        },
        '/history': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as int;
          return HistoryPage(userId: userId);
        },
      },
    );
  }
}