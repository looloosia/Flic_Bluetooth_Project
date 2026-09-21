import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

Future<List<String>> findRoses() async {
  final info = NetworkInfo();
  final phoneIp = await info.getWifiIP();
  final foundIps = <String>[];
  final ips = <String>[];

  if (phoneIp == null) {
    print('phone IP is null');
    return [];
  }
  final parts = phoneIp.split('.');

  final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

  const batchSize = 30;

  final List<String> candidates = [];
  for (int start = 1; start <= 254; start += batchSize) {
    final end = start + batchSize - 1;
    final List<Future<String?>> futures = [];

    for (int i = start; i <= end; i++) {
      final ip = '$subnet.$i';
      futures.add(
        checkRoseCandidate(ip)
      );


    }
    print('검사중: $start ~ $end');
    final results = await Future.wait(futures);

    for (String? ip in results) {
      if (ip != null) {
        candidates.add(ip);
      }
    }
  }

  return trueRoses(candidates);
}

Future<String?> checkRoseCandidate(String ip) async {
  try {
    final socket = await Socket.connect(
      ip,
      9283,
      timeout: const Duration(milliseconds: 300),
    );
    socket.destroy();
    return ip;
  } catch (_) {
    return null;
  }
}

Future<List<String>> trueRoses(List<String> candidates) async {
  final List<String> finalRosIPs = [];
  print('Rose후보: $candidates');
  for (String ip in candidates) {
    try {
      final client = HttpClient();

      client.connectionTimeout = const Duration(seconds: 2);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        print('인증서 검증 실패 감지: $host:$port');


        return host == ip && port == 9283;
      };

      final request = await client.postUrl(
          Uri.parse('https://$ip:9283/get_current_state'));

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );

      request.headers.set(
          HttpHeaders.acceptHeader,
          '*/*'
      );

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        if (data['code'] == 'G0000' && data['status']?['outs'] == 'OK') {
          finalRosIPs.add(ip);
        }
      }
      client.close();
    } catch(e) {
      print('$ip ROSE 검증 실패: $e');
    } finally {

    }
  }
  return finalRosIPs;
}

Future<void> sendRequest(String ip, String? action) async {
  final client = HttpClient();

  client.connectionTimeout = const Duration(seconds: 15);
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    print('인증서 검증 실패 감지: $host:$port');


    return host == ip && port == 9283;
  };

  final bodyText;
  switch (action) {
    case 'standby':
      bodyText = 'remote_bar_order_sleep_on_off';
    case 'reboot':
      bodyText = 'remote_bar_order.reboot';
    case 'playPause':
      bodyText = 17;
    case 'next':
      bodyText = 18;
    case 'prev':
      bodyText = 19;
    case 'mute':
      bodyText = 'remote_bar_order.mute';
    case 'volume10':
      bodyText = 10;
    case 'volume20':
      bodyText = 20;
    case 'volume30':
      bodyText = 30;
    default:
      bodyText = 'remote_bar_order_sleep_on_off';
  }

  try {
    String path;
    Map<String, dynamic> requestBody;
    if (action == 'standby' || action == 'reboot' || action == 'mute') {
      path = '/remote_bar_order';
      requestBody = {'barControl': bodyText};
    } else if (action == 'playPause' || action == 'next' || action == 'prev') {
      path = '/current_play_state';
      requestBody = {'currentPlayState': bodyText};
    } else if (action == 'volume10' || action == 'volume20' || action == 'volume30') {
      path = '/volume';
      requestBody = {
        'volumeType': 'volume_set',
        'volumeValue': bodyText,
      };
    } else {return;}


    final url = Uri.parse(
      'https://$ip:9283$path',
    );
    print('1. 연결 시작: $url');
    final request = await client.postUrl(url);
    print('2. HTTPS 연결 성공');

    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/json',
    );

    request.headers.set(
      HttpHeaders.acceptHeader,
      '*/*'
    );

    final jsonBody = jsonEncode(requestBody);
    final bodyBytes = utf8.encode(jsonBody);

    request.contentLength = bodyBytes.length;

    print('보내는 데이터: $jsonBody');
    request.add(bodyBytes);

    final response = await request.close();

    print('status = ${response.statusCode}');
    print('Content-Type: ${request.headers.value(HttpHeaders.contentTypeHeader)}');
    print('Content-Length: ${request.contentLength}');
    print('보내는 데이터: $jsonBody');
    final responseBody = await response.transform(utf8.decoder).join();
    print('response = $responseBody');
  } on HttpException catch (e) {
    print('HTTP 응답 전에 ROSE가 연결 종료: $e');
  } on SocketException catch (e) {
    print('Socket 오류: $e');
  } catch (e) {
    print('통신 오류: $e');
  } finally {
    client.close(force: true);
  }
}

Future<List<dynamic>?> fetchRadios(int page) async {
  final url = Uri.parse(
      'https://api.roseaudio.kr/radio/v2/channel?title=&page=$page&size=15&sortType=NAME_ASC&regionId=0');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['radioChannels'];
  } else {
    print('----error. Status code: ${response.statusCode}');
    return null;
  }
}

Future<void> playRadio(
    String ip,
  List<dynamic> radios,
  int index,
) async {
  try {
    final client = HttpClient();

    client.connectionTimeout = const Duration(seconds: 15);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      print('인증서 검증 실패 감지: $host:$port');


      return host == ip && port == 9283;
    };

    final request = await client.postUrl(
      Uri.parse('https://$ip:9283/rose_radio_play'));

    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/json; charset=utf-8',
    );

    request.headers.set(
        HttpHeaders.acceptHeader,
        '*/*'
    );
    final jsonBody = jsonEncode({'data': radios, 'currentPosition': index});
    final bodyBytes = utf8.encode(jsonBody);

    request.contentLength = bodyBytes.length;

    print('보내는 데이터: $jsonBody');
    request.add(bodyBytes);

    final response = await request.close();

    print('status = ${response.statusCode}');
  } catch(e) {
    print('error : $e');
  }

}