import 'package:flutter/material.dart';

class FirebaseUtils {
  static FirebaseUtils instance = FirebaseUtils();

  Future setDataFirebase(
    BuildContext context,
    Map<String, dynamic> message,
  ) async {
    // var dataType = message['data']['type'];
    // var dataTypePush = message['data']['type_push'];
    // var dataMessage = message['data']['message'];
    print(message);
  }
}
