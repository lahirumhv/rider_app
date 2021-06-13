import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestAssistant {
  // Changed from String to Uri.parse
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    try {
      if (response.statusCode == 200) {
        String jsonData = response.body;

        var decodedData = jsonDecode(jsonData);

        return decodedData;
      } else {
        return "Failed.";
      }
    } catch (e) {
      return "Failed.";
    }
  }
}
