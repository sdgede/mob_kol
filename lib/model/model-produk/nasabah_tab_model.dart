import 'package:sevanam_mobkol/model/model-produk/_base_helper_produk.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';

class NasabahTabModel implements BaseProdukModelInterface {
  String dbTable = 'm_nasabah_tab';
  String dbPk = 'nasabah_tab_id';
  String dbGroupMenu = 'TABUNGAN';
  String dbRekCd = 'TABRELA';
  String dbNorekField = 'no_rek';

  String nasabahTabId;
  String nasabahId;
  String noMaster;
  String wilayahCd;
  String groupCd;
  String rekCd;
  String noRek;
  String setoranAwal;
  String status;
  String tglDaftar;
  String tglTutup;
  String alasanTutup;
  String potongan;
  String remark;
  String caraBayar;
  String noRekSumber;
  String createWho;
  String createDate;
  String changeWho;
  String changeDate;
  String noRekPlain;

  NasabahTabModel({
    this.nasabahTabId = "",
    this.nasabahId = "",
    this.noMaster = "",
    this.wilayahCd = "",
    this.groupCd = "",
    this.rekCd = "",
    this.noRek = "",
    this.setoranAwal = "",
    this.status = "",
    this.tglDaftar = "",
    this.tglTutup = "",
    this.alasanTutup = "",
    this.potongan = "",
    this.remark = "",
    this.caraBayar = "",
    this.noRekSumber = "",
    this.createWho = "",
    this.createDate = "",
    this.changeWho = "",
    this.changeDate = "",
    this.noRekPlain = "",
  }) : super();

  @override
  factory NasabahTabModel.fromJson(Map<String, dynamic> json) {
    return NasabahTabModel(
      nasabahTabId: json['nasabah_tab_id'] ?? (json['produk_id'] ?? ""),
      nasabahId: json['nasabah_id'] ?? "",
      noMaster: json['no_master'] ?? "",
      wilayahCd: json['wilayah_cd'] ?? "",
      groupCd: json['group_cd'] ?? "",
      rekCd: json['rek_cd'] ?? "",
      noRek: json['no_rek'] ?? "",
      setoranAwal: json['setoran_awal'] ?? "",
      status: json['status'] ?? "",
      tglDaftar: json['tgl_daftar'] ?? "",
      tglTutup: json['tgl_tutup'] ?? "",
      alasanTutup: json['alasan_tutup'] ?? "",
      potongan: json['potongan'] ?? "",
      remark: json['remark'] ?? "",
      caraBayar: json['cara_bayar'] ?? "",
      noRekSumber: json['no_rek_sumber'] ?? "",
      createWho: json['create_who'] ?? "",
      createDate: json['create_date'] ?? "",
      changeWho: json['change_who'] ?? "",
      changeDate: json['change_date'] ?? "",
      noRekPlain: json['no_rek_plain'] ?? "",
    );
  }

  @override
  String getPrimaryKeyValue() {
    return nasabahTabId;
  }

  @override
  Map<String, String>? prepareRow() {
    return {
      "nasabah_tab_id": nasabahTabId,
      "nasabah_id": nasabahId,
      "no_master": noMaster,
      "wilayah_cd": wilayahCd,
      "group_cd": groupCd,
      "rek_cd": rekCd,
      "no_rek": noRek,
      "setoran_awal": setoranAwal,
      "status": status,
      "tgl_daftar": tglDaftar,
      "tgl_tutup": tglTutup,
      "alasan_tutup": alasanTutup,
      "potongan": potongan,
      "remark": remark,
      "cara_bayar": caraBayar,
      "no_rek_sumber": noRekSumber,
      "create_who": createWho,
      "create_date": createDate,
      "change_who": changeWho,
      "change_date": changeDate,
      "no_rek_plain": noRekPlain,
    };
  }

  @override
  Future<dynamic>? searchByName(String keyword, String? rekCd) async {
    return BaseHelperProduk().searchByNameNasabah(keyword, rekCd, dbTable, dbPk);
  }

  @override
  Future<dynamic>? searchByNorek(String norek, String? rekCd) async {
    return BaseHelperProduk().searchByNorekNasabahTab(norek, rekCd, dbTable, dbPk);
  }

  @override
  Future<Map<String, int>?> upsertMigration() async {
    return BaseHelperProduk().upsertMigration(prepareRow, getPrimaryKeyValue, dbTable, dbPk);
  }
}
