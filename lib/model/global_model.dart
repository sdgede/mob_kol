import 'package:flutter/cupertino.dart';

class CustomIcons {
  String? image, name, navigator, tipe, title;
  bool isDev, isPembayaran;

  CustomIcons({
    this.image,
    this.name,
    this.navigator,
    this.tipe,
    this.title,
    this.isDev = false,
    this.isPembayaran = false,
  });
}

class Slider {
  final String sliderImageUrl;
  final String sliderHeading;
  final String sliderSubHeading;

  Slider({
    required this.sliderImageUrl,
    required this.sliderHeading,
    required this.sliderSubHeading,
  });
}

class ComboBoxModel {
  final String? value, desc, data;

  ComboBoxModel({
    required this.value,
    required this.desc,
    this.data,
  });
}

class SuksesTransaksiModel {
  String? noReferensi, trxDate, status, pesan, kode, rekCd;
  String? who, keterangan, groupProduk, norek, nama, hp, terbilang;
  dynamic saldo, saldo_awal, saldo_akhir, pokok, bunga, denda, jumlah, adm;
  dynamic idTrx;
  List<Map<String, dynamic>>? dataNotif;

  SuksesTransaksiModel({
    this.noReferensi,
    this.trxDate,
    this.norek,
    this.nama,
    this.pokok,
    this.bunga,
    this.denda,
    this.jumlah,
    this.saldo,
    this.keterangan,
    this.groupProduk,
    this.who,
    this.status,
    this.pesan,
    this.dataNotif,
    this.kode,
    this.saldo_awal,
    this.saldo_akhir,
    this.adm,
    this.terbilang,
    this.hp,
    this.idTrx,
    this.rekCd,
  });

  factory SuksesTransaksiModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? _dataNotif = [];
    if (json['dataNotif'] != null)
      for (var val in json['dataNotif']) {
        _dataNotif.add({
          "rek_cd": val['rek_cd'],
          "trans_id": val['trans_id'].toString(),
        });
      }
    else
      _dataNotif = null;

    return SuksesTransaksiModel(
      noReferensi: json['no_referensi'],
      trxDate: json["trx_date"] ?? "",
      kode: json["kode"] ?? "",
      norek: json["norek"] ?? "",
      nama: json["nama"] ?? "",
      hp: json["no_hp"] ?? "",
      rekCd: json["rekCd"] ?? "",
      idTrx: json["lastId"] ?? "",
      pokok: json["pokok"] ?? "",
      bunga: json["bunga"] ?? "",
      denda: json["denda"] ?? "",
      jumlah: json["jumlah"] ?? "",
      saldo: json["saldo"] ?? "",
      saldo_awal: json["saldo_awal"] ?? "",
      saldo_akhir: json["saldo_akhir"] ?? "",
      adm: json["adm"] ?? "",
      terbilang: json["terbilang"] ?? "",
      keterangan: json["keterangan"] ?? "",
      groupProduk: json["groupProduk"] ?? "",
      who: json["who"] ?? "",
      pesan: json["pesan"] ?? "",
      status: json["status"] ?? "",
      dataNotif: _dataNotif,
    );
  }
}

class BluetoothPrinterModel {
  dynamic noReferensi, trxDate, kode;
  dynamic norek, nama, hp, pokok, bunga, denda, jumlah, terbilang;
  dynamic saldo, saldo_awal, saldo_akhir, who, keterangan, groupProduk;

  BluetoothPrinterModel({
    this.noReferensi,
    this.trxDate,
    this.norek,
    this.nama,
    this.pokok,
    this.bunga,
    this.denda,
    this.jumlah,
    this.saldo,
    this.keterangan,
    this.groupProduk,
    this.who,
    this.kode,
    this.saldo_awal,
    this.saldo_akhir,
    this.terbilang,
    this.hp,
  });

  factory BluetoothPrinterModel.fromJson(Map<String, dynamic> json) {
    return BluetoothPrinterModel(
      noReferensi: json['no_referensi'],
      trxDate: json["trx_date"] ?? "",
      kode: json["kode"] ?? "",
      norek: json["norek"] ?? "",
      nama: json["nama"] ?? "",
      hp: json["no_hp"] ?? "",
      pokok: json["pokok"] ?? "",
      bunga: json["bunga"] ?? "",
      denda: json["denda"] ?? "",
      jumlah: json["jumlah"] ?? "",
      saldo: json["saldo"] ?? "",
      saldo_awal: json["saldo_awal"] ?? "",
      saldo_akhir: json["saldo_akhir"] ?? "",
      terbilang: json["terbilang"] ?? "",
      keterangan: json["keterangan"] ?? "",
      groupProduk: json["groupProduk"] ?? "",
      who: json["who"] ?? "",
    );
  }
}

class OTPModel {
  String? requestOtpId, serverId, kodeOtp, tglRequest, tglExpired;
  String? tglExpired2, status, pesan;

  OTPModel({
    this.requestOtpId,
    this.serverId,
    this.kodeOtp,
    this.tglRequest,
    this.tglExpired,
    this.tglExpired2,
    this.status,
    this.pesan,
  });

  factory OTPModel.fromJson(Map<String, dynamic> json) {
    return OTPModel(
      requestOtpId: json['request_otp_id'] ?? "",
      serverId: json['server_id'] ?? "",
      kodeOtp: json['kode_otp'] ?? "",
      tglRequest: json['tgl_request'] ?? "",
      tglExpired: json['tgl_expired'] ?? "",
      tglExpired2: json['tgl_expired2'] ?? "",
      status: json['status'] ?? "",
      pesan: json['pesan'] ?? "",
    );
  }
}

class ListModelKol {
  String? title, navigator, description;
  String? icon, type;
  bool? isDev;
  GlobalKey? key;

  ListModelKol({this.type, this.title, this.navigator, this.icon, this.isDev = false, this.key, this.description});
}

class UpdateInfo {
  String? version;
  String? title;
  String? desc;
  String? type;
  String? img;
  String? url;

  UpdateInfo({this.version, this.title, this.desc, this.type, this.img, this.url});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['versi_update'] ?? "",
      title: json['judul'] ?? "",
      desc: json['desc'] ?? "",
      type: json['tipe_update'] ?? "",
      img: json['img'] ?? "",
      url: json['url_update'] ?? "",
    );
  }
}
