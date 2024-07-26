import 'package:achieve_club_mobile_admin/data/achievement.dart';
import 'package:achieve_club_mobile_admin/data/completedAchievements.dart';
import 'package:achieve_club_mobile_admin/items/achievementItem.dart';
import 'package:achieve_club_mobile_admin/main.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;
  final String avatarPath;
  final String clubLogo;
  final String clubName;
  final Function() logoutCallback;
  final Function() updateUsers;

  const UserPage({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.avatarPath,
    required this.clubLogo,
    required this.clubName,
    required this.logoutCallback,
    required this.updateUsers
  });

  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  Map<String, dynamic>? userData;
  late String password = '';
  bool isPasswordHidden = true;
  IconData passIcon = Icons.visibility;
  late Future<List<Achievement>> _achieveFuture;
  late Future<List<CompletedAchievement>> _completedAchievementsFuture;
  bool _isFloatingActionButtonVisible = false;
  List<int> selectedAchievementIds = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    _achieveFuture = fetchAchievements();
    _completedAchievementsFuture = fetchCompletedAchievements();
  }

  Future<List<CompletedAchievement>> fetchCompletedAchievements() async {
    var url = Uri.parse('${baseURL}completedachievements/${widget.userId}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => CompletedAchievement.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      return fetchCompletedAchievements();
    } else {
      throw Exception('Failed to load completed achievements');
    }
  }

  Future<List<Achievement>> fetchAchievements() async {
    var headers = {"Accept-Language":"ru"};
    final response = await http.get(Uri.parse('${baseURL}achievements'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Achievement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load achievements');
    }
  }

  Future<void> fetchData() async {
    final clubResponse = await http.get(Uri.parse('${baseURL}users/${widget.userId}'));

    if (clubResponse.statusCode == 200) {
      final userData = jsonDecode(clubResponse.body);

      setState(() {
        this.userData = userData;
      });
    } else {
      throw Exception('Failed to load data: ${clubResponse.body} [${clubResponse.statusCode}]');
    }
  }

  void updatePasswordVisibility() {
    setState(() {
      isPasswordHidden = !isPasswordHidden;
      switch (passIcon) {
        case Icons.visibility_off:
          passIcon = Icons.visibility;
          break;
        case Icons.visibility:
          passIcon = Icons.visibility_off;
          break;
      }
    });
  }
  bool _isPasswordValid(String password) {
    final RegExp passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  void _updatePassword(String value) {
    setState(() {
      password = value;
    });
  }

  void updateFloatingActionButtonVisibility() {
    setState(() {
      _isFloatingActionButtonVisible = selectedAchievementIds.isNotEmpty;
    });
  }

  Future<Achievement?> getAchievementById(int id) async {
    final achievements = await _achieveFuture;

    if (achievements.isNotEmpty) {
      final achievement = achievements.firstWhere((a) => a.id == id);
      return achievement;
    }

    return null;
  }

  Future<void> onAchieveCancel(BuildContext context,int userId, List<int> completedAchievementsIds) async {
    var url = Uri.parse('${baseURL}completedachievements');
    var cookies = await loadCookies();
    debugPrint('$cookies');
    var headers = {'Content-Type': 'application/json', 'Cookie': cookies!};
    var body = jsonEncode({
      "userId": userId,
      "achievementIds": completedAchievementsIds,
    });
    var response = await http.delete(url, body: body, headers: headers);
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Успешно отменено'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _completedAchievementsFuture = fetchCompletedAchievements();
                    },
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    else if (response.statusCode == 401) {
      await refreshToken();
      await onAchieveCancel(context, userId, completedAchievementsIds);
    }
    debugPrint("${response.statusCode} (${response.body})");
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

  void cancelAchievementDialog(
      BuildContext context,
      int userId,
      List<int> selectedAchievementIds,
      ) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center( child: Text('Вы действительно хотите отменить следующие достижения у пользователя?', textAlign: TextAlign.center,style: TextStyle(fontSize: 18.0),),),
                const SizedBox(height: 16.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: selectedAchievementIds.map((achievementId) {
                      return FutureBuilder<Achievement?>(
                        future: getAchievementById(achievementId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            final achievement = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                width: 100.0,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(128, 128, 128, 0.2),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        'https://sskef.site/${achievement.logoURL}',
                                        width: 50.0,
                                        height: 50.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      achievement.title,
                                      style: const TextStyle(fontSize: 12.0),
                                      textAlign: TextAlign.center,
                                    ),

                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onAchieveCancel(context, userId, selectedAchievementIds);
                }, child: const Text('Отметить невыполненными'))
              ],
            ),
          ),
        );
      },
    );
  }
  void deleteUserDialog(
      BuildContext context,
      ) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center( child: Text('Вы действительно хотите удалить аккаунт пользователя?', textAlign: TextAlign.center,style: TextStyle(fontSize: 18.0),),),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () {
                      Navigator.of(dialogContext).pop();
                      deleteUser();
                    },
                        child: const Text('Удалить', style: TextStyle(color: Color.fromRGBO(
                            252, 105, 105, 1.0)),)
                    ),
                    const SizedBox(width: 8.0,),
                    ElevatedButton(onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                        child: const Text('Отменить', style: TextStyle(color: Colors.white),)
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void updateUserPassword(
      int userId,
      String password,
      ) {

  }

  Future<void> deleteUser() async {
    var url = Uri.parse('${baseURL}users/${widget.userId}');
    var cookies = await loadCookies();

    var response = await http.delete(url, headers: {
      'Cookie': cookies!,
    });

    if (response.statusCode == 200) {
      await widget.updateUsers();

    }
    else {
      await refreshToken();
      await deleteUser();
      throw Exception(
          'Failed to delete user (StatusCode: ${response.statusCode})\n${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<List<dynamic>>? currentSnapshot;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Редактирование',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: _isFloatingActionButtonVisible
          ? FloatingActionButton(
        onPressed: () {
          cancelAchievementDialog(context, widget.userId, selectedAchievementIds);
        },
        child: const Icon(Icons.cancel),
      )
          : null,
      body: FutureBuilder(
        future: Future.wait([_achieveFuture, _completedAchievementsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          currentSnapshot = snapshot;
          if (snapshot.hasData) {
            final achievements = snapshot.data![0] as List<Achievement>;
            final completedAchievements =
            snapshot.data![1] as List<CompletedAchievement>;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromRGBO(11, 106, 108, 0.15)
                          : const Color.fromRGBO(11, 106, 108, 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row (
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50.0,
                              backgroundImage: NetworkImage('https://sskef.site/${widget.avatarPath}'),
                            ),
                            const SizedBox(width: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 150),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${widget.firstName} ${widget.lastName}',
                                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Клуб "${widget.clubLogo}"',
                                        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          width: 500,
                          height: 50,
                          child:OutlinedButton(
                            onPressed: () {
                              deleteUserDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Delete user', style: TextStyle(color: Color.fromRGBO(
                                      252, 105, 105, 1.0))),
                                  Icon(Icons.delete_outline, color: Color.fromRGBO(
                                      252, 105, 105, 1.0)),
                                ]
                            ),
                            ),
                        ),
                      ],
                    ),
                    ),
                    /*const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromRGBO(11, 106, 108, 0.15)
                            : const Color.fromRGBO(11, 106, 108, 0.15),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            //controller: _passwordController,
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: password,
                                selection: TextSelection.collapsed(
                                    offset: password.length),
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              suffixIcon: IconButton(
                                icon: Icon(passIcon),
                                onPressed: () {
                                  updatePasswordVisibility();
                                },
                              ),
                              errorText: password.isNotEmpty && (password.length < 6 || !_isPasswordValid(password))
                                  ? 'Пароль должен содержать не менее 6 символов и \nкак минимум 1 букву или 1 цифру'
                                  : null,
                            ),
                            obscureText: isPasswordHidden,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            onChanged: (value) {
                              _updatePassword(value);
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Пароль обязателен для заполнения';
                              }
                              if (value!.length < 6 || !_isPasswordValid(value)) {
                                return 'Пароль должен содержать не менее 6 символов и \nкак минимум 1 букву или 1 цифру';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8.0,),
                          ElevatedButton(
                            onPressed: () {
                              updateUserPassword(widget.userId, password);
                            },
                            child: const Text('Обновить пароль'),
                          ),
                        ],
                      ),
                    ),*/
                    const SizedBox(height: 16.0),
                    const Center(child: Text('Список завершенных достижений пользователя', style: TextStyle(fontSize: 18.0),),),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        /*color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromRGBO(11, 106, 108, 0.15)
                            : const Color.fromRGBO(11, 106, 108, 0.15),*/
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      //padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: completedAchievements.length,
                                itemBuilder: (context, index) {
                                  final completedAchievement = completedAchievements[index];
                                  final achievement = achievements.firstWhere((achieve) => achieve.id == completedAchievement.achievementId);

                                  return AchievementItem(
                                    onTap: () {
                                      setState(() {
                                        if (selectedAchievementIds
                                            .contains(achievement.id)) {
                                          selectedAchievementIds
                                              .remove(achievement.id);
                                          updateFloatingActionButtonVisibility();
                                        } else {
                                          selectedAchievementIds
                                              .add(achievement.id);
                                          updateFloatingActionButtonVisibility();
                                        }
                                      });
                                    },
                                    logo: 'https://sskef.site/${achievement.logoURL}',
                                    title: achievement.title,
                                    description: achievement.description,
                                    xp: achievement.xp,
                                    completionRatio: achievement.completionRatio,
                                    id: achievement.id,
                                    isSelected: selectedAchievementIds
                                        .contains(achievement.id),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
        ),
    );
  }
}