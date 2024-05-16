import 'package:achieve_club_mobile_admin/pages/authpage.dart';
import 'package:flutter/material.dart';

var appTitle = 'Авторизация';
var baseURL = 'https://sskef.site/api/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(
        child: AuthPage(),
      ),
    );
  }
}
