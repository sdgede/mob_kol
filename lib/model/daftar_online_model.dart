class ListChoiceModel {
  String? title, value, value2, desc, desc2, image, typeInput, navigator;
  String? remark, remark2;
  bool? isInput, isChoicePage, isCheckBox, isImage;
  int? focusCamera;

  ListChoiceModel({
    this.title,
    this.value,
    this.value2,
    this.desc,
    this.desc2,
    this.image,
    this.isInput,
    this.isCheckBox,
    this.isChoicePage,
    this.isImage,
    this.focusCamera,
    this.typeInput,
    this.navigator,
    this.remark,
    this.remark2,
  });

  factory ListChoiceModel.fromJson(Map<String, dynamic> json) {
    return ListChoiceModel(
      title: json["title"] ?? "",
      value: json["value"] ?? "",
      value2: json["value2"] ?? "",
      desc: json["desc"] ?? json["description"] ?? "",
      desc2: json["desc2"] ?? "",
      image: json["image"] ?? "",
      isInput: json["isInput"] ?? false,
      isCheckBox: json["isCheckBox"] ?? false,
      isChoicePage: json["isChoicePage"] ?? false,
      isImage: json["isImage"] ?? false,
      focusCamera: json["focusCamera"] ?? 0,
      typeInput: json["typeInput"] ?? "TEXT",
      navigator: json["navigator"] ?? "",
      remark: json["remark"] ?? "",
      remark2: json["remark2"] ?? "",
    );
  }
}

class OTPCollectionModel {
  String? value;

  OTPCollectionModel({
    this.value,
  });

  factory OTPCollectionModel.fromJson(Map<String, dynamic> json) {
    return OTPCollectionModel(
      value: json["value"] ?? "",
    );
  }
}

class HistoryEformModel {
  String? tipe, produkCd, nomorMohon, rekSumber, nominal, trxDate, keterangan;
  String? statusProduk, statusProdukStr, jw, jaminan, dataLain, status, pesan;
  String? scoreUsia, scorePendidikan, scoreUsaha, scoreIstri, scoreSendiri;
  String? scoreBersih, scoreJaminan, scorePekerjaan, scoreTmptTinggal, sukuBunga;

  HistoryEformModel({
    this.tipe,
    this.produkCd,
    this.nomorMohon,
    this.rekSumber,
    this.nominal,
    this.trxDate,
    this.keterangan,
    this.statusProduk,
    this.statusProdukStr,
    this.jw,
    this.sukuBunga,
    this.jaminan,
    this.dataLain,
    this.scoreUsia,
    this.scorePendidikan,
    this.scoreUsaha,
    this.scoreIstri,
    this.scoreSendiri,
    this.scoreBersih,
    this.scoreJaminan,
    this.scorePekerjaan,
    this.scoreTmptTinggal,
    this.status,
    this.pesan,
  });

  factory HistoryEformModel.fromJson(Map<String, dynamic> json) {
    return HistoryEformModel(
      tipe: json['tipe'] ?? "",
      produkCd: json['produk_cd'] ?? "",
      nomorMohon: json['no_mohon'] ?? "",
      rekSumber: json['rek_sumber'] ?? "",
      nominal: json['jumlah'] ?? "",
      trxDate: json['trx_date'] ?? "",
      keterangan: json['ket'] ?? "",
      statusProduk: json['status'] ?? "",
      statusProdukStr: json['status_str'] ?? "",
      jw: json['jw'] ?? "",
      sukuBunga: json['sb'] ?? "",
      jaminan: json['jaminan'] ?? "",
      dataLain: json['data_lain'] ?? "",
      scoreUsia: json['score_usia'] ?? "",
      scorePendidikan: json['score_pendidikan'] ?? "",
      scoreUsaha: json['score_usaha'] ?? "",
      scoreIstri: json['score_istri'] ?? "",
      scoreSendiri: json['score_sendiri'] ?? "",
      scoreBersih: json['score_bersih'] ?? "",
      scoreJaminan: json['score_jaminan'] ?? "",
      scorePekerjaan: json['score_pekerjaan'] ?? "",
      scoreTmptTinggal: json['score_tmpt_tinggal'] ?? "",
      status: json['status'] ?? "",
      pesan: json['pesan'] ?? "",
    );
  }
}

class SimulasiModel {
  String? bulanKe, setoran, bunga, jumlah, saldo, status, pesan;

  SimulasiModel({
    this.bulanKe,
    this.setoran,
    this.bunga,
    this.jumlah,
    this.saldo,
    this.status,
    this.pesan,
  });

  factory SimulasiModel.fromJson(Map<String, dynamic> json) {
    return SimulasiModel(
      bulanKe: json["BulanKe"] ?? "",
      setoran: double.parse(json["Pokok"] ?? json["Setoran"] ?? "0").toStringAsFixed(0),
      bunga: double.parse(json["Bunga"] ?? "0").toStringAsFixed(0),
      jumlah: double.parse(json["Jumlah"] ?? "0").toStringAsFixed(0),
      saldo: double.parse(json["Bakidebet"] ?? json["Saldo"] ?? "0").toStringAsFixed(0),
      status: json["status"] ?? "",
      pesan: json["pesan"] ?? "",
    );
  }
}
