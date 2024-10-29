import 'dart:convert';
import '/data/user.dart';
import '/items/userItem.dart';
import '/main.dart';
import '/pages/authpage.dart';
import '/pages/currentUserPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsersPage extends StatefulWidget {
  final Function() logoutCallback;

  const UsersPage({super.key, required this.logoutCallback});

  @override
  _UsersPage createState() => _UsersPage();
}

class _UsersPage extends State<UsersPage> {

  @override
  void initState() {
    super.initState();
  }

  void navigateToUserPage(int userId, String firstName, String lastName, String avatarPath, String clubName, String clubLogo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserPage(
              userId: userId,
              firstName: firstName,
              lastName: lastName,
              avatarPath: avatarPath,
              clubLogo: clubLogo,
              clubName: clubName,
              logoutCallback: widget.logoutCallback,
              updateUsers: updatePage,
            ),
      ),
    );
  }

  Future<List<User>> fetchUsers() async {
    var url = Uri.parse('${baseURL}api/users/all');

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

  void updatePage() async {
    await fetchUsers();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
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
                          onTap: () {
                            navigateToUserPage(user.id, user.firstName, user.lastName, user.avatar, user.clubLogo, user.clubName);
                          },
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
