import 'package:sevanam_mobkol/model/model-produk/_base_helper_produk.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';

class NasabahSirenaModel implements BaseProdukModelInterface {
  String dbTable = 'm_nasabah_sirena';
  String dbPk = 'nasabah_sirena_id';
  String dbGroupMenu = 'BERENCANA';
  String dbRekCd = 'SIRENA';
  String dbNorekField = 'no_rek';

  String nasabahSirenaId;
  String nasabahId;
  String statusAnggota;
  String noMaster;
  String noMasterLama;
  String noRek;
  String setoranAwal;
  String setoranPerBulan;
  String jumlahDiterima;
  String jangkaWaktu;
  String startDate;
  String endDate;
  String sukuBunga;
  String tglTutup;
  String alasanTutup;
  String status;
  String remark;
  String wilayahCd;
  String groupCd;
  String denda;
  String adm;
  String mat;
  String potongan;
  String caraBayar;
  String norekTransfer;
  String createWho;
  String createDate;
  String changeWho;
  String changeDate;
  String noRekPlain;
  String sumberDana;
  String pejabat;
  String isAutodebet;
  String tglAutodebet;
  String jumlahAutodebet;
  String pajak;
  String ao;

  NasabahSirenaModel({
    this.nasabahSirenaId = "",
    this.nasabahId = "",
    this.statusAnggota = "",
    this.noMaster = "",
    this.noMasterLama = "",
    this.noRek = "",
    this.setoranAwal = "",
    this.setoranPerBulan = "",
    this.jumlahDiterima = "",
    this.jangkaWaktu = "",
    this.startDate = "",
    this.endDate = "",
    this.sukuBunga = "",
    this.tglTutup = "",
    this.alasanTutup = "",
    this.status = "",
    this.remark = "",
    this.wilayahCd = "",
    this.groupCd = "",
    this.denda = "",
    this.adm = "",
    this.mat = "",
    this.potongan = "",
    this.caraBayar = "",
    this.norekTransfer = "",
    this.createWho = "",
    this.createDate = "",
    this.changeWho = "",
    this.changeDate = "",
    this.noRekPlain = "",
    this.sumberDana = "",
    this.pejabat = "",
    this.isAutodebet = "",
    this.tglAutodebet = "",
    this.jumlahAutodebet = "",
    this.pajak = "",
    this.ao = "",
  }) : super();

  @override
  factory NasabahSirenaModel.fromJson(Map<String, dynamic> json) {
    return NasabahSirenaModel(
      nasabahSirenaId: json['nasabah_sirena_id'] ?? (json['produk_id'] ?? ""),
      nasabahId: json['nasabah_id'] ?? "",
      statusAnggota: json['status_anggota'] ?? "",
      noMaster: json['no_master'] ?? "",
      noMasterLama: json['no_master_lama'] ?? "",
      noRek: json['no_rek'] ?? "",
      setoranAwal: json['setoran_awal'] ?? "",
      setoranPerBulan: json['setoran_per_bulan'] ?? "",
      jumlahDiterima: json['jumlah_diterima'] ?? "",
      jangkaWaktu: json['jangka_waktu'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      sukuBunga: json['suku_bunga'] ?? "",
      tglTutup: json['tgl_tutup'] ?? "",
      alasanTutup: json['alasan_tutup'] ?? "",
      status: json['status'] ?? "",
      remark: json['remark'] ?? "",
      wilayahCd: json['wilayah_cd'] ?? "",
      groupCd: json['group_cd'] ?? "",
      denda: json['denda'] ?? "",
      adm: json['adm'] ?? "",
      mat: json['mat'] ?? "",
      potongan: json['potongan'] ?? "",
      caraBayar: json['cara_bayar'] ?? "",
      norekTransfer: json['norek_transfer'] ?? "",
      createWho: json['create_who'] ?? "",
      createDate: json['create_date'] ?? "",
      changeWho: json['change_who'] ?? "",
      changeDate: json['change_date'] ?? "",
      noRekPlain: json['no_rek_plain'] ?? "",
      sumberDana: json['sumber_dana'] ?? "",
      pejabat: json['pejabat'] ?? "",
      isAutodebet: json['is_autodebet'] ?? "",
      tglAutodebet: json['tgl_autodebet'] ?? "",
      jumlahAutodebet: json['jumlah_autodebet'] ?? "",
      pajak: json['pajak'] ?? "",
      ao: json['ao'] ?? "",
    );
  }

  @override
  String getPrimaryKeyValue() {
    return nasabahSirenaId;
  }

  @override
  Map<String, String>? prepareRow() {
    return {
      "nasabah_sirena_id": nasabahSirenaId,
      "nasabah_id": nasabahId,
      "status_anggota": statusAnggota,
      "no_master": noMaster,
      "no_master_lama": noMasterLama,
      "no_rek": noRek,
      "setoran_awal": setoranAwal,
      "setoran_per_bulan": setoranPerBulan,
      "jumlah_diterima": jumlahDiterima,
      "jangka_waktu": jangkaWaktu,
      "start_date": startDate,
      "end_date": endDate,
      "suku_bunga": sukuBunga,
      "tgl_tutup": tglTutup,
      "alasan_tutup": alasanTutup,
      "status": status,
      "remark": remark,
      "wilayah_cd": wilayahCd,
      "group_cd": groupCd,
      "denda": denda,
      "adm": adm,
      "mat": mat,
      "potongan": potongan,
      "cara_bayar": caraBayar,
      "norek_transfer": norekTransfer,
      "create_who": createWho,
      "create_date": createDate,
      "change_who": changeWho,
      "change_date": changeDate,
      "no_rek_plain": noRekPlain,
      "sumber_dana": sumberDana,
      "pejabat": pejabat,
      "is_autodebet": isAutodebet,
      "tgl_autodebet": tglAutodebet,
      "jumlah_autodebet": jumlahAutodebet,
      "pajak": pajak,
      "ao": ao,
    };
  }

  @override
  Future<dynamic>? searchByName(String keyword, String? rekCd) async {
    return BaseHelperProduk().searchByNameNasabah(keyword, rekCd, dbTable, dbPk);
  }

  @override
  Future<dynamic>? searchByNorek(String norek, String? rekCd) async {
    return BaseHelperProduk().searchByNorekNasabahBerencana(norek, rekCd, dbTable, dbPk);
  }

  @override
  Future<Map<String, int>?> upsertMigration() async {
    return BaseHelperProduk().upsertMigration(prepareRow, getPrimaryKeyValue, dbTable, dbPk);
  }
}
