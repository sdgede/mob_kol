import 'dart:convert';

import 'mcrypt_utils.dart';
import '../config/config.dart';

class AuthUtils {
  static AuthUtils instance = AuthUtils();

  Future getTokenAPK() async {
    McryptUtils encrypt = McryptUtils.instance;
    return base64Encode(utf8.encode('${encrypt.encrypt(clientId)}:${encrypt.encrypt(clientSecret)}'));
  }

  Future getTokenBerita() async {
    return "c732ad52eb3f48c6b8729a0e11e0327f";
  }

  Future getTokenMerchant() async {
    return "da996c9c291208c888df368531822659";
  }
}
