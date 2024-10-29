import '/pages/authpage.dart';
import 'package:flutter/material.dart';

var appTitle = 'Авторизация';
var baseURL = 'https://achieve.by:5000/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(11, 106, 108, 1.0)),
        useMaterial3: true,
        fontFamily: 'Exo2',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(11, 106, 108, 1.0),
            brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: 'Exo2',
      ),
      home: const AuthPage(),
    );
  }
}
