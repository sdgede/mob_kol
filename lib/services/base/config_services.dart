import 'package:dio/dio.dart';

class ConfigServices {
  static Options getHeadersAPK({String token = ""}) {
    var _headers = Map<String, dynamic>();
    _headers['Accept'] = "application/json";
    if (token != '') {
      _headers['Authorization'] = 'Basic $token';
    }
    return Options(
      headers: _headers,
      contentType: "multipart/form-data",
      // sendTimeout: 60 * 1000 // 60 seconds
      sendTimeout: Duration(seconds: 60), // 60 seconds
      // receiveTimeout: 60 * 1000, // 60 seconds
      receiveTimeout: Duration(seconds: 60), // 60 seconds
    );
  }

  static Options getHeadersMerchant({String token = ""}) {
    var _headers = Map<String, dynamic>();
    _headers['Accept'] = "application/json";
    if (token != '') {
      _headers['user-key'] = token;
    }

    return Options(headers: _headers);
  }
}
