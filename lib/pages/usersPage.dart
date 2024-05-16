import 'dart:convert';

import 'package:achieve_club_mobile_admin/data/user.dart';
import 'package:achieve_club_mobile_admin/items/userItem.dart';
import 'package:achieve_club_mobile_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPage createState() => _UsersPage();
}

class _UsersPage extends State<UsersPage> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    var url = Uri.parse('${baseURL}users');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<User> users = [];
      for (final userData in data) {
        users.add(User.fromJson(userData));
      }
      return users;
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> users = snapshot.data!;
            users.sort((a, b) => b.xpSum.compareTo(a.xpSum));
            users = users.take(100).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        User user = users[index];

                        return UserItem(
                          onTap: null,
                          firstName: user.firstName,
                          lastName: user.lastName,
                          avatarPath: user.avatar,
                          userXP: user.xpSum,
                          clubLogo: user.clubLogo,
                          topPosition: index + 1,
                          id: user.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center (child:CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
