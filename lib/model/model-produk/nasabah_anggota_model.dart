import 'package:sevanam_mobkol/model/model-produk/_base_helper_produk.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';

class NasabahAnggotaModel implements BaseProdukModelInterface {
  String dbTable = 'm_nasabah_anggota';
  String dbPk = 'nasabah_anggota_id';
  String dbGroupMenu = 'ANGGOTA';
  String dbRekCd = 'SIMP_ANGGOTA';
  String dbNorekField = 'no_anggota';

  String nasabahAnggotaId;
  String nasabahId;
  String noMaster;
  String noAnggota;
  String pokok;
  String wajibAwal;
  String tglDaftar;
  String tglTutup;
  String alasanTutup;
  String potongan;
  String status;
  String remark;
  String groupCd;
  String wilayahCd;
  String caraBayarWajib;
  String norekTransfer;
  String createWho;
  String createDate;
  String changeWho;
  String changeDate;
  String noAnggotaPlain;
  String tipeKeluar;

  NasabahAnggotaModel({
    this.nasabahAnggotaId = "",
    this.nasabahId = "",
    this.noMaster = "",
    this.noAnggota = "",
    this.pokok = "",
    this.wajibAwal = "",
    this.tglDaftar = "",
    this.tglTutup = "",
    this.alasanTutup = "",
    this.potongan = "",
    this.status = "",
    this.remark = "",
    this.groupCd = "",
    this.wilayahCd = "",
    this.caraBayarWajib = "",
    this.norekTransfer = "",
    this.createWho = "",
    this.createDate = "",
    this.changeWho = "",
    this.changeDate = "",
    this.noAnggotaPlain = "",
    this.tipeKeluar = "",
  }) : super();

  @override
  factory NasabahAnggotaModel.fromJson(Map<String, dynamic> json) {
    return NasabahAnggotaModel(
      nasabahAnggotaId: json['nasabah_anggota_id'] ?? (json['produk_id'] ?? ""),
      nasabahId: json['nasabah_id'] ?? "",
      noMaster: json['no_master'] ?? "",
      noAnggota: (json['no_anggota'] ?? json['no_rek']) ?? "",
      pokok: json['pokok'] ?? "",
      wajibAwal: json['wajib_awal'] ?? "",
      tglDaftar: json['tgl_daftar'] ?? "",
      tglTutup: json['tgl_tutup'] ?? "",
      alasanTutup: json['alasan_tutup'] ?? "",
      potongan: json['potongan'] ?? "",
      status: json['status'] ?? "",
      remark: json['remark'] ?? "",
      groupCd: json['group_cd'] ?? "",
      wilayahCd: json['wilayah_cd'] ?? "",
      caraBayarWajib: json['cara_bayar_wajib'] ?? "",
      norekTransfer: json['norek_transfer'] ?? "",
      createWho: json['create_who'] ?? "",
      createDate: json['create_date'] ?? "",
      changeWho: json['change_who'] ?? "",
      changeDate: json['change_date'] ?? "",
      noAnggotaPlain: json['no_anggota_plain'] ?? "",
      tipeKeluar: json['tipe_keluar'] ?? "",
    );
  }

  @override
  String getPrimaryKeyValue() {
    return nasabahAnggotaId;
  }

  @override
  Map<String, String>? prepareRow() {
    return {
      "nasabah_anggota_id": nasabahAnggotaId,
      "nasabah_id": nasabahId,
      "no_master": noMaster,
      "no_anggota": noAnggota,
      "pokok": pokok,
      "wajib_awal": wajibAwal,
      "tgl_daftar": tglDaftar,
      "tgl_tutup": tglTutup,
      "alasan_tutup": alasanTutup,
      "potongan": potongan,
      "status": status,
      "remark": remark,
      "group_cd": groupCd,
      "wilayah_cd": wilayahCd,
      "cara_bayar_wajib": caraBayarWajib,
      "norek_transfer": norekTransfer,
      "create_who": createWho,
      "create_date": createDate,
      "change_who": changeWho,
      "change_date": changeDate,
      "no_anggota_plain": noAnggotaPlain,
      "tipe_keluar": tipeKeluar,
    };
  }

  @override
  Future<dynamic>? searchByName(String keyword, String? rekCd) async {
    return BaseHelperProduk().searchByNameNasabah(keyword, rekCd, dbTable, dbPk);
  }

  @override
  Future<dynamic>? searchByNorek(String norek, String? rekCd) async {
    return BaseHelperProduk().searchByNorekNasabahAnggota(norek, rekCd, dbTable, dbPk);
  }

  @override
  Future<Map<String, int>?> upsertMigration() async {
    return BaseHelperProduk().upsertMigration(prepareRow, getPrimaryKeyValue, dbTable, dbPk);
  }
}
