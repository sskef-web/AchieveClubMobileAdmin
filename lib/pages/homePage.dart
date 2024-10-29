import '/pages/AchievementEdit/achievementsPage.dart';

import '/pages/QRViewExample.dart';
import '/main.dart';
import '/pages/usersPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final Function() logoutCallback;

  HomePage({super.key, required this.logoutCallback});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool isAccess = false;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    checkAccess();
    _tabs = [
      const QRViewExample(),
      UsersPage(logoutCallback: widget.logoutCallback,),
      AchievementsPage()
    ];
  }

  Future<void> refreshToken() async {
    var refreshUrl = Uri.parse('${baseURL}api/auth/refresh');
    var cookies = await loadCookies();

    var response = await http.get(refreshUrl, headers: {
      'Cookie': cookies!,
    });

    if (response.statusCode == 200) {
      var newCookies = response.headers['set-cookie'];
      if (newCookies != null) {
        await saveCookies(newCookies);
        debugPrint('Refresh token done - ${response.statusCode}');
      }
    } else {
      throw Exception(
          'Failed to refresh Token (StatusCode: ${response.statusCode})\n${response.body}');
    }
  }

  Future<String?> loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookies');
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }

  void checkAccess() async{
    isAccess = await checkUserRole();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    widget.logoutCallback();
    setState(() {
      appTitle = 'Авторизация';
    });
  }

  Future<bool> checkUserRole() async {
    var url = Uri.parse('${baseURL}api/ping/admin');
    var cookies = await loadCookies();

    var response = await http.get(url, headers: {
      'Cookie': cookies!,
    });

    debugPrint('Check user role response - ${response.statusCode}');
    if (response.statusCode == 200) {
      setState(() {
        isAccess = true;
      });
      return true;
    }
    else {
      await refreshToken();
      await checkUserRole();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          appTitle,
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          iconSize: 32.0,
          icon: Transform.rotate(
            angle: 3.14,
            child: const Icon(Icons.logout),
          ),
          onPressed: () {
            widget.logoutCallback();
          },
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            switch (_currentIndex) {
              case 0:
                appTitle = 'Сканирование QR-кода';
                break;
              case 1:
                appTitle = 'Пользователи';
                break;
              case 2:
                appTitle = 'Достижения';
                break;
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Сканер QR-кодов',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Пользователи',
          ),
          if (isAccess)
            BottomNavigationBarItem(
              icon: Icon(Icons.accessible),
              label: 'Достижения',
            ),
        ],
      ),
    );
  }
}
