import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class RoleButton extends StatefulWidget {
  final int userId;

  const RoleButton ({
    super.key,
    required this.userId
  });

  @override
  _RoleButtonState createState() => _RoleButtonState();
}

class _RoleButtonState extends State<RoleButton> {
  String _selectedRole = 'Студент';

  Future<String?> loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookies');
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }

  Future<void> refreshToken() async {
    var refreshUrl = Uri.parse('${baseURL}auth/refresh');
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

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Студент"), value: "Студент"),
      DropdownMenuItem(child: Text("Тренер"), value: "Тренер"),
      DropdownMenuItem(child: Text("Админ"), value: "Админ"),
    ];
    return menuItems;
  }

  Future<bool> checkUserRole() async {
    var url = Uri.parse('${baseURL}ping/admin');
    var cookies = await loadCookies();

    var response = await http.get(url, headers: {
      'Cookie': cookies!,
    });

    debugPrint('Check user role response - ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    }
    else {
      await refreshToken();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Ошибка'),
              SizedBox(height: 16.0,),
              Text('Попробуйте заново')
              ],
          );
        }
      );
      return false;
    }
  }


  void changeRole(int userId) async {
    int roleId;
    switch (_selectedRole) {
      case "Студент":
        roleId = 1;
        break;
      case "Тренер":
        roleId = 3;
        break;
      case "Админ":
        roleId = 2;
        break;
      default:
        return;
    }

    var cookies = await loadCookies();

    var body = jsonEncode({
      "userId": userId,
      "roleId": roleId,
    });

    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Cookie': cookies!,
    };


    var response = await http.patch(
      Uri.parse('${baseURL}users/change_role'), headers: headers, body: body,
    );

    if (response.statusCode == 200) {
      debugPrint('Role changed successfully');
    } else {
      debugPrint('Failed to change role. Status code: ${response.statusCode}, ${response.body}');
    }
  }

  void _showRoleDialog() async {
    bool access = await checkUserRole();

    if (access) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Выберите роль"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile<String>(
                      title: Text("Студент"),
                      value: "Студент",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text("Тренер"),
                      value: "Тренер",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text("Админ"),
                      value: "Админ",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            changeRole(widget.userId);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(
                                color: Color.fromRGBO(252, 105, 105, 1.0)),
                          )),
                      const SizedBox(
                        width: 8.0,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Отменить',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  )
                ],
              );
            },
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Ошибка доступа"),
            content: const Text(
                'Смена ролей пользователей доступна только для администратора.'),
            actions: <Widget>[
              TextButton(
                child: const Text("Закрыть"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 50,
      child: OutlinedButton(
        onPressed: _showRoleDialog,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text('Изменить роль')],
        ),
      ),
    );
  }
}
