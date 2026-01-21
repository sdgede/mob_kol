// ignore_for_file: non_constant_identifier_names

import 'package:sevanam_mobkol/model/model-produk/_base_helper_produk.dart';
import 'package:sevanam_mobkol/model/model-produk/nasabah_anggota_model.dart';
import 'package:sevanam_mobkol/model/model-produk/nasabah_sirena_model.dart';
import 'package:sevanam_mobkol/model/model-produk/nasabah_tab_model.dart';

class ProdukCollection {
  String? nama, icon, slug, rekCd, min_setoran, min_tarikan, rek_shortcut;
  bool? isSelected;
  dynamic urut_menu;

  ProdukCollection({
    this.nama,
    this.icon,
    this.slug,
    this.rekCd,
    this.min_setoran,
    this.min_tarikan,
    this.rek_shortcut,
    this.urut_menu,
    this.isSelected,
  });

  factory ProdukCollection.fromJson(Map<String, dynamic> json) {
    return ProdukCollection(
      nama: json["nama"] ?? "",
      icon: json["icon"] ?? "",
      slug: json["slug"] ?? "",
      rekCd: json["rek_cd"] ?? "",
      min_setoran: json["min_setoran"] ?? "",
      min_tarikan: json["min_tarikan"] ?? "",
      rek_shortcut: json["rek_shortcut"] ?? "",
      urut_menu: json["urut_menu"] ?? "",
      isSelected: json["isSelected"] ?? false,
    );
  }
}

class ListProdukCollection {
  String? no_rek, nama, va, remark, saldo, nama_produk, jenis_produk, produk_id;
  String? status, pesan;
  bool? is_eform;

  ListProdukCollection({
    this.no_rek,
    this.nama,
    this.va,
    this.remark,
    this.saldo,
    this.is_eform,
    this.nama_produk,
    this.jenis_produk,
    this.produk_id,
    this.status,
    this.pesan,
  });

  factory ListProdukCollection.fromJson(Map<String, dynamic> json) {
    return ListProdukCollection(
      no_rek: json["no_rek"] ?? "",
      nama: json["nama"] ?? "",
      va: json["va"] ?? "",
      remark: json["remark"] ?? "",
      saldo: json["SALDO"] ?? "0",
      is_eform: json["isEform"] ?? false,
      nama_produk: json["nama_produk"] ?? "",
      jenis_produk: json["jenis_produk"] ?? "",
      produk_id: json["produk_id"] ?? "",
      status: json["status"] ?? "",
      pesan: json["pesan"] ?? "",
    );
  }
}

class DetailProdukCollection {
  dynamic nominal_tunggakan, kali_nunggak, baki_debet, pokok_bln_ini, tg_pokok;
  dynamic nasabah_id, tab_id, wilayah, last_trans_date, setoran_awal;
  dynamic no_rek, nama, va, ket, saldo, produk_id, alamat, tgl_daftar;
  dynamic tgl_jatem, sb, jangka_waktu, bunga_bulan, bunga_sgh, cara_byr_bunga;
  dynamic setoran_per_bulan, jumlah_diterima, sistem_bunga, saldoblokir;
  dynamic jenis_pinjaman, metode_angsuran, kolek, no_rek_transfer, nama_bunga;
  dynamic alamat_bunga, plafon, tunggakan_pokok, tunggakan_bunga, denda, pokok;
  dynamic bunga, total_bayar, nama_waris, alamat_waris, hubungan, late_charge;
  dynamic status, pesan, status_produk, nama_produk, jenis_produk, bnga_bln_ini;
  dynamic angsuranBulanan, angsuranBulan, kolektibilitas, tgl_bayar;
  dynamic jenis_siber, min_setoran;
  dynamic kodeVa, hp, jenisVa, tunggakan, tagihan, remark, vaVendor;
  String? remarkBlokir;

