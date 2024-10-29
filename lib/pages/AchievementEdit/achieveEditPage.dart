import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/achievementToEdit.dart';
import '../../main.dart';

class AchieveEditPage extends StatefulWidget {
  final int id;
  final Function() updateAchieves;

  const AchieveEditPage({
    super.key,
    required this.id,
    required this.updateAchieves
  });

  @override
  _AchieveEditPageState createState() => _AchieveEditPageState();
}

class _AchieveEditPageState extends State<AchieveEditPage> {
  late Future<AchievementToEdit> futureAchievement;
  late TextEditingController titleRuController;
  late TextEditingController titlePlController;
  late TextEditingController titleEnController;
  late TextEditingController descriptionRuController;
  late TextEditingController descriptionPlController;
  late TextEditingController descriptionEnController;
  late TextEditingController xpController;
  bool isMultiple = false;
  late String newTitleRu;
  late String newTitlePl;
  late String newTitleEn;
  late String newDescriptionRu;
  late String newDescriptionPl;
  late String newDescriptionEn;
  late int newXp = 0;
  late bool newIsMultiple;
  String newLogoUrl = '';
  List<String> imageUrls = [];
  ValueNotifier<String?> selectedImageUrl = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    futureAchievement = fetchAchievement();
    titleRuController = TextEditingController();
    titlePlController = TextEditingController();
    titleEnController = TextEditingController();
    descriptionRuController = TextEditingController();
    descriptionPlController = TextEditingController();
    descriptionEnController = TextEditingController();
    xpController = TextEditingController();
    _fetchImageUrls();
  }

  @override
  void dispose() {
    titleRuController.dispose();
    titlePlController.dispose();
    titleEnController.dispose();
    descriptionRuController.dispose();
    descriptionPlController.dispose();
    descriptionEnController.dispose();
    xpController.dispose();
    super.dispose();
  }

  Future<AchievementToEdit> fetchAchievement() async {
    final response =
        await http.get(Uri.parse('${baseURL}api/achievements/${widget.id}'));

    if (response.statusCode == 200) {
      return AchievementToEdit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load achievement');
    }
  }

  Future<void> _fetchImageUrls() async {
    var cookies = await loadCookies();
    final response =
        await http.get(Uri.parse('${baseURL}api/achievementicons'), headers: {
      'Cookie': cookies!,
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        imageUrls = data.cast<String>();
      });
    } else {
      debugPrint('${response.body}, Status Code - ${response.statusCode}');
      throw Exception('Failed to load image URLs');
    }
  }

  void imagePicker() {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
          ),
            child:
            Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: selectedImageUrl,
                    builder: (context, selectedUrl, _) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1,
                        ),
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          final isSelected = url == selectedUrl;
                          return GestureDetector(
                            onTap: () {
                              debugPrint('${selectedImageUrl.value}');
                              setState(() {
                                if (selectedImageUrl.value == url) {
                                  selectedImageUrl.value = null;
                                } else {
                                  selectedImageUrl.value = url;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 4.0,
                                ),
                              ),
                              child: Image.network(
                                '${baseURL}$url',
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Закрыть'),
                      ),
                      selectedImageUrl.value != null
                          ? ElevatedButton(
                        onPressed: () {Navigator.pop(dialogContext);},
                        child: const Text('Продолжить'),
                      )
                          : ElevatedButton(
                        onPressed: () {
                          uploadImage();
                        },
                        child: const Text('Загрузить картинку'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    var cookies = await loadCookies();

    if (pickedImage != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseURL}api/achievementicons'),
      );
      request.headers['Cookie'] = cookies!;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pickedImage.path,
        ),
      );

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

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
                      Text(
                        'Изображение загружено, перезайдите в страничку выбора изображения.',
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
          throw Exception(
              'Upload image error. Code: ${response.statusCode}\n${response.body}');
        }
      } catch (error) {
        throw Exception('Upload image error: $error');
      }
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

  Future<void> editAchievement(
    String titleRU,
    String titlePL,
    String titleEN,
    String descriptionRU,
    String descriptionPL,
    String descriptionEN,
    String logoURL,
    String xp,
    bool isMultiple,
  ) async {
    String logo;
    if (selectedImageUrl.value != null) {
      logo = selectedImageUrl.value!;
    }
    else {
      logo = logoURL;
    }

    var cookies = await loadCookies();
    final url = Uri.parse('${baseURL}api/achievements/${widget.id}');
    final headers = {'Content-Type': 'application/json', 'Cookie': cookies!};
    final body = jsonEncode({
      'title_en': titleEN,
      'title_ru': titleRU,
      'title_pl': titlePL,
      'description_en': descriptionEN,
      'description_ru': descriptionRU,
      'description_pl': descriptionPL,
      'logoURL': logo,
      'xp': int.parse(xp),
      'isMultiple': isMultiple
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      debugPrint('Achievement edit successfully');
      setState(() {
        widget.updateAchieves();
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
                    'Достижение успешно изменено.',
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
    } else if (response.statusCode == 401) {
      await refreshToken();
      await editAchievement(titleRU, titlePL, titleEN, descriptionRU,
          descriptionPL, descriptionEN, logoURL, xp, isMultiple);
    } else {
      debugPrint(
          'Failed to edit achievement. Error: ${response.body}. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Изменение достижения'),
      ),
      body: FutureBuilder<AchievementToEdit>(
        future: futureAchievement,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final achievement = snapshot.data!;
            if (newLogoUrl == '') {
              newLogoUrl = achievement.logoURL;
            }
            if (!titleRuController.text.isNotEmpty) {
              titleRuController.text = achievement.titleRu;
              titlePlController.text = achievement.titlePl;
              titleEnController.text = achievement.titleEn;
              descriptionRuController.text = achievement.descriptionRu;
              descriptionPlController.text = achievement.descriptionPl;
              descriptionEnController.text = achievement.descriptionEn;
              xpController.text = achievement.xp.toString();
              isMultiple = achievement.isMultiple;
            }

            if (newLogoUrl != '') {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent),
                        onPressed: () {
                          imagePicker();
                        },
                        child: selectedImageUrl.value != null ? Image.network('${baseURL}/${selectedImageUrl.value}', scale: 1.5) : Image.network('${baseURL}/${newLogoUrl}', scale: 1.5),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextField(
                        controller: titleRuController,
                        decoration: const InputDecoration(
                          labelText: 'Название достижения (на русском)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            newTitleRu = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: titlePlController,
                        decoration: const InputDecoration(
                          labelText: 'Название достижения (на польском)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            newTitlePl = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: titleEnController,
                        decoration: const InputDecoration(
                          labelText: 'Название достижения (на английском)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            newTitleEn = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: descriptionRuController,
                        decoration: const InputDecoration(
                          labelText: 'Описание достижения (на русском)',
                        ),
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            newDescriptionRu = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: descriptionPlController,
                        decoration: const InputDecoration(
                          labelText: 'Описание достижения (на польском)',
                        ),
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            newDescriptionPl = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: descriptionEnController,
                        decoration: const InputDecoration(
                          labelText: 'Описание достижения (на английском)',
                        ),
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            newDescriptionEn = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: xpController,
                        decoration: const InputDecoration(
                          labelText: 'Количество опыта за выполнение',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            newXp = int.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      CheckboxListTile(
                        title: Text('Комбо-достижение'),
                        value: isMultiple,
                        onChanged: (newValue) {
                          setState(() {
                            newIsMultiple = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                          onPressed: () {
                            editAchievement(
                                titleRuController.text,
                                titlePlController.text,
                                titleEnController.text,
                                descriptionRuController.text,
                                descriptionPlController.text,
                                descriptionEnController.text,
                                newLogoUrl,
                                xpController.text,
                                isMultiple);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Сохранить',
                              style: TextStyle(fontSize: 16),
                            ),
                          ))
                    ],
                  ),
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
