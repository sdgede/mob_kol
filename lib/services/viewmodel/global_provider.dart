import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:sevanam_mobkol/model/global_model.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';
import 'package:sevanam_mobkol/services/collection/firestore_collection.dart';
import 'package:sevanam_mobkol/services/collection/produk_collection.dart';
import 'package:sevanam_mobkol/services/utils/text_utils.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../config/config.dart' as config;
import '../config/router_generator.dart';
import '../utils/dialog_utils.dart';
import '../utils/location_utils.dart';
import '../collection/global_collection.dart';
import '../../setup.dart';

class GlobalProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  GlobalCollectionServices globalCollectionServices =
      setup<GlobalCollectionServices>();
  ProdukCollectionServices produkCollectionServices =
      setup<ProdukCollectionServices>();
  FirestoreCollectionServices firestoreService =
      setup<FirestoreCollectionServices>();

  Future<void> setBaseURL() async {
    String baseURL = await firestoreService.getBaseURL();
    config.baseURL = baseURL;
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // Updated: Menggunakan BluetoothInfo dari print_bluetooth_thermal
  BluetoothInfo? _selectedPrinter;
  BluetoothInfo? get getSelectedPrinter => _selectedPrinter;

  void setSelectedPrinter(BluetoothInfo printer) {
    _selectedPrinter = printer;
    notifyListeners();
  }

  String? _selectedPrinterName;
  String? get getSelectedPrinterName => _selectedPrinterName;

  void setSelectedPrinterName(String printerName) {
    _selectedPrinterName = printerName;
    notifyListeners();
  }

  // Updated: MAC Address untuk printer (diperlukan untuk koneksi)
  String? _selectedPrinterMac;
  String? get getSelectedPrinterMac => _selectedPrinterMac;

  void setSelectedPrinterMac(String macAddress) {
    _selectedPrinterMac = macAddress;
    notifyListeners();
  }

  String? _invoiceImage;
  String get getInvoiceImage => _invoiceImage!;

  void setInvoiceImage(String val) {
    _invoiceImage = val;
    notifyListeners();
  }

  String _connectionMode = config.onlineMode;
  String get getConnectionMode => _connectionMode;

  void setConnectionMode(String mode) {
    _connectionMode = mode;
    notifyListeners();
  }

  dynamic _dataLogin;
  dynamic get dataLogin => _dataLogin;
  Future getLogin(
      BuildContext context, String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    EasyLoading.show(status: config.Loading);
    try {
      var res = await globalCollectionServices.getLogin(
        context: context,
        username: username,
        password: password,
      );

      var result = res;
      if (_connectionMode == config.onlineMode)
        result = res == null ? null : json.decode(res);
      _dataLogin = result;

      if (result == null) {
        EasyLoading.dismiss();
        DialogUtils.instance.showError(context: context);
        return null;
      } else if (result['responLogin']['status'] == "Gagal") {
        EasyLoading.dismiss();
        DialogUtils.instance
            .showError(context: context, text: result['responLogin']['pesan']);
      } else {
        config.dataLogin = result['responLogin'];
        config.dataSetting = result['dataSetting'];
        config.dataUser = result['dataUser'];
        //config.dataProvider = result['formatNomorHpIna'];
        //config.plnWarning = result['ketentuan_plntoken'];

        var navigator, arguments;

        if (result['responLogin']['active_flag'] == "N") {
          navigator = RouterGenerator.resetPassword;
          arguments = {'isBuat': true};
        } else {
          prefs.setBool('first_time_login', false);
          prefs.setString('username', result['responLogin']['username']);
          prefs.setString('nama', result['responLogin']['nama']);
          navigator = RouterGenerator.homeKolektor;
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
          navigator,
          (Route<dynamic> route) => false,
          arguments: arguments,
        );
        EasyLoading.dismiss();
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      print(e);
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  Future syncAcount() async {
    try {
      if (dataLogin != null) {
        var syncData =
            await globalCollectionServices.syncAccount(dataLogin['dataUser']);
        print("Account sync was successful with response $syncData");
      }
    } catch (e) {
      print("Error sync data user: $e");
    }
  }

  Future syncMigrateData(
      {BuildContext? context,
      var groupProduk,
      var rekCd,
      DateTime? tglAwal,
      DateTime? tglAkhir}) async {
    var dataMigrasi = await produkCollectionServices.getDataMigrasi(
      context: context,
      groupProduk: groupProduk,
      rekCd: rekCd,
      tglAwal: DateFormat("yyyy-MM-dd").format(tglAwal!),
      tglAkhir: DateFormat("yyyy-MM-dd").format(tglAkhir!),
      lat: latitude.toString(),
      long: longitude.toString(),
    );
    var result = dataMigrasi == null ? null : json.decode(dataMigrasi);
    print("dataMigrasi $groupProduk $dataMigrasi");
    if (result == null) {
      return null;
    } else {
      if (result[0]['res_status'] == 'Gagal') {
        return null;
      }
      var effectedRow = await globalCollectionServices.syncData(
        dataMigrasi: dataMigrasi,
        groupProduk: groupProduk,
        rekCd: rekCd,
      );
      return effectedRow;
    }
  }

  Future syncData(BuildContext context, var products) async {
    try {
      EasyLoading.show(status: config.Loading);
      DateTime last = await globalCollectionServices.lastSync();
      DateTime current = DateTime.now();
      int ditambahkan = 0;
      int diperbaharui = 0;
      String updatedText = '';

      // statis: master nasabah
      var effectedRowCF = await syncMigrateData(
          context: context,
          groupProduk: 'CONFIG',
          rekCd: 'CONFIG',
          tglAwal: last,
          tglAkhir: current);
      if (effectedRowCF != null) {
        updatedText += ' Config,';
        ditambahkan += effectedRowCF['row_add'] as int;
        diperbaharui += effectedRowCF['row_edit'] as int;
      }
      var effectedRowMN = await syncMigrateData(
          context: context,
          groupProduk: 'MASTER_NASABAH',
          rekCd: 'MASTER_NASABAH',
          tglAwal: last,
          tglAkhir: current);
      if (effectedRowMN != null) {
        updatedText += ' Master Nasabah,';
        ditambahkan += effectedRowMN['row_add'] as int;
        diperbaharui += effectedRowMN['row_edit'] as int;
      }
      // dinamis: produk
      for (ProdukCollection product in products) {
        print("Sync data available: ${product.nama}");
      }
      for (ProdukCollection product in products) {
        var effectedRow = await syncMigrateData(
            context: context,
            groupProduk: product.slug,
            rekCd: product.rekCd,
            tglAwal: last,
            tglAkhir: current);
        if (effectedRow != null) {
          updatedText +=
              ' ' + TextUtils().capitalizeEachWord(product.nama!) + ',';
          ditambahkan += effectedRow['row_add'] as int;
          diperbaharui += effectedRow['row_edit'] as int;
        }
      }
      // update db version
      await globalCollectionServices
          .updateSync(DateFormat('yyyy-MM-dd').format(current));

      // jika sudah selesai
      print("Data {$updatedText} was successfully synchronized");
      EasyLoading.dismiss();
      await DialogUtils.instance.showInfo(
        context: context,
        isCancel: false,
        title: "Pemberitahuan!",
        text: "Data berhasil diperbaharui \n\n" +
            "Data ditambahkan : " +
            ditambahkan.toString() +
            "\n" +
            "Data diperbarui : " +
            diperbaharui.toString() +
            "\n\nData yang diperbaharui: $updatedText",
        clickOKText: "TUTUP",
      );
      return true;
    } catch (e) {
      print("Error sync data: $e");
      EasyLoading.dismiss();
    }
  }

  Future isNeedSync() async {
    try {
      bool syncData = await globalCollectionServices.isNeedSync();
      print("syncData $syncData");
      return syncData;
    } catch (e) {
      print("Error is need sync: $e");
    }
  }

  dynamic getLoginPin(BuildContext context, String pin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    EasyLoading.show(status: config.Loading);
    try {
      var res = await globalCollectionServices.getLoginPin(
        context: context,
        username: prefs.getString('username'),
        pin: pin,
      );
      var result = res == null ? null : json.decode(res);
      if (result == null) {
        EasyLoading.dismiss();
        DialogUtils.instance.showError(context: context);
        return null;
      } else if (result['responLogin']['status'] == "Gagal") {
        EasyLoading.dismiss();
        DialogUtils.instance
            .showError(context: context, text: result['responLogin']['pesan']);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            RouterGenerator.homePage, (Route<dynamic> route) => false);

        config.dataLogin = result['responLogin'];
        config.dataSetting = result['dataSetting'];
        config.dataProvider = result['formatNomorHpIna'];
        config.plnWarning = result['ketentuan_plntoken'];
        EasyLoading.dismiss();
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      print(e);
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  dynamic resetPassword(
    BuildContext context,
    String password,
    bool isBuat,
  ) async {
    if (isBuat) EasyLoading.show(status: config.Loading);
    try {
      var result = await globalCollectionServices.resetPassword(
          context: context, password: password);
      var res = result == null ? null : json.decode(result);
      EasyLoading.dismiss();
      if (res == null) {
        DialogUtils.instance.showError(context: context);
        return false;
      } else {
        if (res[0]['status'] == 'Gagal') {
          DialogUtils.instance.showError(
            context: context,
            text: res[0]['pesan'],
          );
          return false;
        } else {
          if (isBuat) {
            await DialogUtils.instance.showInfo(
              context: context,
              title: "Pemberitahuan!",
              text:
                  "Password berhasil dibuat, Anda akan segera dialihkan ke halaman PIN",
              isCancel: false,
              clickOKText: "OK",
            );
          } else {
            await DialogUtils.instance.showInfo(
              context: context,
              title: "Pemberitahuan!",
              text: res[0]['pesan'],
              isCancel: false,
              clickOKText: "OK",
            );
          }
          return true;
        }
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return false;
    } catch (e) {
      print(e);
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return false;
    }
  }

  dynamic resetPin(
    BuildContext context,
    String pin,
    bool isBuat,
  ) async {
    if (isBuat) EasyLoading.show(status: config.Loading);
    try {
      var result =
          await globalCollectionServices.resetPin(context: context, pin: pin);
      var res = result == null ? null : json.decode(result);
      EasyLoading.dismiss();
      if (res == null) {
        DialogUtils.instance.showError(context: context);
        return false;
      } else {
        if (res[0]['status'] == 'Gagal') {
          DialogUtils.instance.showError(
            context: context,
            text: res[0]['pesan'],
          );
          return false;
        } else {
          if (isBuat) {
            await DialogUtils.instance.showInfo(
              context: context,
              title: "Pemberitahuan!",
              text:
                  "PIN berhasil dibuat, Anda akan segera dialihkan ke halaman Login",
              isCancel: false,
              clickOKText: "OK",
            );
          } else {
            await DialogUtils.instance.showInfo(
              context: context,
              title: "Pemberitahuan!",
              text: res[0]['pesan'],
              isCancel: false,
              clickOKText: "OK",
            );
          }
          return true;
        }
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return false;
    } catch (e) {
      print(e);
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return false;
    }
  }

  dynamic checkReEncryptData(
    BuildContext context,
    String data,
  ) async {
    EasyLoading.show(status: config.Loading);
    try {
      var result = await globalCollectionServices.checkReEncryptData(
        context: context,
        data: data,
      );
      var res = result == null ? null : json.decode(result);
      EasyLoading.dismiss();
      if (res == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        return res;
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      print(e);
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  //my location service
  String? _myAddress;
  String get myAddress => _myAddress!;

  double? _myLatitude;
  double? get myLatitude => _myLatitude;
  double? _myLongitude;
  double? get myLongitude => _myLongitude;

  //location service
  String? _address;
  String get address => _address!;

  double? _latitude;
  double get latitude => _latitude ?? 0;
  double? _longitude;
  double get longitude => _longitude ?? 0;

  LocationUtils locationUtils = setup<LocationUtils>();

  dynamic loadLocation(BuildContext context) async {
    bool res = await locationUtils.getLocation(context) ?? false;
    if (res) {
      _myAddress = await locationUtils.getAddress();
      _myLatitude = locationUtils.latitude;
      _myLongitude = locationUtils.longitude;
      notifyListeners();
    }
  }

  dynamic setLocation({
    double? latitude,
    double? longitude,
  }) async {
    _address = await locationUtils.getAddressByCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }

  String getImageProduk(String produk) {
    String img = 'assets/images/tab-slide.png';
    if (produk == 'TABUNGAN') img = 'assets/images/tab-slide.png';
    if (produk == 'DEPOSITO') img = 'assets/images/dep-slide.png';
    if (produk == 'PINJAMAN') img = 'assets/images/kredit-slide.png';
    return img;
  }

  String getIconProduk(String rekCd) {
    String img = 'assets/images/tab-slide.png';
    if (rekCd == 'SIMP_SUKARELA') img = 'assets/icon/tab-slide.png';
    if (rekCd == 'SIMP_ANGGOTA') img = 'assets/images/dep-slide.png';
    if (rekCd == 'SIMP_BERJANGKA') img = 'assets/images/kredit-slide.png';
    if (rekCd == 'KREDIT') img = 'assets/images/kredit-slide.png';
    return img;
  }

  String getTransCd(String groupProduk, String tipeTrans) {
    String transCd = '-';
    if (groupProduk == 'TABUNGAN') {
      if (tipeTrans == 'SETOR')
        transCd = 'STT';
      else
        transCd = 'TTT';
    } else if (groupProduk == 'ANGGOTA') {
      if (tipeTrans == 'SETOR')
        transCd = 'STW';
      else
        transCd = 'TTW';
    } else if (groupProduk == 'DEPOSITO' || groupProduk == 'BERENCANA') {
      if (tipeTrans == 'SETOR')
        transCd = 'STJ';
      else
        transCd = 'PTJ';
    } else if (groupProduk == 'KREDIT') {
      transCd = 'PKT';
    }

    return transCd;
  }

  Future<dynamic> uploadProgressLocalNotification(
    int maxProgress,
    int progress,
  ) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? "ANDROID" : "IOS",
      config.companyName,
      // config.companyFullName,
      channelDescription: config.companyFullName,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
    );
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        123,
        "Upload transaksi offline",
        progress.toString() + " of " + maxProgress.toString() + " Uploaded",
        platformChannelSpecifics);
  }

  dynamic exportDB(BuildContext context, String path) async {
    try {
      File result = await globalCollectionServices.copyDB();

      Directory documentsDirectory = Directory(path);

      String newPath = join(documentsDirectory.absolute.path +
          '/' +
          config.mobileName.replaceAll(RegExp(r' '), '_') +
          '_db.db');

      File b = File("${result.path}" + "/sqlite_koperasi.db");

      if ((await Permission.manageExternalStorage.request().isGranted ||
              await Permission.storage.request().isGranted) &&
          await Permission.accessMediaLocation.request().isGranted) {
        File a = await b.copy(newPath);
        DialogUtils.instance.showInfo(
            context: context,
            title: 'Database Tersimpan',
            text: "Database berhasil disimpan pada $a",
            isCancel: false,
            clickOKText: "TUTUP");
      } else {
        DialogUtils.instance.showError(
            context: context,
            text: "Export Database error: No Permission Granted!");
      }
    } catch (e) {
      DialogUtils.instance
          .showError(context: context, text: "Export Database error: $e");
    }
  }

  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;

  dynamic checkUpdate(BuildContext context) async {
    try {
      UpdateInfo? resp =
          await globalCollectionServices.checkUpdate(context: context);
      if (resp == null) {
        _updateInfo =
            new UpdateInfo(title: '', version: '', desc: '', type: 'NO_UPDATE');
      } else {
        _updateInfo = resp;
      }
    } catch (e) {
      print('error check update with message $e');
    }
  }

  dynamic getLocalConfig() async {
    try {
      var localCfg = await globalCollectionServices.getLocalConfig();
      return localCfg;
    } catch (e) {
      print("error get local config with message $e");
    }
  }
}
