import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevanam_mobkol/services/config/config.dart' as config;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sevanam_mobkol/services/utils/mcrypt_utils.dart';

class FirestoreCollectionServices {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> getBaseURL() async {
    String baseURL = config.baseURL;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String clientPackageName = packageInfo.packageName;

    final docRef = db.collection("mobkol_base_url").doc(clientPackageName);
    const source = Source.server;

    await docRef.get(const GetOptions(source: source)).then(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) return false;
        if (data['base_url'] == null || data['base_url'] == '') return false;

        String tmpBaseURL = McryptUtils.instance.decrypt(data['base_url']);
        if (data['base_url'] != tmpBaseURL) baseURL = tmpBaseURL;
        return true;
      },
      onError: (e) => print("Firestore: Error completing $e"),
    );

    return baseURL;
  }
}
