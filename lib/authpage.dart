import 'dart:convert';

import 'package:achieve_club_mobile_admin/QRViewExample.dart';
import 'package:achieve_club_mobile_admin/validatedTextField.dart';
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

  Future<void> _onLogin() async {
    var url = Uri.https('sskef.site', 'api/auth/login');
    debugPrint(url.toString());
    var headers = {
    'Content-Type': 'application/json',
    };
    var body = jsonEncode({"email": _email, "password": _password});
    var response =
        await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      debugPrint(response.headers['set-cookie']!);
      await saveCookies(response.headers["set-cookie"]!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const QRViewExample(),
        ),
      );
    } else
      {
        throw Exception(response.body);
      }
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  ValidatedTextField(
                    placeholder: "Email",
                    value: _email,
                    onChanged: (value) => setState(() {
                      _email = value;
                    }),
                  ),
                  ValidatedTextField(
                    placeholder: "Password",
                    value: _password,
                    onChanged: (value) => setState(() {
                      _password = value;
                    }),
                  ),
                ],
              ),
            ),
            FilledButton(onPressed: _onLogin, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