  DetailProdukCollection({
    this.nasabah_id,
    this.tab_id,
    this.wilayah,
    this.last_trans_date,
    this.setoran_awal,
    this.nominal_tunggakan,
    this.kali_nunggak,
    this.baki_debet,
    this.pokok_bln_ini,
    this.tg_pokok,
    this.no_rek,
    this.nama,
    this.va,
    this.ket,
    this.saldo,
    this.saldoblokir,
    this.remarkBlokir,
    this.produk_id,
    this.alamat,
    this.tgl_daftar,
    this.status_produk,
    this.tgl_jatem,
    this.sb,
    this.jangka_waktu,
    this.bunga_bulan,
    this.bunga_sgh,
    this.cara_byr_bunga,
    this.setoran_per_bulan,
    this.jumlah_diterima,
    this.sistem_bunga,
    this.jenis_pinjaman,
    this.metode_angsuran,
    this.kolek,
    this.no_rek_transfer,
    this.nama_bunga,
    this.alamat_bunga,
    this.plafon,
    this.tunggakan_pokok,
    this.tunggakan_bunga,
    this.bnga_bln_ini,
    this.denda,
    this.pokok,
    this.bunga,
    this.total_bayar,
    this.late_charge,
    this.nama_waris,
    this.alamat_waris,
    this.hubungan,
    this.status,
    this.pesan,
    this.nama_produk,
    this.jenis_produk,
    this.angsuranBulanan,
    this.angsuranBulan,
    this.kolektibilitas,
    this.tgl_bayar,
    this.jenis_siber,
    this.min_setoran,
    this.kodeVa,
    this.hp,
    this.jenisVa,
    this.tunggakan,
    this.tagihan,
    this.remark,
    this.vaVendor,
  });

  factory DetailProdukCollection.fromJson(Map<String, dynamic> json) {
    return DetailProdukCollection(
      nasabah_id: json["nas_id"] ?? "",
      tab_id: json["tab_id"] ?? "",
      wilayah: json["wilayah"] ?? "",
      last_trans_date: json["trx_date"] ?? "",
      setoran_awal: json["setoranAwal"] ?? "",
      nominal_tunggakan: json["tunggakan"] ?? "",
      kali_nunggak: json["kali_nunggak"] ?? "",
      baki_debet: json["BakiDebet"] ?? "",
      pokok_bln_ini: json["pokok"] ?? "",
      tg_pokok: json["tunggakanPokok"] ?? "",
      no_rek: json["norek"] ?? "",
      nama: json["nama"] ?? "",
      va: json["va"] ?? "",
      ket: json["ket"] ?? "",
      saldo: json["saldo"] ?? "0",
      saldoblokir: json["val_blokir"] ?? "0",
      remarkBlokir: json["remarkBlokir"] ?? "0",
      produk_id: json["produk_id"] ?? "",
      alamat: json["alamat"] ?? "",
      tgl_daftar: json["tglReal"] ?? "",
      status_produk: json["status"] ?? "",
      tgl_jatem: json["tglJatem"] ?? "",
      sb: json["sb"] ?? "",
      jangka_waktu: json["jw"] ?? "",
      bunga_bulan: json["bunga_bulan"] ?? "",
      bunga_sgh: json["bunga_sgh"] ?? "",
      cara_byr_bunga: json["cara_byr_bunga"] ?? "",
      setoran_per_bulan: json["setoranPerBulan"] ?? "",
      jumlah_diterima: json["jmlDiterima"] ?? "",
      sistem_bunga: json["sistemBunga"] ?? "",
      jenis_pinjaman: json["jenis_pinjaman"] ?? "",
      metode_angsuran: json["metodeAngsuran"] ?? "",
      kolek: json["kolek"] ?? "",
      no_rek_transfer: json["no_rek_transfer"] ?? "",
      nama_bunga: json["nama_bunga"] ?? "",
      alamat_bunga: json["alamat_bunga"] ?? "",
      plafon: json["plafon"] ?? "",
      tunggakan_pokok: json["tunggakan_pokok"] ?? "",
      tunggakan_bunga: json["tunggakanBunga"] ?? "",
      bnga_bln_ini: json["bungaBlnIni"] ?? "",
      denda: json["getDenda"] ?? "",
      pokok: json["pokok"] ?? "",
      bunga: json["bunga"] ?? "",
      total_bayar: json["totalBayar"] ?? "",
      late_charge: json["late_charge"] ?? "",
      nama_waris: json["nama_waris"] ?? "",
      alamat_waris: json["alamat_waris"] ?? "",
      hubungan: json["hubungan"] ?? "",
      status: json["status"] ?? "",
      pesan: json["pesan"] ?? "",
      nama_produk: json["nama_produk"] ?? "",
      jenis_produk: json["jenis_produk"] ?? "",
      angsuranBulanan: json["angsuran"] ?? "",
      angsuranBulan: json["bulan_angsuran"] ?? "",
      kolektibilitas: json["kolektibilitas"] ?? "",
      tgl_bayar: json["tglBayar"] ?? "",
      jenis_siber: json["jenis_siber"] ?? "",
      min_setoran: json["min_setoran"] ?? "",
      kodeVa: json["kode_va"] ?? "",
      hp: json["hp"] ?? "",
      jenisVa: json["jenis_va"] ?? "",
      tunggakan: json["tunggakan"] ?? "",
      tagihan: json["tagihan"] ?? "",
      remark: json["remark"] ?? "",
      vaVendor: json["va_vendor"] ?? "",
    );
  }
}

