import 'package:http/http.dart' as http;
import 'dart:convert';

class RoseApiService {
  Future<void> powerOn() async {
    final url = Uri.parse('https://{ip}:9283/remote_bar_order');

    final Map<String, dynamic> requestBody = {
      "barControl": "remote_bar_order.power_onoff",
      "value": -1,
      "roseToken": ""
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          requestBody
        })
      );

      if (response.statusCode == 200) {
        print('------전송 완료');
      } else  {
        print('-------전송 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('------통신 에러 발생: $e');
    }
  }
}