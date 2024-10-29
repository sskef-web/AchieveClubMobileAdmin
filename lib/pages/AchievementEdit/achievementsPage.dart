import '/pages/AchievementEdit/achieveAddPage.dart';
import '/pages/AchievementEdit/achieveEditPage.dart';
import '../../items/editAchievementItem.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/achievement.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {

  const AchievementsPage({
    super.key,
  });

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {

  late Future<List<Achievement>> _achieveFuture;

  @override
  void initState() {
    super.initState();
    _achieveFuture = fetchAchievements();
  }

  Future<List<Achievement>> fetchAchievements() async {
    var headers = {"Accept-Language": "ru"};
    final response =
    await http.get(Uri.parse('${baseURL}api/achievements'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Achievement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load achievements');
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<List<dynamic>>? currentSnapshot;
    return Scaffold(
      body: FutureBuilder(
          future: Future.wait([_achieveFuture]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            currentSnapshot = snapshot;
            if (snapshot.hasData) {
              final achievements = snapshot.data![0] as List<Achievement>;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AchieveAddPage(),
                              ),
                            );
                          },
                          child: Padding(padding: EdgeInsets.all(8.0), child: Text('Добавить новое достижение'),)
                      ),
                      const SizedBox(height: 8.0),
                      Stack(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: achievements.length,
                            itemBuilder: (context, index) {
                              final achievement = achievements[index];

                              return EditAchievementItem(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AchieveEditPage(
                                          id: achievement.id,
                                          updateAchieves: fetchAchievements,
                                      ),
                                    ),
                                  );
                                },
                                logo: '$baseURL${achievement.logoURL}',
                                title: achievement.title,
                                description: achievement.description,
                                xp: achievement.xp,
                                completionRatio: achievement.completionRatio,
                                id: achievement.id,
                                isSelected: false,
                                completionCount: 'Комбо',
                                isMultiple: achievement.isMultiple,
                                fetchAchievements: fetchAchievements,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
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
