import 'dart:convert';
import 'dart:io';
import 'package:achieve_club_mobile_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
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

  Future<void> onAchieveComplete() async {
    String data = result!.code!;
    var dataParts = data.split(':');
    debugPrint("${dataParts[0]}\n${dataParts[1]}");
    var url = Uri.https('sskef.site', 'api/completedachievements');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cookies = prefs.getString('cookies');

    var headers = {'Content-Type': 'application/json', 'Cookie': cookies!};
    var achievementIds =
        dataParts.sublist(1);
    var body = jsonEncode({
      "userId": dataParts[0],
      "achievementIds": achievementIds,
    });
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
                  Text('Успешно выполнено'),
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
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result == null)
                  ? const Text("Отсканируйте!")
                  : ElevatedButton(
                      onPressed: onAchieveComplete, child: const Text('Выполнить')),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