class MutasiProdukCollection {
  String? referensi_id, trans_cd, jumlah, remark, saldo, tgl, create_who, dbcr;
  String? nama, bukti, kode, op, saldo_awal, status, pesan, norek;
  String? pokok, bunga, denda, hp, terbilang, isUpload, groupProduk, rekCd, adm;
  String? totSetoran, totTarikan, totPokok, totBunga, totDenda, debet, kredit;
  String? kodeVa;
  dynamic trans_id;

  MutasiProdukCollection({
    this.referensi_id,
    this.trans_cd,
    this.jumlah,
    this.debet,
    this.kredit,
    this.pokok,
    this.bunga,
    this.denda,
    this.adm,
    this.remark,
    this.saldo,
    this.saldo_awal,
    this.tgl,
    this.create_who,
    this.trans_id,
    this.dbcr,
    this.status,
    this.pesan,
    this.nama,
    this.hp,
    this.bukti,
    this.kode,
    this.terbilang,
    this.op,
    this.norek,
    this.groupProduk,
    this.rekCd,
    this.isUpload,
    this.totSetoran,
    this.totTarikan,
    this.totPokok,
    this.totBunga,
    this.totDenda,
    this.kodeVa,
  });

  factory MutasiProdukCollection.fromJson(Map<String, dynamic> json) {
    return MutasiProdukCollection(
      nama: json["nama"] ?? "",
      hp: json["no_hp"] ?? "",
      bukti: json["bukti"] ?? "",
      kode: json["kode"] ?? "",
      referensi_id: json["referensi_id"] ?? "",
      trans_cd: json["trans_cd"] ?? "",
      jumlah: json["jumlah"] ?? "0",
      debet: json["debet"] ?? "0",
      kredit: json["kredit"] ?? "0",
      pokok: json["pokok"] ?? "0",
      bunga: json["bunga"] ?? "0",
      denda: json["denda"] ?? "0",
      adm: json["adm"] ?? "0",
      remark: json["remark"] ?? "",
      terbilang: json["terbilang"] ?? "",
      saldo: json["saldo"] ?? "0",
      saldo_awal: json["saldo_awal"] ?? "0",
      tgl: json["tgl"] ?? "",
      create_who: json["create_who"] ?? "",
      dbcr: json["dbcr"] ?? "",
      trans_id: json["trans_id"] ?? "",
      status: json["res_status"] ?? "",
      pesan: json["pesan"] ?? "",
      op: json["op"] ?? "",
      norek: json["norek"] ?? "",
      groupProduk: json["groupProduk"] ?? "",
      rekCd: json["rekCd"] ?? "",
      isUpload: json["isUpload"] ?? "",
      totSetoran: json["totSetor"] ?? "0",
      totTarikan: json["totTarik"] ?? "0",
      totPokok: json["totPokok"] ?? "0",
      totBunga: json["totBunga"] ?? "0",
      totDenda: json["totDenda"] ?? "0",
      kodeVa: json["kode_va"] ?? "0",
      //totSetoran: if ( ?? "0",
    );
  }
}

class MutasiProdukCollectionSearch {
  String? referensi_id, trans_cd, jumlah, remark, saldo, tgl, create_who, dbcr;
  String? nama, bukti, kode, op, saldo_awal, status, pesan, norek;
  String? pokok, bunga, denda, hp, terbilang, isUpload, groupProduk, rekCd, adm;
  String? totSetoran, totTarikan;
  dynamic trans_id;

