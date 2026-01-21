import 'package:steel_crypt/steel_crypt.dart';
import 'package:encrypt/encrypt.dart';
import '../config/config.dart' as config;

class McryptUtils {
  static McryptUtils instance = McryptUtils();

  final Key secretKey = Key.fromUtf8(config.secretKey);
  final IV iv = IV.fromUtf8(config.iv);
  final String secretKeyMerchant = config.secretKeyMerchant;
  final String ivMerchant = config.ivMerchant;

  // String encrypt(String value) {
  //   if (value == "") return "";
  //   var aesEncrypter = AesCrypt(key: this.secretKey, padding: PaddingAES.pkcs7);
  //   String? encrypted;
  //   try {
  //     encrypted = aesEncrypter.gcm.encrypt(inp: value, iv: this.iv);
  //   } on Exception {
  //     print("Error encrypt");
  //   } catch (e) {
  //     print("Error encrypt");
  //   }
  //   return encrypted!;
  // }

  String encrypt(String? value) {
    if (value == null || value == "") return "";

    final encrypter = Encrypter(AES(this.secretKey, mode: AESMode.cbc));
    String? encrypted;
    try {
      encrypted = encrypter.encrypt(value, iv: this.iv).base64;
    } catch (e) {
      print("Error encrypt $e");
    }
    return encrypted!;
  }

  // String decrypt(String encrypted) {
  //   if (encrypted == "") return "";
  //   // var aesEncrypter = AesCrypt(this.secretKey, 'cbc', 'pkcs7');
  //   var aesEncrypter = AesCrypt(key: this.secretKey, padding: PaddingAES.pkcs7);
  //   String? decrypted;
  //   try {
  //     decrypted = aesEncrypter.gcm.decrypt(enc: encrypted, iv: this.iv);
  //     print('checkkk on decrypt $decrypted');
  //   } on Exception {
  //     print("Error decrypt");
  //   } catch (e) {
  //     print("Error decrypt $e");
  //   }
  //   return decrypted!;
  // }

  String decrypt(String? encrypted) {
    if (encrypted == null || encrypted == "") return "";
    final encrypter = Encrypter(AES(this.secretKey, mode: AESMode.cbc));
    String? decrypted;
    try {
      decrypted = encrypter.decrypt64(encrypted, iv: this.iv);
    } catch (e) {
      print("Error decrypt $e");
      return encrypted;
    }
    return decrypted;
  }

  String encryptMerchant(String value) {
    if (value == "") return "";
    // var aesEncrypter = AesCrypt(this.secretKeyMerchant, 'cbc', 'pkcs7');
    var aesEncrypter = AesCrypt(key: this.secretKeyMerchant, padding: PaddingAES.pkcs7);
    String? encrypted;
    try {
      encrypted = aesEncrypter.gcm.encrypt(inp: value, iv: this.ivMerchant);
    } on Exception {
      print("Error encrypt");
    } catch (e) {
      print("Error encrypt");
    }
    return encrypted!;
  }

  String decryptMerchant(String encrypted) {
    if (encrypted == "") return "";
    var aesEncrypter = AesCrypt(key: this.secretKeyMerchant, padding: PaddingAES.pkcs7);
    String? decrypted;
    try {
      decrypted = aesEncrypter.gcm.decrypt(enc: encrypted, iv: this.ivMerchant);
    } on Exception {
      print("Error decrypt");
    } catch (e) {
      print("Error encrypt");
    }
    return decrypted!;
  }
}
