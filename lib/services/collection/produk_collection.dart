import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevanam_mobkol/model/model_datatable.dart';

import '../../database/databaseHelper.dart';
import '../../services/viewmodel/global_provider.dart';
import '../../model/produk_model.dart';
import '../base/base_services.dart';
import '../config/config.dart' as config;
import '../utils/mcrypt_utils.dart';

class ProdukCollectionServices extends BaseServices {
  GlobalProvider? _globalProv;
  final dbHelper = DatabaseHelper.instance;

  Future<List<ProdukCollection>?> dataProduk({BuildContext? context, bool migrasi = false}) async {
    _globalProv = Provider.of<GlobalProvider>(context!, listen: false);
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "getIconProdukApp";
    dataProduk["context"] = migrasi ? McryptUtils.instance.encrypt("migrasi") : "";
    dataProduk["id_user"] = McryptUtils.instance.encrypt(config.dataLogin['ID_USER'] ?? "");
    var resp;

    if (_globalProv!.getConnectionMode == config.onlineMode)
      resp = await request(
        context: context,
        url: config.ConfigURL().urlApiLogin,
        type: RequestType.POST,
        data: dataProduk,
      );
    else
      resp = await dbHelper.getIconProdukOffline(dataParse: dataProduk, isMigration: true);

    List<ProdukCollection>? produkCollection;

    if (resp != null) {
      var jsonData = json.decode(resp);
      produkCollection = [];
      jsonData.forEach((val) {
        produkCollection!.add(ProdukCollection.fromJson(val));
      });
    }
    return produkCollection;
  }

  Future<List<MutasiProdukCollection>> getDataMutasi({
    BuildContext? context,
    String? idProduk,
    String? rekCd,
    String? groupProduk,
    String? norek,
  }) async {
    var dataProduk = Map<String, dynamic>();
    var urlWs = config.ConfigURL().urlApiNasabahProduk;
    if (groupProduk == 'TABUNGAN') {
      dataProduk["req"] = "getMutasiTabungan";
      urlWs = config.ConfigURL().urlApiNasabahProduk;
    } else if (groupProduk == 'ANGGOTA') {
      dataProduk["req"] = "getMutasiAnggota";
      urlWs = config.ConfigURL().urlApiNasabahProduk;
    } else if (groupProduk == 'BERENCANA') {
      dataProduk["req"] = "getMutasiBerencana";
      urlWs = config.ConfigURL().urlApiNasabahDeposito;
    } else if (groupProduk == 'KREDIT') {
      dataProduk["req"] = "getMutasiKredit";
      urlWs = config.ConfigURL().urlApiNasabahKredit;
    }

    dataProduk["id_produk"] = McryptUtils.instance.encrypt(idProduk!);
    dataProduk["rekCd"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["groupProduk"] = McryptUtils.instance.encrypt(groupProduk!);
    dataProduk["norek"] = McryptUtils.instance.encrypt(norek ?? '0');

    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd);
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd);
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");