  MutasiProdukCollectionSearch({
    this.referensi_id,
    this.trans_cd,
    this.jumlah,
    this.pokok,
    this.bunga,
    this.denda,
    this.adm,
    this.remark,
    this.saldo,
    this.saldo_awal,
    this.tgl,
    this.create_who,
    this.trans_id,
    this.dbcr,
    this.status,
    this.pesan,
    this.nama,
    this.hp,
    this.bukti,
    this.kode,
    this.terbilang,
    this.op,
    this.norek,
    this.groupProduk,
    this.rekCd,
    this.isUpload,
    this.totSetoran,
    this.totTarikan,
  });

  factory MutasiProdukCollectionSearch.fromJson(Map<String, dynamic> json) {
    return MutasiProdukCollectionSearch(
      nama: json["nama"] ?? "",
      hp: json["no_hp"] ?? "",
      bukti: json["bukti"] ?? "",
      kode: json["kode"] ?? "",
      referensi_id: json["referensi_id"] ?? "",
      trans_cd: json["trans_cd"] ?? "",
      jumlah: json["jumlah"] ?? "0",
      pokok: json["pokok"] ?? "0",
      bunga: json["bunga"] ?? "0",
      denda: json["denda"] ?? "0",
      adm: json["adm"] ?? "0",
      remark: json["remark"] ?? "",
      terbilang: json["terbilang"] ?? "",
      saldo: json["saldo"] ?? "0",
      saldo_awal: json["saldo_awal"] ?? "0",
      tgl: json["tgl"] ?? "",
      create_who: json["create_who"] ?? "",
      dbcr: json["dbcr"] ?? "",
      trans_id: json["trans_id"] ?? "",
      status: json["res_status"] ?? "",
      pesan: json["pesan"] ?? "",
      op: json["op"] ?? "",
      norek: json["norek"] ?? "",
      groupProduk: json["groupProduk"] ?? "",
      rekCd: json["rekCd"] ?? "",
      isUpload: json["isUpload"] ?? "",
      totSetoran: json["totSetor"] ?? "0",
      totTarikan: json["totTarik"] ?? "0",
      //totSetoran: if ( ?? "0",
    );
  }
}

class SaldoKolektorModel {
  //main produk variabel
  dynamic debet_tab, kredit_tab, saldo_tab, kredit_agt, debet_agt, saldo_agt;
  dynamic kredit_jangka, kredit_kredit, debet_kredit, saldo_kredit, kas_awal;
  dynamic kas_keluar2, kas_keluar1, status, tot_debet, tot_kredit;
  dynamic tot_saldo, kas_sisa;
  //custom produk variabel
  String? debet_duo, kredit_duo, saldo_duo;
  String? debet_lestari, kredit_lestari, saldo_lestari;
  String? debet_simas, kredit_simas, saldo_simas;
  String? debet_sirena, kredit_sirena, saldo_sirena;
  String? debet_taberna, kredit_taberna, saldo_taberna;

  SaldoKolektorModel({
    //main produk variabel
    this.debet_tab,
    this.kredit_tab,
    this.saldo_tab,
    this.kredit_agt,
    this.debet_agt,
    this.saldo_agt,
    this.kredit_jangka,
    this.kredit_kredit,
    this.debet_kredit,
    this.saldo_kredit,
    this.kas_awal,
    this.kas_keluar2,
    this.kas_keluar1,
    this.status,
    this.tot_debet,
    this.tot_kredit,
    this.tot_saldo,
    this.kas_sisa,
    //custom variable
    this.debet_duo,
    this.kredit_duo,
    this.saldo_duo,
    this.debet_lestari,
    this.kredit_lestari,
    this.saldo_lestari,
    this.debet_simas,
    this.kredit_simas,
    this.saldo_simas,
    this.debet_sirena,
    this.kredit_sirena,
    this.saldo_sirena,
    this.debet_taberna,
    this.kredit_taberna,
    this.saldo_taberna,
  });

