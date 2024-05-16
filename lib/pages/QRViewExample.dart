import 'dart:convert';
import 'dart:io';
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

  Future<void> onAchieveComplete() async {
    String data = result!.code!;
    var dataParts = data.split(':');
    debugPrint("${dataParts[0]}\n${dataParts[1]}");
    var url = Uri.https('sskef.site', 'api/completedachievements');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cookies = prefs.getString('cookies');

    var headers = {'Content-Type': 'application/json', 'Cookie': cookies!};
    var achievementIds =
        dataParts.sublist(1); // Создание списка идентификаторов ачивок
    var body = jsonEncode({
      "userId": dataParts[0],
      "AchievementIds": achievementIds,
    });
    var response = await http.post(url, body: body, headers: headers);
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
                      onPressed: onAchieveComplete, child: Text(result!.code!)),
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
