import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static PermissionUtils instance = PermissionUtils();
  getPermission(permission) async {
    if (permission == 'location') {
      PermissionStatus _permissionStatus = await Permission.location.status;

      if (_permissionStatus.isGranted) {
        return true;
      } else {
        PermissionStatus _permissionStatus = await Permission.location.request();
        if (_permissionStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    } else if (permission == 'camera') {
      PermissionStatus _permissionStatus = await Permission.camera.status;

      if (_permissionStatus.isGranted) {
        return true;
      } else {
        PermissionStatus _permissionStatus = await Permission.camera.request();
        if (_permissionStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    } else if (permission == 'storage') {
      PermissionStatus _permissionStatus = await Permission.storage.status;

      if (_permissionStatus.isGranted) {
        return true;
      } else {
        PermissionStatus _permissionStatus = await Permission.storage.request();
        if (_permissionStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  getPermissionAll() async {
    await [Permission.location].request();
  }
}
