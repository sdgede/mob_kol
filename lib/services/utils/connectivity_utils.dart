import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:sevanam_mobkol/services/viewmodel/global_provider.dart';

import '../config/config.dart' as config;
import '../utils/dialog_utils.dart';

class ConnectivityUtils {
  static ConnectivityUtils distance = ConnectivityUtils();
  List<ConnectivityResult> previous = [];
  Timer? alert;
  var timer = 30;

  onCheckConnectivity(BuildContext context) {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final bool isOffline = results.contains(ConnectivityResult.none);

      if (isOffline) {
        // no internet
        EasyLoading.show(status: config.Reconnect);
        alert = Timer(Duration(seconds: timer), () {
          EasyLoading.dismiss();
          _alertTimeout(context);
        });
      } else if (previous.contains(ConnectivityResult.none)) {
        // internet back
        EasyLoading.dismiss();
        alert?.cancel();
      }

      previous = results;
    });
  }

  _checkConnectivity(context) {
    try {
      InternetAddress.lookup('google.com').then((result) {
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // internet conn available
          EasyLoading.dismiss();
          alert!.cancel();
        } else {
          // no conn
          EasyLoading.show(status: config.Reconnect);
          alert = Timer(Duration(seconds: timer), () {
            EasyLoading.dismiss();
            _alertTimeout(context);
          });
        }
      }).catchError((error) {
        // no conn
        EasyLoading.show(status: config.Reconnect);
        alert = Timer(Duration(seconds: timer), () {
          EasyLoading.dismiss();
          _alertTimeout(context);
        });
      });
    } on SocketException catch (_) {
      // no internet
      EasyLoading.show(status: config.Reconnect);
      alert = Timer(Duration(seconds: timer), () {
        EasyLoading.dismiss();
        _alertTimeout(context);
      });
    }
  }

  _alertTimeout(BuildContext context) async {
    bool res = await DialogUtils.instance.showInfo(
          context: context,
          clickCancelText: 'Muat Ulang',
          clickOKText: 'Mode Offline',
          text:
              'Koneksi terputus. Silakan periksa kembali koneksi anda. Jika sedang melakukan transaksi mohon cek mutasi rekening anda. Anda dapat melanjutkan dengan mode Offline.',
          title: 'Opps...',
        ) ??
        false;

    if (!res) {
      _checkConnectivity(context);
    } else {
      Provider.of<GlobalProvider>(context, listen: false)
          .setConnectionMode(config.offlineMode);
      // SystemNavigator.pop();
    }
  }
}
