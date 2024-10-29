import '/pages/AchievementEdit/achieveImagePicker.dart';
import 'package:flutter/material.dart';

class AchieveAddPage extends StatefulWidget {

  const AchieveAddPage({
        super.key,
  });

  @override
  _AchieveAddPageState createState() => _AchieveAddPageState();
}

class _AchieveAddPageState extends State<AchieveAddPage> {
  String titleRU = '';
  String titleEN = '';
  String titlePL = '';
  String descriptionRU = '';
  String descriptionEN = '';
  String descriptionPL = '';
  String exp = '';
  bool isAccess = false;
  bool isComboAchievement = false;

  @override
  void initState() {
    super.initState();
  }

  void goToImagePick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchieveImagePicker(
          titleRU: titleRU,
          titlePL: titlePL,
          titleEN: titleEN,
          descriptionRU: descriptionRU,
          descriptionPL: descriptionPL,
          descriptionEN: descriptionEN,
          exp: exp,
          isComboAchievement: isComboAchievement,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавление достижения'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название достижения (на русском)',
              ),
              onChanged: (value) {
                setState(() {
                  titleRU = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название достижения (на польском)',
              ),
              onChanged: (value) {
                setState(() {
                  titlePL = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название достижения (на английском)',
              ),
              onChanged: (value) {
                setState(() {
                  titleEN = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Описание достижения (на русском)',
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  descriptionRU = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Описание достижения (на польском)',
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  descriptionPL = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Описание достижения (на английском)',
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  descriptionEN = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Количество опыта за выполнение',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  exp = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            CheckboxListTile(
              title: Text('Комбо-достижение'),
              value: isComboAchievement,
              onChanged: (newValue) {
                setState(() {
                  isComboAchievement = newValue!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                goToImagePick();
              },
              child: const Text('Перейти к добавлению изображения'),
            ),
          ],
        ),
      ),
    );
  }
}