  factory SaldoKolektorModel.fromJson(Map<String, dynamic> json) {
    return SaldoKolektorModel(
      //main produk variabel
      debet_tab: json["debet_tab"]?.toString() ?? "0",
      kredit_tab: json["kredit_tab"]?.toString() ?? "0",
      saldo_tab: json["saldo_tab"]?.toString() ?? "0",
      kredit_agt: json["kredit_anggota"]?.toString() ?? "0",
      debet_agt: json["debet_anggota"]?.toString() ?? "0",
      saldo_agt: json["saldo_anggota"]?.toString() ?? "0",
      kredit_jangka: json["kredit_jangka"] ?? "0",
      kredit_kredit: json["kredit_kredit"]?.toString() ?? "0",
      debet_kredit: json["debet_kredit"]?.toString() ?? "0",
      saldo_kredit: json["saldo_kredit"]?.toString() ?? "0",
      kas_awal: json["kas_awal"]?.toString() ?? "0",
      kas_keluar2: json["kas_keluar2"]?.toString() ?? "0",
      kas_keluar1: json["kas_keluar1"]?.toString() ?? "0",
      status: json["res_status"]?.toString() ?? "0",
      tot_debet: json["tot_debet"]?.toString() ?? "0",
      tot_kredit: json["tot_kredit"]?.toString() ?? "0",
      tot_saldo: json["tot_saldo"]?.toString() ?? "0",
      kas_sisa: json["kas_sisa"]?.toString() ?? "0",
      //other produk variable
      debet_duo: json["debet_duo"]?.toString() ?? "0",
      kredit_duo: json["kredit_duo"]?.toString() ?? "0",
      saldo_duo: json["saldo_duo"]?.toString() ?? "0",
      debet_lestari: json["debet_lestari"]?.toString() ?? "0",
      kredit_lestari: json["kredit_lestari"]?.toString() ?? "0",
      saldo_lestari: json["saldo_lestari"]?.toString() ?? "0",
      debet_simas: json["debet_simas"]?.toString() ?? "0",
      kredit_simas: json["kredit_simas"]?.toString() ?? "0",
      saldo_simas: json["saldo_simas"]?.toString() ?? "0",
      debet_sirena: json["debet_sirena"]?.toString() ?? "0",
      kredit_sirena: json["kredit_sirena"]?.toString() ?? "0",
      saldo_sirena: json["saldo_sirena"]?.toString() ?? "0",
      debet_taberna: json["debet_taberna"]?.toString() ?? "0",
      kredit_taberna: json["kredit_taberna"]?.toString() ?? "0",
      saldo_taberna: json["saldo_taberna"]?.toString() ?? "0",
    );
  }
}

class NasabahProdukModel {
  String? nama, foto, norek, alamat, status, pesan;
  String? jenisProduk, icon, groupProduk, rekCd, minSetoran;

  NasabahProdukModel({
    this.nama,
    this.foto,
    this.norek,
    this.jenisProduk,
    this.groupProduk,
    this.rekCd,
    this.minSetoran,
    this.icon,
    this.alamat,
    this.status,
    this.pesan,
  });

  factory NasabahProdukModel.fromJson(Map<String, dynamic> json) {
    return NasabahProdukModel(
      nama: json["nama"] ?? "",
      foto: json["foto"] ?? "",
      norek: json["norek"] ?? "",
      jenisProduk: json["jenis_produk"] ?? "",
      groupProduk: json["group_cd"] ?? "",
      rekCd: json["rek_cd"] ?? "",
      minSetoran: json["min_setoran"] ?? "",
      icon: json["icon"] ?? "",
      alamat: json["alamat"] ?? "",
      status: json["res_status"] ?? "",
      pesan: json["pesan"] ?? "",
    );
  }
}

class ProdukTabunganUserModel {
  String? no_rek, nama, saldo, produk_id;

  ProdukTabunganUserModel({this.no_rek, this.nama, this.saldo, this.produk_id});

  factory ProdukTabunganUserModel.fromJson(Map<String, dynamic> json) {
    return ProdukTabunganUserModel(
      no_rek: json["no_rek"] ?? "",
      nama: json["nama"] ?? "",
      saldo: json["SALDO"] ?? "0",
      produk_id: json["produk_id"] ?? "",
    );
  }
}

class DataMigrasiCollection {
  String? produkId, nasabahId, noMaster, wilayahCd, groupProduk, norek, setoranAwal;
  String? status, tglDaftar, tglTutup, alasanTutup, potongan, remark, createWho;
  String? createDate, changeWho, changeDate;

