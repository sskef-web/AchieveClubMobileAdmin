import 'package:achieve_club_mobile_admin/pages/QRViewExample.dart';
import 'package:achieve_club_mobile_admin/main.dart';
import 'package:achieve_club_mobile_admin/pages/usersPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Function() logoutCallback;

  const HomePage({super.key, required this.logoutCallback});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [const QRViewExample(), UsersPage(logoutCallback: widget.logoutCallback,)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(appTitle)),
        leading: SizedBox(
          width: 48.0,
          height: 48.0,
          child: IconButton(
            iconSize: 32.0,
            icon: Transform.rotate(
              angle: 3.14,
              child: const Icon(Icons.logout),
            ),
            onPressed: widget.logoutCallback,
          ),
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
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Cканирование QR-кода',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Пользователи',
          ),
        ],
      ),
    );
  }
}
