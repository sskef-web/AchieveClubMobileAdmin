import 'dart:convert';

import 'package:achieve_club_mobile_admin/pages/homePage.dart';
import 'package:achieve_club_mobile_admin/pages/loginPage.dart';
import 'package:achieve_club_mobile_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _email = "";
  String _password = "";
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _updateEmail(String value) {
    setState(() {
      _email = value;
    });
  }

  void _updatePassword(String value) {
    setState(() {
      _password = value;
    });
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _onLogin() async {
    var url = Uri.https('sskef.site', 'api/auth/login');
    debugPrint(url.toString());
    var headers = {
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({"email": _email, "password": _password});
    var response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      debugPrint(response.headers['set-cookie']!);
      await saveCookies(response.headers["set-cookie"]!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePage(
            logoutCallback: _logout,
          ),
        ),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      setState(() {
        _isLoggedIn = true;
      });
    } else {
      throw Exception(response.body);
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    setState(() {
      _isLoggedIn = false;
      appTitle = 'Авторизация';
    });
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return HomePage(logoutCallback: _logout);
    } else {
      return LoginPage(
        loginCallback: _onLogin,
        updateEmail: _updateEmail,
        updatePassword: _updatePassword,
        email: _email,
        password: _password,
      );
    }
  }
}
