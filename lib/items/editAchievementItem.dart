import '/pages/AchievementEdit/achieveEditPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class EditAchievementItem extends StatefulWidget {
  final String logo;
  final int id;
  final String title;
  final String description;
  final int xp;
  final int completionRatio;
  final bool isSelected;
  final VoidCallback? onTap;
  final String completionCount;
  final bool isMultiple;
  final Function() fetchAchievements;

  const EditAchievementItem(
      {super.key,
      required this.logo,
      required this.id,
      required this.title,
      required this.description,
      required this.xp,
      required this.completionRatio,
      required this.isSelected,
      required this.onTap,
      required this.completionCount,
      required this.isMultiple,
      required this.fetchAchievements});

  @override
  _EditAchievementItemState createState() => _EditAchievementItemState();
}

class _EditAchievementItemState extends State<EditAchievementItem> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant EditAchievementItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    isSelected = widget.isSelected;
  }

  Future<String?> loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookies');
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
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
      }
    } else {
      throw Exception(
          'Failed to refresh Token (StatusCode: ${response.statusCode})\n${response.body}');
    }
  }

  Future<void> deleteAchieve() async {
    var url = Uri.parse('${baseURL}api/achievements/${widget.id}');
    var cookies = await loadCookies();

    var response = await http.delete(url, headers: {
      'Cookie': cookies!,
    });

    if (response.statusCode == 200) {
      setState(() {
        widget.fetchAchievements();
      });
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
                    'Достижение удалено.',
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
    } else {
      await refreshToken();
      await deleteAchieve();
      throw Exception(
          'Failed to delete achievement (StatusCode: ${response.statusCode})\n${response.body}');
    }
  }

  void deleteAchieveDialog(
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
                const Center(
                  child: Text(
                    'Вы действительно хотите удалить достижение?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          deleteAchieve();
                        },
                        child: const Text(
                          'Удалить',
                          style: TextStyle(
                              color: Color.fromRGBO(252, 105, 105, 1.0)),
                        )),
                    const SizedBox(
                      width: 8.0,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text(
                          'Отменить',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Colors.blue
                : Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromRGBO(11, 106, 108, 0.25)
                    : const Color.fromRGBO(231, 231, 231, 1.0)),
        child: Column(
          children: [
            Card(
              color: Colors.transparent,
              child: ListTile(
                contentPadding:
                    EdgeInsets.only(top: 4.0, bottom: 8.0, right: 10, left: 10),
                onTap: null,
                leading: Image.network(widget.logo),
                title: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 15),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          right: 8.0, left: 8.0, top: 2.0, bottom: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromRGBO(11, 106, 108, 1)
                            : const Color.fromRGBO(11, 106, 108, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.xp}XP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    widget.isMultiple
                        ? Container(
                            padding: EdgeInsets.only(
                                right: 8.0, left: 8.0, top: 2.0, bottom: 2.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color.fromRGBO(11, 106, 108, 1)
                                  : const Color.fromRGBO(11, 106, 108, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.completionCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
                subtitle: Text(
                  widget.description,
                  style: TextStyle(
                    height: 1.3,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: widget.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(11, 106, 108, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        children: [Icon(Icons.edit), Text('Изменить')],
                      )),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                      onPressed: () {
                        deleteAchieveDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        children: [Icon(Icons.delete), Text('Удалить')],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
