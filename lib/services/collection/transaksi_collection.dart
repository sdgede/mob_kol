import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../config/config.dart';
import '../../database/databaseHelper.dart';
import '../../database/table_config.dart' as tbConf;
import '../../model/global_model.dart';
import '../../services/base/base_services.dart';
import '../../services/utils/mcrypt_utils.dart';

class TransaksiCollectionServices extends BaseServices {
  final dbHelper = DatabaseHelper.instance;

  Future<SuksesTransaksiModel?> prosesTransaksiKolektor({
    BuildContext? context,
    String? rekCd,
    String? groupProduk,
    String? tipeTrans,
    String? kodeVa,
    String? norek,
    String? jumlah,
    String? pokok,
    String? bunga,
    String? denda,
    String? lateCharge,
    String? remark,
    String? produkId,
    String? lat,
    String? long,
    String? connMode,
    String? action,
  }) async {
    var dataTransaksi = Map<String, dynamic>();
    String urlWs = ConfigURL().urlApiTransaksiTabungan;

    if (groupProduk == 'TABUNGAN') {
      dataTransaksi["req"] = "insertTtransTab";
      urlWs = ConfigURL().urlApiTransaksiTabungan;
    } else if (groupProduk == 'ANGGOTA') {
      dataTransaksi["req"] = "insertTtransAnggota";
      urlWs = ConfigURL().urlApiTransaksiTabungan;
    } else if (groupProduk == 'BERENCANA') {
      dataTransaksi["req"] = "insertTtransSirena";
      urlWs = ConfigURL().urlApiTransaksiDeposito;
    } else if (groupProduk == 'KREDIT') {
      dataTransaksi["req"] = "insertTtransKredit";
      urlWs = ConfigURL().urlApiTransaksiKredit;
    }

    dataTransaksi["groupProduk"] = McryptUtils.instance.encrypt(groupProduk!);
    dataTransaksi["produkId"] = McryptUtils.instance.encrypt(produkId!);
    dataTransaksi["rekCd"] = McryptUtils.instance.encrypt(rekCd!);
    dataTransaksi["wilayahCd"] = McryptUtils.instance.encrypt(dataLogin['wilayah_cd'] ?? '01');
    dataTransaksi["tipeTrans"] = McryptUtils.instance.encrypt(tipeTrans!);
    dataTransaksi["norek"] = McryptUtils.instance.encrypt(norek!);
    dataTransaksi["jumlah"] = McryptUtils.instance.encrypt(jumlah!);
    dataTransaksi["pokok"] = McryptUtils.instance.encrypt(pokok ?? "0");
    dataTransaksi["bunga"] = McryptUtils.instance.encrypt(bunga ?? "0");
    dataTransaksi["denda"] = McryptUtils.instance.encrypt(denda ?? "0");
    dataTransaksi["lateCharge"] = McryptUtils.instance.encrypt(lateCharge ?? "0");
    dataTransaksi["trx_remark"] = McryptUtils.instance.encrypt(remark ?? "");
    dataTransaksi["kolektor"] = McryptUtils.instance.encrypt(dataLogin['username']);
    dataTransaksi["pwd"] = McryptUtils.instance.encrypt(dataLogin['password']);
    dataTransaksi["unique_id"] = McryptUtils.instance.encrypt(Uuid().v7());

    //data log
    dataTransaksi["lat"] = McryptUtils.instance.encrypt(lat!);
    dataTransaksi["longi"] = McryptUtils.instance.encrypt(long!);
    dataTransaksi["imei"] = McryptUtils.instance.encrypt(dataLogin['imei']);

    var resp;

    if (connMode == offlineMode && !["SINGLE_UPLOAD", "MULTIPLE_UPLOAD"].contains(action))
      resp = await dbHelper.insertTransaksiOffline(dataTransaksi, tbConf.tbTrxGlobal);
    else
      resp = await request(
        context: context,
        url: urlWs,
        type: RequestType.POST,
        data: dataTransaksi,
      );

    SuksesTransaksiModel? responSukses;

    if (resp != null) {
      var jsonData = json.decode(resp);
      responSukses = new SuksesTransaksiModel.fromJson(jsonData[0]);
    }

    return responSukses;
  }

  Future sendNotifikasiTransaksiWhatsApp({
    BuildContext? context,
    String? rekCd,
    String? transId,
  }) async {
    var dataNotifikasi = Map<String, dynamic>();
    dataNotifikasi["req"] = "sendNotifikasiTransaksiWhatsApp";
    dataNotifikasi["rek_cd"] = McryptUtils.instance.encrypt(rekCd!);
    dataNotifikasi["trans_id"] = McryptUtils.instance.encrypt(transId!);

    await request(
      context: context,
      url: ConfigURL().urlApiNotifikasi,
      type: RequestType.POST,
      data: dataNotifikasi,
    );
  }
}
