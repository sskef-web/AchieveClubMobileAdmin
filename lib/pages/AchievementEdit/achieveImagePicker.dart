import 'dart:convert';
import '/pages/AchievementEdit/previewNewAchievement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class AchieveImagePicker extends StatefulWidget {
  final String titleRU;
  final String titlePL;
  final String titleEN;
  final String descriptionRU;
  final String descriptionPL;
  final String descriptionEN;
  final String exp;
  final bool isComboAchievement;

  AchieveImagePicker({
    super.key,
    required this.titleRU,
    required this.titlePL,
    required this.titleEN,
    required this.descriptionRU,
    required this.descriptionPL,
    required this.descriptionEN,
    required this.exp,
    required this.isComboAchievement
  });

  @override
  _AchieveImagePicker createState() => _AchieveImagePicker();
}

class _AchieveImagePicker extends State<AchieveImagePicker> {
  List<String> imageUrls = [];
  ValueNotifier<String?> selectedImageUrl = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _fetchImageUrls();
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

  Future<String?> loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookies');
  }

  Future<void> saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }

  Future<void> _fetchImageUrls() async {
    var cookies = await loadCookies();
    final response = await http.get(Uri.parse('${baseURL}api/achievementicons'), headers: {
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

  void _updatePage() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              AchieveImagePicker(
                  titleRU: widget.titleRU,
                  titlePL: widget.titlePL,
                  titleEN: widget.titleEN,
                  descriptionRU: widget.descriptionRU,
                  descriptionPL: widget.descriptionPL,
                  descriptionEN: widget.descriptionEN,
                  exp: widget.exp,
                  isComboAchievement: widget.isComboAchievement,
              )),
    );
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
          _updatePage();
        } else {
          throw Exception('Upload image error. Code: ${response.statusCode}\n${response.body}');
        }
      } catch (error) {
        throw Exception('Upload image error: $error');
      }
    }
  }

  void goToPreviewPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewNewAchievement(
          imageUrl: '${selectedImageUrl.value}',
          titleRU: widget.titleRU,
          titlePL: widget.titlePL,
          titleEN: widget.titleEN,
          descriptionRU: widget.descriptionRU,
          descriptionPL: widget.descriptionPL,
          descriptionEN: widget.descriptionEN,
          experiencePoints: int.parse(widget.exp),
          isComboAchievement: widget.isComboAchievement,
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    if (imageUrls.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Выбор изображения'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: selectedImageUrl,
                builder: (context, selectedUrl, _) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              color: isSelected ? Colors.blue : Colors.transparent,
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
              child: Row (
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  selectedImageUrl.value != null ?
                    ElevatedButton(
                      onPressed: () {
                        goToPreviewPage();
                      },
                      child: const Text('Продолжить'),
                    ) : ElevatedButton(
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
    }
    else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
