import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../services/config/config.dart' as config;
import '../../services/utils/dialog_utils.dart';
import '../../services/utils/permission_utils.dart';

class QRUtils {
  static QRUtils instance = QRUtils();

  dynamic qrScanner(BuildContext context) async {
    bool permisionCamera = await PermissionUtils.instance.getPermission('camera');

    if (permisionCamera) {
      try {
        var barcode = await BarcodeScanner.scan();
        return barcode.rawContent;
      } on PlatformException catch (error) {
        if (error.code == BarcodeScanner.cameraAccessDenied) {
          DialogUtils.instance.showError(
            context: context,
            text: "Silakan izikan " + config.companyName + " untuk mengakses kamera anda.",
          );
        } else {
          DialogUtils.instance.showError(context: context);
          return null;
        }
      } on FormatException {
        print('null (User returned using the "back"-button before scanning anything. Result)');
        return null;
      } catch (e) {
        DialogUtils.instance.showError(
          context: context,
          text: "Terjadi kesalahan saat membuka kamera. CODE:500",
        );
        return null;
      }
    } else {
      DialogUtils.instance.showError(
        context: context,
        text: "Silakan izikan " + config.companyName + " untuk mengakses kamera anda.",
      );
      return null;
    }
  }
}
