import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class APInotification {
  static Future<http.Response> postRequset({required Map data}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAiPNNiXg:APA91bHiMejZLVIMmqu0TwK0J--BsC7TN8OV5oBSVC3eXaE1RGBHoOwmDukuj-xzA62WeX-MmOaMCCPTKoeRPB1xjGIzpdEvBEUo_Zb7jg6G4fqSiT_5VE7DBSlxpA3MFyq8a2SDKbmN'
    };

    return await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        body: jsonEncode(data), headers: headers);
  }
}
