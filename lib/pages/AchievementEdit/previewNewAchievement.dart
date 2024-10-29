import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../items/achievementItem.dart';
import '../../main.dart';
import '../authpage.dart';

class PreviewNewAchievement extends StatelessWidget {
  final String imageUrl;
  final String titleRU;
  final String titlePL;
  final String titleEN;
  final String descriptionRU;
  final String descriptionPL;
  final String descriptionEN;
  final int experiencePoints;
  final bool isComboAchievement;

  PreviewNewAchievement({
    super.key,
    required this.imageUrl,
    required this.titleRU,
    required this.titlePL,
    required this.titleEN,
    required this.descriptionRU,
    required this.descriptionPL,
    required this.descriptionEN,
    required this.experiencePoints,
    required this.isComboAchievement
  });

  Future<String?> loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookies');
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }

  Future<void> createAchievement(BuildContext context) async {
    var cookies = await loadCookies();
    final url = Uri.parse('${baseURL}api/achievements');
    final headers = {'Content-Type': 'application/json', 'Cookie': cookies!};
    final body = jsonEncode({
      'title_en': titleEN,
      'title_ru': titleRU,
      'title_pl': titlePL,
      'description_en': descriptionEN,
      'description_ru': descriptionRU,
      'description_pl': descriptionPL,
      'logoURL': imageUrl,
      'xp': experiencePoints,
      'isMultiple': isComboAchievement
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      updatePage(context);
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
                  Text(
                    'Достижение cоздано.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            ),
          );
        },
      );
      debugPrint('Achievement created successfully');
    } else if (response.statusCode == 400) {
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
                  Text(
                    'Ошибка при создании:\n${response.body}.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
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
    else {
      debugPrint('Failed to create achievement. Error: ${response.body}. Status code: ${response.statusCode}');
    }
  }

  void updatePage(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Завершение'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Предпросмотр будущего достижения',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            AchievementItem(
              logo: '${baseURL}/${imageUrl}',
              id: 0,
              title: titleRU,
              description: descriptionRU,
              xp: experiencePoints,
              completionRatio: 52,
              isSelected: false,
              onTap: () {},
              completionCount: '1',
              isMultiple: isComboAchievement,
            ),
            AchievementItem(
              logo: '${baseURL}/${imageUrl}',
              id: 0,
              title: titlePL,
              description: descriptionPL,
              xp: experiencePoints,
              completionRatio: 52,
              isSelected: false,
              onTap: () {},
              completionCount: '1',
              isMultiple: isComboAchievement,
            ),
            AchievementItem(
              logo: '${baseURL}/${imageUrl}',
              id: 0,
              title: titleEN,
              description: descriptionEN,
              xp: experiencePoints,
              completionRatio: 52,
              isSelected: false,
              onTap: () {},
              completionCount: '1',
              isMultiple: isComboAchievement,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                createAchievement(context);
              },
              child: const Text('Создать достижение'),
            )
          ]
        ),
      ),
    );
  }
}