    var resp = await request(
      context: context,
      url: urlWs,
      type: RequestType.POST,
      data: dataProduk,
    );
    List<MutasiProdukCollection> listProdukCollection = [];
    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        listProdukCollection.add(MutasiProdukCollection.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<ModelDatatable> getDataMutasiV2(
    BuildContext context, {
    required int page,
    int limit = 20,
    String? idProduk,
    String? rekCd,
    String? groupProduk,
    String? norek,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, String> productReq = {
        "TABUNGAN": "getMutasiTabungan",
        "ANGGOTA": "getMutasiAnggota",
        "BERENCANA": "getMutasiBerencana",
        "KREDIT": "getMutasiKredit",
      };

      Map<String, dynamic> reqData = {
        "req": productReq[groupProduk],
        "id_produk": McryptUtils.instance.encrypt(idProduk!),
        "rekCd": McryptUtils.instance.encrypt(rekCd!),
        "groupProduk": McryptUtils.instance.encrypt(groupProduk!),
        "norek": McryptUtils.instance.encrypt(norek ?? '0'),
        "user": McryptUtils.instance.encrypt(config.dataLogin['username']),
        "pwd": config.dataLogin['password'],
        "imei": McryptUtils.instance.encrypt(config.dataLogin['imei']),
        "activity": McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd),
        "remark": McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd),
        "lat": McryptUtils.instance.encrypt("0"),
        "longi": McryptUtils.instance.encrypt("0"),
        "page": McryptUtils.instance.encrypt("$page"),
        "limit": McryptUtils.instance.encrypt("$limit"),
      };

      if (startDate != null) {
        reqData["start_date"] = McryptUtils.instance.encrypt(DateFormat("yyyy-MM-dd").format(startDate).toString());
      }

      if (endDate != null) {
        reqData["end_date"] = McryptUtils.instance.encrypt(DateFormat("yyyy-MM-dd").format(endDate).toString());
      }

      var response = await request(
        context: context,
        url: config.ConfigURL().urlProductCollector,
        type: RequestType.POST,
        data: reqData,
      );

      if (response != null) {
        var jsonData = json.decode(response);
        return ModelDatatable.fromJson(jsonData as Map<String, dynamic>, (Map<String, dynamic> row) {
          return MutasiProdukCollection.fromJson(row);
        });
      }

      return ModelDatatable(total: 0, limit: limit, page: page, totalPage: 0, data: []);
    } catch (e) {
      debugPrint(e.toString());
      return ModelDatatable(total: 0, limit: limit, page: page, totalPage: 0, data: []);
    }
  }

  Future<List<MutasiProdukCollection>> getDataKlad({
    BuildContext? context,
    String? rekCd,
    String? groupProduk,
    String? lat,
    String? long,
    String? startDate,
    String? endDate,
  }) async {
    var dataProduk = Map<String, dynamic>();
    var urlWs = config.ConfigURL().urlApiTransaksiTabungan;
    if (groupProduk == 'TABUNGAN') {
      dataProduk["req"] = "getHistoryTransTabByDate";
      urlWs = config.ConfigURL().urlApiTransaksiTabungan;
    } else if (groupProduk == 'ANGGOTA') {
      dataProduk["req"] = "getHistoryTransAnggotaByDate";
      urlWs = config.ConfigURL().urlApiTransaksiTabungan;
    } else if (groupProduk == 'BERENCANA') {
      dataProduk["req"] = "getHistoryBerencanaByDate";
      urlWs = config.ConfigURL().urlApiTransaksiDeposito;
    } else if (groupProduk == 'KREDIT') {
      dataProduk["req"] = "getHistoryKreditByDate";
      urlWs = config.ConfigURL().urlApiTransaksiKredit;
    }

    dataProduk["rekCd"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["groupProduk"] = McryptUtils.instance.encrypt(groupProduk!);

    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd);
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd);
    dataProduk["tglAwal"] = McryptUtils.instance.encrypt(startDate!);
    dataProduk["tglAkhir"] = McryptUtils.instance.encrypt(endDate!);
    dataProduk["lat"] = McryptUtils.instance.encrypt(lat ?? '');
    dataProduk["longi"] = McryptUtils.instance.encrypt(long ?? '');
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);

    var resp;
    if (_globalProv!.getConnectionMode == config.offlineMode)
      resp = await dbHelper.getKladOffline(dataParse: dataProduk);
    else
      resp = await request(
        context: context,
        url: urlWs,
        type: RequestType.POST,
        data: dataProduk,
      );

    List<MutasiProdukCollection> listProdukCollection = [];

    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        listProdukCollection.add(MutasiProdukCollection.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<List<SaldoKolektorModel>> getDataSaldoKolektor({
    BuildContext? context,
    String? rekCd,
    String? groupProduk,
  }) async {
    _globalProv = Provider.of<GlobalProvider>(context!, listen: false);
    var dataProduk = Map<String, dynamic>();
    var urlWs = config.ConfigURL().urlApiNasabahProduk;
    dataProduk["req"] = "getSaldoKolektor";

    dataProduk["rekCd"] = McryptUtils.instance.encrypt(rekCd ?? '');
    dataProduk["groupProduk"] = McryptUtils.instance.encrypt(groupProduk ?? '');

    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + (rekCd ?? ''));
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + (rekCd ?? ''));
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");

    var resp;

    if (_globalProv!.getConnectionMode == config.offlineMode)
      resp = await dbHelper.getSaldoKolOffline(dataParse: dataProduk);
    else
      resp = await request(
        context: context,
        url: urlWs,
        type: RequestType.POST,
        data: dataProduk,
      );

    List<SaldoKolektorModel> listProdukCollection = [];

    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        listProdukCollection.add(SaldoKolektorModel.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<List<SaldoKolektor>> getSaldoKolektor({
    BuildContext? context,
  }) async {
    _globalProv = Provider.of<GlobalProvider>(context!, listen: false);
    var dataProduk = Map<String, dynamic>();

    var urlWs = config.ConfigURL().urlApiNasabahProduk;
    dataProduk["req"] = "getSaldoKolektor";

    var resp;

    if (_globalProv!.getConnectionMode == config.offlineMode)
      resp = await dbHelper.getSaldoKolOffline(dataParse: dataProduk);
    else {
      resp = await request(context: context, url: urlWs, type: RequestType.POST, data: dataProduk);
    }

    List<SaldoKolektor> listProdukCollection = [];

    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        listProdukCollection.add(SaldoKolektor.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<List<NasabahProdukModel>?> getDataSearchNasabah({
    BuildContext? context,
    String? keyword,
    String? rekCd,
    String? groupProduk,
    String? latitude,
    String? longitude,
  }) async {
    _globalProv = Provider.of<GlobalProvider>(context!, listen: false);
    var dataProduk = Map<String, dynamic>();
    var urlWs = config.ConfigURL().urlApiNasabahProduk;

    if (groupProduk == 'TABUNGAN' || groupProduk == 'ANGGOTA') {
      urlWs = config.ConfigURL().urlApiNasabahProduk;
      dataProduk["req"] = "getDataPencarianProdukTab";
    } else if (groupProduk == 'BERENCANA') {
      urlWs = config.ConfigURL().urlApiNasabahDeposito;
      dataProduk["req"] = "getDataPencarianTabBerencana";
    } else if (groupProduk == 'KREDIT') {
      urlWs = config.ConfigURL().urlApiNasabahKredit;
      dataProduk["req"] = "getDataPencarianKredit";
    }

    dataProduk["keyword"] = McryptUtils.instance.encrypt(keyword!);
    dataProduk["rekCd"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["groupProduk"] = McryptUtils.instance.encrypt(groupProduk!);
    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);

    var resp;
    if (_globalProv!.getConnectionMode == config.offlineMode)
      resp = await dbHelper.pencarianNasabahTabOffline(dataParse: dataProduk);
    else
      resp = await request(
        context: context,
        url: urlWs,
        type: RequestType.POST,
        data: dataProduk,
      );

    List<NasabahProdukModel>? listProdukCollection;

    if (resp != null) {
      var jsonData = json.decode(resp);
      listProdukCollection = [];
      jsonData.forEach((val) {
        listProdukCollection!.add(NasabahProdukModel.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<List<NasabahProdukModel>?> getDataPenagihanPinajaman({
    BuildContext? context,
    String? tglAwal,
    String? tglAkhir,
    String? latitude,
    String? longitude,
  }) async {
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "getDataPenagihanPinjaman";
    dataProduk["tgl_awal"] = McryptUtils.instance.encrypt(tglAwal!);
    dataProduk["tgl_akhir"] = McryptUtils.instance.encrypt(tglAkhir!);

    var resp = await request(
      context: context,
      url: config.ConfigURL().urlApiNasabahKredit,
      type: RequestType.POST,
      data: dataProduk,
    );

    List<NasabahProdukModel>? listProdukCollection;

    if (resp != null) {
      var jsonData = json.decode(resp);
      listProdukCollection = [];
      jsonData.forEach((val) {
        listProdukCollection!.add(NasabahProdukModel.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<List<ListProdukCollection>?> getDataProdukByUserId({
    BuildContext? context,
    String? idUser,
    String? rekCd,
  }) async {
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "spGetProdukByProdukIdUser";
    dataProduk["id"] = McryptUtils.instance.encrypt(idUser!);
    dataProduk["produk"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd);
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_" + rekCd);
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");

    var resp = await request(
      context: context,
      url: config.ConfigURL().urlApiNasabah,
      type: RequestType.POST,
      data: dataProduk,
    );

    List<ListProdukCollection>? listProdukCollection;

    if (resp != null) {
      var jsonData = json.decode(resp);
      listProdukCollection = [];
      jsonData.forEach((val) {
        listProdukCollection!.add(ListProdukCollection.fromJson(val));
      });
    }
    return listProdukCollection;
  }

  Future<List<DetailProdukCollection>> getDataDetailProdukByProdukId({
    BuildContext? context,
    String? produkId,
    String? rekCd,
  }) async {
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "spGetDetailProdukByProdukId";
    dataProduk["id"] = McryptUtils.instance.encrypt(produkId!);
    dataProduk["produk"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_DETAIL_PRODUK_" + rekCd);
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_DETAIL_PRODUK_" + rekCd);
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");

    var resp = await request(
      context: context,
      url: config.ConfigURL().urlApiNasabah,
      type: RequestType.POST,
      data: dataProduk,
    );

    var detailProdukCollection;

    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        detailProdukCollection.add(DetailProdukCollection.fromJson(val));
      });
    }
    return detailProdukCollection;
  }

  Future<List<DetailProdukCollection>?> getDataDetailProdukByNasabahId({
    BuildContext? context,
    String? idUser,
    String? rekCd,
  }) async {
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "getDataDetailProdukByNasabahId";
    dataProduk["id"] = McryptUtils.instance.encrypt(idUser!);
    dataProduk["produk"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_DETAIL_PRODUK_" + rekCd);
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_DETAIL_PRODUK_" + rekCd);
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");
    var resp = await request(
      context: context,
      url: config.ConfigURL().urlApiNasabah,
      type: RequestType.POST,
      data: dataProduk,
    );

    List<DetailProdukCollection>? detailProdukCollection;

    if (resp != null) {
      var jsonData = json.decode(resp);
      detailProdukCollection = [];
      jsonData.forEach((val) {
        detailProdukCollection!.add(DetailProdukCollection.fromJson(val));
      });
    }
    return detailProdukCollection;
  }

  dynamic getDataProdukByRek({
    BuildContext? context,
    String? norek,
    String? groupProduk,
    String? rekCd,
    String? lat,
    String? long,
  }) async {
    var dataProduk = Map<String, dynamic>();
    var urlWs = config.ConfigURL().urlApiNasabahProduk;
    if (groupProduk == 'TABUNGAN') {
      dataProduk["req"] = "getDataProdukTabByRek";
      urlWs = config.ConfigURL().urlApiNasabahProduk;
    } else if (groupProduk == 'ANGGOTA') {
      dataProduk["req"] = "getDataProdukAnggotaByRek";
      urlWs = config.ConfigURL().urlApiNasabahProduk;
    } else if (groupProduk == 'BERENCANA') {
      dataProduk["req"] = "getDataProdukBerencanaByRek";
      urlWs = config.ConfigURL().urlApiNasabahDeposito;
    } else if (groupProduk == 'KREDIT') {
      dataProduk["req"] = "getRincianKreditByRek";
      urlWs = config.ConfigURL().urlApiNasabahKredit;
    }

    dataProduk["norek"] = McryptUtils.instance.encrypt(norek!);
    dataProduk["rekCd"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["groupProduk"] = McryptUtils.instance.encrypt(groupProduk!);
    dataProduk["kolektor"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["lat"] = McryptUtils.instance.encrypt(lat ?? "");
    dataProduk["longi"] = McryptUtils.instance.encrypt(long ?? "");

    var resp;
    if (_globalProv!.getConnectionMode == config.offlineMode)
      resp = await dbHelper.getDataProduk(dataParse: dataProduk);
    else
      resp = await request(
        context: context,
        url: urlWs,
        type: RequestType.POST,
        data: dataProduk,
      );
    return resp;
  }

  dynamic getDataMigrasi({
    BuildContext? context,
    String? groupProduk,
    String? rekCd,
    String? tglAwal,
    String? tglAkhir,
    String? lat,
    String? long,
  }) async {
    var dataProduk = Map<String, dynamic>();
    var urlWs = config.ConfigURL().urlApiNasabahProduk;
    if (groupProduk == 'TABUNGAN') {
      dataProduk["req"] = "getDataMigrasiTab";
      urlWs = config.ConfigURL().urlApiNasabahProduk;
    } else if (groupProduk == 'ANGGOTA') {
      dataProduk["req"] = "getDataMigrasiAgt";
      urlWs = config.ConfigURL().urlApiNasabahProduk;
    } else if (groupProduk == 'BERENCANA') {
      dataProduk["req"] = "getDataMigrasiBerencana";
      urlWs = config.ConfigURL().urlApiNasabahDeposito;
    } else if (groupProduk == 'MASTER_NASABAH') {
      dataProduk["req"] = "getDataMigrasiMasterNasabah";
      urlWs = config.ConfigURL().urlApiNasabah;
    } else if (groupProduk == 'DATA_AKUN') {
      dataProduk["req"] = "getMigrasiDataAKun";
      urlWs = config.ConfigURL().urlApiLogin;
    } else if (groupProduk == 'CONFIG') {
      dataProduk["req"] = "getMigrasiDataConfig";
      urlWs = config.ConfigURL().urlApiLogin;
    }

    dataProduk["tglAwal"] = McryptUtils.instance.encrypt(tglAwal!);
    dataProduk["tglAkhir"] = McryptUtils.instance.encrypt(tglAkhir!);
    dataProduk["rekCd"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["groupProduk"] = McryptUtils.instance.encrypt(groupProduk!);
    dataProduk["kolektor"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["lat"] = McryptUtils.instance.encrypt(lat ?? '');
    dataProduk["longi"] = McryptUtils.instance.encrypt(long ?? '');

    var resp = await request(
      context: context,
      url: urlWs,
      type: RequestType.POST,
      data: dataProduk,
    );

    return resp;
  }

  Future<List<MutasiProdukCollection>> getMutasiProdukByProdukIdDateRage({
    BuildContext? context,
    String? produkId,
    String? rekCd,
    String? tglAwal,
    String? tglAkhir,
  }) async {
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "getPrimaNotaByProdukIdDateRange";
    dataProduk["id"] = McryptUtils.instance.encrypt(produkId!);
    dataProduk["produk"] = McryptUtils.instance.encrypt(rekCd!);
    dataProduk["tgl_awal"] = McryptUtils.instance.encrypt(tglAwal!);
    dataProduk["tgl_akhir"] = McryptUtils.instance.encrypt(tglAkhir!);
    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_MUTASI_PRODUK_" + rekCd);
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_MUTASI_PRODUK_" + rekCd);
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");

    var resp = await request(
      context: context,
      url: config.ConfigURL().urlApiNasabah,
      type: RequestType.POST,
      data: dataProduk,
    );

    List<MutasiProdukCollection> muatasiProdukCollection = [];

    if (resp != null) {
      var jsonData = json.decode(resp);
      jsonData.forEach((val) {
        muatasiProdukCollection.add(MutasiProdukCollection.fromJson(val));
      });
    }
    return muatasiProdukCollection;
  }

  Future<List<ProdukTabunganUserModel>?> spGetTabunganIdUser({
    BuildContext? context,
    String? idUser,
  }) async {
    var dataProduk = Map<String, dynamic>();
    dataProduk["req"] = "spGetTabunganIdUser";
    dataProduk["id"] = McryptUtils.instance.encrypt(idUser!);
    dataProduk["user"] = McryptUtils.instance.encrypt(config.dataLogin['username']);
    dataProduk["pwd"] = config.dataLogin['password'];
    dataProduk["imei"] = McryptUtils.instance.encrypt(config.dataLogin['imei']);
    dataProduk["activity"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_TABRELA_USER");
    dataProduk["remark"] = McryptUtils.instance.encrypt("GET_ALL_PRODUK_TABRELA_USER");
    dataProduk["lat"] = McryptUtils.instance.encrypt("0");
    dataProduk["longi"] = McryptUtils.instance.encrypt("0");

    var resp = await request(
      context: context,
      url: config.ConfigURL().urlApiNasabah,
      type: RequestType.POST,
      data: dataProduk,
    );

    List<ProdukTabunganUserModel>? produkTabunganUser;

    if (resp != null) {
      var jsonData = json.decode(resp);
      produkTabunganUser = [];
      jsonData.forEach((val) {
        produkTabunganUser!.add(ProdukTabunganUserModel.fromJson(val));
      });
    }
    return produkTabunganUser;
  }
}