  DataMigrasiCollection({
    this.produkId,
    this.nasabahId,
    this.noMaster,
    this.wilayahCd,
    this.groupProduk,
    this.norek,
    this.setoranAwal,
    this.status,
    this.tglDaftar,
    this.tglTutup,
    this.alasanTutup,
    this.potongan,
    this.remark,
    this.createWho,
    this.createDate,
    this.changeWho,
    this.changeDate,
  });

  factory DataMigrasiCollection.fromJson(Map<String, dynamic> json) {
    return DataMigrasiCollection(
      produkId: json["produk_id"] ?? "",
      nasabahId: json["nasabah_id"] ?? "",
      noMaster: json["no_master"] ?? "",
      wilayahCd: json["wilayah_cd"] ?? "",
      groupProduk: json["group_cd"] ?? "",
      norek: json["no_rek"] ?? "",
      setoranAwal: json["setoran_awal"] ?? "",
      status: json["status"] ?? "",
      tglDaftar: json["tgl_daftar"] ?? "",
      tglTutup: json["tgl_tutup"] ?? "",
      alasanTutup: json["alasan_tutup"] ?? "",
      potongan: json["potongan"] ?? "",
      remark: json["remark"] ?? "",
      createWho: json["create_who"] ?? "",
      createDate: json["create_date"] ?? "",
      changeWho: json["change_who"] ?? "",
      changeDate: json["change_date"] ?? "",
    );
  }
}

class SaldoKolektor {
  String? title;
  dynamic data;

  SaldoKolektor({this.title, this.data});

  factory SaldoKolektor.fromJson(Map<String, dynamic> json) {
    return SaldoKolektor(
      title: json["title"] ?? "",
      data: json["data"] ?? [],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class ProdukModel {
  List<String> products = [
    'TABUNGAN',
    'ANGGOTA',
    'BERENCANA',
  ];
  String? stringClass;

  ProdukModel({this.stringClass});

  String getNorekField(String groupMenu, String? mode) {
    mode = mode ?? "group_menu";

    dynamic productModel = getProductModel(mode: mode, productClass: groupMenu);
    if (productModel != null) return productModel.dbNorekField as String;

    return "no_rek";
  }

  String getQueryNama(
    String groupMenu, {
    required String dbTable,
    required String dbNasId,
    String? mode,
  }) {
    mode = mode ?? "group_menu";

    String query = "(SELECT ${BaseHelperProduk().getQuerySelectNamaNasabah('x', 'nama')} FROM m_nasabah x WHERE x.nasabah_id = $dbTable.$dbNasId)";

    var productClass = getProductModel();
    if (productClass == null) return "";

    return query;
  }

  dynamic getProductModel({dynamic json, String? mode, String? productClass}) {
    mode = mode ?? "group_menu";
    productClass = productClass ?? stringClass;

    if ((mode == "group_menu" && productClass == "BERENCANA") || (mode == "rek_cd" && productClass == "SIRENA")) {
      if (mode == "rek_cd" && productClass == "SIRENA") {
        return json == null ? NasabahSirenaModel() : NasabahSirenaModel.fromJson(json);
      }

      return json == null ? NasabahSirenaModel() : NasabahSirenaModel.fromJson(json);
    } else if ((mode == "group_menu" && productClass == "ANGGOTA") || (mode == "rek_cd" && productClass == "SIMP_ANGGOTA")) {
      return json == null ? NasabahAnggotaModel() : NasabahAnggotaModel.fromJson(json);
    } else if ((mode == "group_menu" && productClass == "TABUNGAN") || (mode == "rek_cd" && productClass == "TABRELA")) {
      return json == null ? NasabahTabModel() : NasabahTabModel.fromJson(json);
    } else {
      return null;
    }
  }
}

abstract class BaseProdukModelInterface {
  BaseProdukModelInterface();
  BaseProdukModelInterface.fromJson(Map<String, dynamic> json);

  Map<String, String>? prepareRow() {
    return null;
  }

  String getPrimaryKeyValue() {
    return "";
  }

  Future<dynamic>? searchByName(String keyword, String? rekCd) {
    return null;
  }

  Future<dynamic>? searchByNorek(String norek, String? rekCd) {
    return null;
  }

  Future<Map<String, int>?> upsertMigration() async {
    return null;
  }
}
