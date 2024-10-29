import 'dart:convert';
import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  MobileScannerController controller = MobileScannerController();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.stop();
    } else if (Platform.isIOS) {
      controller.start();
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

  Future<void> onAchieveComplete() async {
    String data = result!.rawValue!;
    var dataParts = data.split(':');
    debugPrint("${dataParts[0]}\n${dataParts[1]}");
    var url = Uri.parse('${baseURL}api/completedachievements');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cookies = prefs.getString('cookies');

    var headers = {'Content-Type': 'application/json', 'Cookie': cookies!};
    var achievementIds =
    dataParts.sublist(1);
    var body = jsonEncode({
      "userId": dataParts[0],
      "achievementIds": achievementIds,
    });
    debugPrint('RESPONSE BODY - ${body}');
    var response = await http.post(url, body: body, headers: headers);
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
                  const Text('Успешно выполнено'),
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
    else if (response.statusCode == 401) {
      await refreshToken();
      await onAchieveComplete();
    }
    else {
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
                    'Достижение не выполнено.\nОшибка: ${response.body}\nКод статуса - ${response.statusCode}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0,),
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
    debugPrint("${response.statusCode} (${response.body})");
    setState(() {
      result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (BarcodeCapture barcode) {
                setState(() {
                  result = barcode.barcodes.first;
                });
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: (result == null)
                  ? const Text("Отсканируйте!")
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onAchieveComplete,
                    child: const Text('Выполнить'),
                  ),
                  result != null ? const SizedBox(height: 8.0) : Container(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        result = null;
                      });
                    },
                    child: const Text('Сбросить сканированный QR-код'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
