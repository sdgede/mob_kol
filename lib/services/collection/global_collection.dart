import 'dart:convert';
import 'dart:io';
import 'package:sevanam_mobkol/model/global_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/databaseHelper.dart';
import '../../services/viewmodel/global_provider.dart';
import '../../model/daftar_online_model.dart';
import '../base/base_services.dart';
import '../config/config.dart';
import '../utils/mcrypt_utils.dart';
import '../utils/text_utils.dart';
import 'dart:io' as io;

import '../config/config.dart' as config;
import '../../ui/constant/constant.dart' as constant;

class GlobalCollectionServices extends BaseServices {
  late GlobalProvider globalProv;
  final dbHelper = DatabaseHelper.instance;

  Future<List<ListChoiceModel>> getDataCustom({
    BuildContext? context,
    String? jenis,
  }) async {
    var dataCustom = Map<String, dynamic>();
    dataCustom["req"] = "getDataCustom";
    dataCustom["code"] = McryptUtils.instance.encrypt(jenis ?? "");

    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataCustom,
    );

    List<ListChoiceModel>? customCollection = [];

    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        customCollection.add(ListChoiceModel.fromJson(val));
      });
    }

    return customCollection;
  }

  dynamic getLogin({
    BuildContext? context,
    String? username,
    String? password,
  }) async {
    globalProv = Provider.of<GlobalProvider>(context!, listen: false);
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "getLogin";
    dataLogin["username"] = McryptUtils.instance.encrypt(username!);
    dataLogin["pwd"] = McryptUtils.instance.encrypt(password!);
    dataLogin["platform"] = McryptUtils.instance.encrypt(Platform.isAndroid ? "ANDROID" : "IOS");
    dataLogin["imei"] = McryptUtils.instance.encrypt(platform!);
    dataLogin["sn"] = McryptUtils.instance.encrypt(platform!);
    dataLogin["versi"] = McryptUtils.instance.encrypt(Platform.isAndroid ? versiApkMobile : versiApkIOS);
    dataLogin["reg_firebase_id"] = McryptUtils.instance.encrypt(firebaseId);

    var resp;

    if (globalProv.getConnectionMode == offlineMode)
      resp = dbHelper.getLoginOffline(dataLogin);
    else {
      resp = await request(
        context: context,
        url: ConfigURL().urlApiLogin,
        type: RequestType.POST,
        data: dataLogin,
      );
    }

    return resp;
  }

  dynamic syncAccount(dynamic val) async {
    var res = await dbHelper.manageSyncAccount(val);
    return res;
  }

  dynamic syncData({var dataMigrasi, var groupProduk, var rekCd}) async {
    var actionMigrate;

    if (groupProduk == 'DATA_AKUN') {
      actionMigrate = await dbHelper.manageDataMigrationAccount(dataMigrasi, groupProduk, rekCd);
    } else if (groupProduk == 'MASTER_NASABAH') {
      actionMigrate = await dbHelper.manageDataMigrationNasabah(dataMigrasi, groupProduk, rekCd);
    } else if (groupProduk == 'CONFIG') {
      actionMigrate = await dbHelper.manageDataMigrationConfig(dataMigrasi);
    } else {
      actionMigrate = await dbHelper.manageDataMigrationProduct(dataMigrasi, groupProduk, rekCd);
    }

    return actionMigrate;
  }

  dynamic lastSync() async {
    var lastSync = await dbHelper.lastSync();

    lastSync = lastSync == null ? DateTime.now().subtract(Duration(days: 1)) : new DateFormat("yyyy-MM-dd").parse(lastSync);
    return lastSync;
  }

  dynamic updateSync(String current) async {
    var updateSync = await dbHelper.updateSync(current);

    var lastSync = await dbHelper.lastSync();
    lastSync = new DateFormat("yyyy-MM-dd").parse(lastSync);
    return updateSync;
  }

  dynamic isNeedSync() async {
    var lastSync = await dbHelper.lastSync();

    // jika belum pernah melakukan sinkronisasi
    if (lastSync == null) return true;

    // jika masih hari ini
    DateTime lastSyncDate = new DateFormat("yyyy-MM-dd").parse(lastSync);
    DateTime current = new DateTime.now();
    if (lastSyncDate.year == current.year && lastSyncDate.month == current.month && lastSyncDate.day == current.day) {
      return false;
    }

    return true;
  }

  dynamic getLoginPin({
    BuildContext? context,
    String? username,
    String? pin,
  }) async {
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "getLoginPin";
    dataLogin["username"] = McryptUtils.instance.encrypt(username!);
    dataLogin["pin"] = McryptUtils.instance.encrypt(pin!);
    dataLogin["platform"] = McryptUtils.instance.encrypt(Platform.isAndroid ? "ANDROID" : "IOS");
    dataLogin["imei"] = McryptUtils.instance.encrypt(platform!);
    dataLogin["sn"] = McryptUtils.instance.encrypt(platform!);
    dataLogin["versi"] = McryptUtils.instance.encrypt(Platform.isAndroid ? versiApkMobile : versiApkIOS);
    dataLogin["reg_firebase_id"] = McryptUtils.instance.encrypt(firebaseId);

    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataLogin,
    );

    return resp;
  }

  dynamic resetPassword({
    BuildContext? context,
    String? password,
  }) async {
    var dataReset = Map<String, dynamic>();
    dataReset["req"] = "gantiPassword";
    dataReset["password"] = McryptUtils.instance.encrypt(password!);
    dataReset["id_user"] = McryptUtils.instance.encrypt(dataLogin['ID_USER']);
    dataReset["username"] = McryptUtils.instance.encrypt(dataLogin['username']);

    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataReset,
    );

    return resp;
  }

  dynamic resetPin({
    BuildContext? context,
    String? pin,
  }) async {
    var dataReset = Map<String, dynamic>();
    dataReset["req"] = "gantiPIN";
    dataReset["pin"] = McryptUtils.instance.encrypt(pin!);
    dataReset["id_user"] = McryptUtils.instance.encrypt(dataLogin['ID_USER']);
    dataReset["username"] = McryptUtils.instance.encrypt(dataLogin['username']);

    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataReset,
    );

    return resp;
  }

  dynamic checkReEncryptData({
    BuildContext? context,
    String? data,
  }) async {
    var decrypt = McryptUtils.instance.decryptMerchant(data!);
    if (decrypt == '') {
      var dataReset = Map<String, dynamic>();
      dataReset["req"] = "getReEncryptData";
      dataReset["data"] = data;

      var resp = await request(
        context: context,
        url: ConfigURL().urlApiLogin,
        type: RequestType.POST,
        typeEncrypt: TypeEncrypt.MERCHANT,
        data: dataReset,
      );
      return resp;
    } else {
      return TextUtils.instance.customDecrypt(decrypt);
    }
  }

  Future checkNomorRekening({
    BuildContext? context,
    String? noRekening,
  }) async {
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "checkNomorRekening";
    dataLogin["norek"] = McryptUtils.instance.encrypt(noRekening!);
    print(dataLogin);
    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataLogin,
    );
    print(resp);
    return resp;
  }

  Future checkHPNIK({
    BuildContext? context,
    String? type,
    String? nomor,
  }) async {
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "checkHPNIK";
    dataLogin["type"] = McryptUtils.instance.encrypt(type!);
    dataLogin["nomor"] = McryptUtils.instance.encrypt(nomor!);

    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataLogin,
    );

    return resp;
  }

  Future<io.File> copyDB() async {
    var dbPath = await dbHelper.copyDB();
    return dbPath;
  }

  Future<UpdateInfo?> checkUpdate({BuildContext? context}) async {
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "checkUpdate";
    dataLogin["versi"] = McryptUtils.instance.encrypt(Platform.isAndroid ? versiApkMobile : versiApkIOS);

    var resp = await request(
      context: context,
      url: ConfigURL().urlApiLogin,
      type: RequestType.POST,
      data: dataLogin,
    );

    print("check update resp $resp");

    if (resp != null) {
      var jsonData = json.decode(resp);
      return UpdateInfo.fromJson(jsonData);
    }

    return null;
  }

  dynamic getLocalConfig() async {
    try {
      var localCfg = await dbHelper.getLocalConfig();
      constant.bgCustom = "assets/images/" + localCfg['primaryBg'];
      // config.baseURL = McryptUtils.instance.decrypt(localCfg['base_url']);
      config.mobileName = localCfg['nama_app'];
      config.companyFullName = localCfg['nama_instansi_full'];
      config.companyName = localCfg['nama_instansi_short'];
      config.nomorCompany = localCfg['no_hp_instansi'];
      config.nomorWhatsAppCompany = localCfg['no_wa_instansi'];
      config.emailCompany = localCfg['email_instansi'];
      config.clientType = config.ClientTypeExtension.fromString(localCfg['client_type'] ?? '');
      constant.primaryColor = Color(int.parse(localCfg['primaryColor']));
      constant.accentColor = Color(int.parse(localCfg['accentColor']));

      return localCfg;
    } catch (e) {
      print("error get local config $e");
      return null;
    }
  }
}
