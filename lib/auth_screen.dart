import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final int points;

  User({required this.id, required this.name, required this.email, required this.points});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'points': points,
      };
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _name = TextEditingController();
  bool isLogin = true;

   void _switchAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://quiz-app-go-backend.onrender.com/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          final user = User.fromJson(userData);

          // Save user data to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(user.toJson()));

          // Navigate to home page
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Show error dialog
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Registration Failed'),
              content: Text('Incorrect email or password.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ),
          );
        }
      } catch (error) {
        // Show error dialog for network issues
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An Error Occurred'),
            content: Text('Could not connect to the server. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        );
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://quiz-app-go-backend.onrender.com/users'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': _name.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 201) {
          final userData = json.decode(response.body);
          final user = User.fromJson(userData);

          // Save user data to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(user.toJson()));

          // Navigate to home page
          Navigator.pushReplacementNamed(context, '/auth');
        } else {
          // Show error dialog
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Registration Failed'),
              content: Text(response.body),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ),
          );
        }
      } catch (error) {
        // Show error dialog for network issues
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An Error Occurred'),
            content: Text('Could not connect to the server. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              !isLogin ? TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Name';
                  }
                  return null;
                },
              ): SizedBox(),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(isLogin
                    ? 'Login'
                    : 'Register'),
                onPressed: isLogin ? _login : _register,
              ),
              TextButton(
                child: Text(isLogin
                    ? 'Create new account'
                    : 'I already have an account'),
                onPressed: _switchAuthMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
