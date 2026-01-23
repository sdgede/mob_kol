import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../config/config.dart' as config;
import '../../database/databaseHelper.dart';
import '../../services/viewmodel/global_provider.dart';
import '../../services/config/router_generator.dart';
import '../../services/collection/produk_collection.dart';
import '../../services/utils/dialog_utils.dart';
import '../../model/produk_model.dart';
import '../../setup.dart';

class ProdukCollectionProvider extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  ProdukCollectionServices produkCollectionServices =
      setup<ProdukCollectionServices>();
  GlobalProvider? gobalProv;
  // daftar produk
  List<ProdukCollection>? _produkCollection;
  List<ProdukCollection>? get produkCollection => _produkCollection;
  void refreshProdukCollection() {
    _produkCollection = null;
    notifyListeners();
  }

  List<ProdukCollection>? _produkCollectionMigrasi;
  List<ProdukCollection>? get produkCollectionMigrasi =>
      _produkCollectionMigrasi;
  void refreshProdukCollectionMigrasi() {
    _produkCollectionMigrasi = null;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  String? _selectedRekCdProduk;
  String get getSelectedRkCdProduk => _selectedRekCdProduk ?? '';
  void setSelectedRekCdProduk(String rekCd, {bool listen = true}) {
    _selectedRekCdProduk = rekCd;
    if (listen) notifyListeners();
  }

  String? _selectedgroupProdukProduk;
  String? get getSelectedgroupProdukProduk => _selectedgroupProdukProduk ?? '';
  void setSelectedgroupProdukProduk(String group, {bool listen = true}) {
    _selectedgroupProdukProduk = group;
    if (listen) notifyListeners();
  }

  void resetSelectedgroupProdukProduk() {
    _selectedgroupProdukProduk = "RESET";
    notifyListeners();
  }

  String? _selectedProdukName;
  String? get getSelectedProdukName => _selectedProdukName;
  void setSelectedProdukName(String name, {bool listen = true}) {
    _selectedProdukName = name;
    if (listen) notifyListeners();
  }

  String? _selectedMinSetoran;
  String get getSelectedMinSetoran => _selectedMinSetoran!;
  void setSelectedMinSetoran(String minSet, {bool listen = true}) {
    _selectedMinSetoran = minSet;
    if (listen) notifyListeners();
  }

  String? _selectedRekShortcut;
  String? get getSelectedRekShortcut => _selectedRekShortcut;
  void setSelectedRekShortcut(String minSet, {bool listen = true}) {
    _selectedRekShortcut = minSet;
    if (listen) notifyListeners();
  }

  String? _selectedProdukIcon;
  String get getSelectedProdukIcon => _selectedProdukIcon!;
  void setSelectedProdukIcon(String ic, {bool listen = true}) {
    _selectedProdukIcon = ic;
    if (listen) notifyListeners();
  }

  Future<void> setAllDatafirstSelectedProduct(
      {bool isListen = true, BuildContext? context}) async {
    // Pastikan data produk sudah loaded
    if (_produkCollection == null && context != null) {
      await dataProduk(context);
    }

    // Cek apakah produkCollection tersedia dan tidak kosong
    if (_produkCollection == null || _produkCollection!.isEmpty) {
      print("❌ [ProdukProvider] Produk collection kosong atau null");
      return;
    }

    // Cari produk dengan urut_menu = 1, atau ambil produk pertama jika tidak ada
    var _dataProduk = _produkCollection!.firstWhere(
      (element) => element.urut_menu.toString() == '1',
      orElse: () {
        print("⚠️ [ProdukProvider] Produk dengan urut_menu=1 tidak ditemukan");
        print("   Menggunakan produk pertama sebagai fallback");
        return _produkCollection!.first;
      },
    );

    // Set semua data produk terpilih
    _selectedRekCdProduk = _dataProduk.rekCd;
    _selectedgroupProdukProduk = _dataProduk.slug;
    _selectedProdukName = _dataProduk.nama;
    _selectedMinSetoran = _dataProduk.min_setoran;
    _selectedRekShortcut = _dataProduk.rek_shortcut;
    _selectedProdukIcon = _dataProduk.icon;

    print("✅ [ProdukProvider] Produk berhasil dipilih:");
    print("   - Nama: $_selectedProdukName");
    print("   - Kode: $_selectedRekCdProduk");
    print("   - Grup: $_selectedgroupProdukProduk");

    if (isListen) notifyListeners();
  }

  Future<void> dataProduk(
    BuildContext context, {
    isMessage = true,
    migrasi = false,
    bool autoSelect = false,
  }) async {
    try {
      print("📡 [ProdukProvider] Memulai load data produk...");

      dynamic produkCollection = await produkCollectionServices.dataProduk(
          context: context, migrasi: migrasi);

      if (produkCollection == null) {
        print("❌ [ProdukProvider] Response data produk null");
        if (isMessage) DialogUtils.instance.showError(context: context);
        return;
      } else {
        _produkCollection = produkCollection;
        print("✅ [ProdukProvider] Data produk berhasil dimuat:");
        print("   Total: ${_produkCollection!.length} produk");
        setLoading(false);

        // AUTO-SELECT produk pertama jika diminta dan belum ada yang dipilih
        if (autoSelect && _selectedProdukName == null) {
          print("🎯 [ProdukProvider] Melakukan auto-select produk pertama...");
          await setAllDatafirstSelectedProduct(
              isListen: false, context: context);
        }

        notifyListeners();
      }
    } on Exception catch (e) {
      print("❌ [ProdukProvider] Exception saat load produk: $e");
      if (isMessage) DialogUtils.instance.showError(context: context);
    } catch (e) {
      print("❌ [ProdukProvider] Error saat load produk: $e");
      if (isMessage) DialogUtils.instance.showError(context: context);
    }
  }

  void dataProdukMigrasi(BuildContext context, {isMessage = true}) async {
    try {
      // EasyLoading.show(status: 'Loading');
      var produkCollectionMigrasi = await produkCollectionServices.dataProduk(
          context: context, migrasi: true);
      if (produkCollectionMigrasi == null) {
        if (isMessage) DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _produkCollectionMigrasi = produkCollectionMigrasi;
        setLoading(false);
      }
      setLoading(false);
    } on Exception {
      if (isMessage) DialogUtils.instance.showError(context: context);
      setLoading(false);
      return null;
    } catch (e) {
      if (isMessage) DialogUtils.instance.showError(context: context);
      setLoading(false);
      return null;
    }
  }

  // list daftar produk
  List<ListProdukCollection>? _listProdukCollection;
  List<ListProdukCollection> get listProdukCollection => _listProdukCollection!;
  void refreshListProdukCollection() {
    _listProdukCollection = null;
    notifyListeners();
  }

  bool _isListLoading = false;
  bool get isListLoading => _isListLoading;
  void setListLoading(bool isListLoading) {
    _isListLoading = isListLoading;
    notifyListeners();
  }

  String? _jenisProduk;
  String get jenisProduk => _jenisProduk!;
  void setjenisProduk(String jenisProduk) {
    _jenisProduk = jenisProduk;
  }

  String? _saldoResult;
  String? get saldoResult => _saldoResult;
  void setSaldoResult(String? saldo, {bool isListen = true}) {
    _saldoResult = saldo;
    if (isListen) notifyListeners();
  }

  void getDataMutasi({
    BuildContext? context,
    String? idProduk,
    String norek = '0',
  }) async {
    try {
      dynamic listMutasi = await produkCollectionServices.getDataMutasi(
        context: context,
        idProduk: idProduk,
        rekCd: _selectedRekCdProduk,
        groupProduk: _selectedgroupProdukProduk,
        norek: norek,
      );
      if (listMutasi == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _muatasiProdukCollection = listMutasi;
        setListLoading(false);
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  Future<void> getDataKlad(BuildContext context) async {
    try {
      print("📊 [ProdukProvider] Memuat data klad:");
      print("   - Produk: $_selectedProdukName");
      print("   - RekCd: $_selectedRekCdProduk");
      print("   - Grup: $_selectedgroupProdukProduk");

      dynamic listMutasi = await produkCollectionServices.getDataKlad(
        context: context,
        rekCd: _selectedRekCdProduk,
        groupProduk: _selectedgroupProdukProduk,
        startDate: DateFormat("yyyy-MM-dd").format(_tglAwal!),
        endDate: DateFormat("yyyy-MM-dd").format(_tglAkhir!),
      );

      if (listMutasi == null) {
        print("❌ [ProdukProvider] Response data klad null");
        DialogUtils.instance.showError(context: context);
        return;
      } else {
        _muatasiProdukCollection = listMutasi;
        print("✅ [ProdukProvider] Data klad berhasil dimuat:");
        print("   Total transaksi: ${listMutasi.length}");
        setListLoading(false);
        notifyListeners();
      }
    } on Exception catch (e) {
      print("❌ [ProdukProvider] Exception saat load klad: $e");
      DialogUtils.instance.showError(context: context);
    } catch (e) {
      print("❌ [ProdukProvider] Error saat load klad: $e");
      DialogUtils.instance.showError(context: context);
    }
  }

  //saldokol

  List<SaldoKolektorModel>? _saldoKolektorCollection;
  List<SaldoKolektorModel>? get saldoKolektorCollection =>
      _saldoKolektorCollection;

  void refreshSaldoKolektor() {
    _saldoKolektorCollection = null;
    notifyListeners();
  }

  Future getDataSaldoKolektor(
    BuildContext context,
  ) async {
    //try {
    dynamic listSaldokol = await produkCollectionServices.getDataSaldoKolektor(
      context: context,
      rekCd: _selectedRekCdProduk,
      groupProduk: _selectedgroupProdukProduk,
    );
    if (listSaldokol == null) {
      DialogUtils.instance.showError(context: context);
      return null;
    } else {
      _saldoKolektorCollection = listSaldokol;
      setListLoading(false);
    }
    // } on Exception {
    //   DialogUtils.instance.showError(context: context);
    //   return null;
    // } catch (e) {
    //   DialogUtils.instance.showError(context: context);
    //   return null;
    // }
  }

  //saldokol menu
  List<SaldoKolektor>? _saldoKolektorMenu;
  List<SaldoKolektor>? get saldoKolektorMenu => _saldoKolektorMenu;

  void refreshSaldoKolektorMenu() {
    _saldoKolektorMenu = null;
    notifyListeners();
  }

  Future getDataSaldoKolektorMenu(
    BuildContext context,
  ) async {
    dynamic listSaldokol = await produkCollectionServices.getSaldoKolektor(
      context: context,
    );

    print("mock listSaldokol $listSaldokol");
    if (listSaldokol == null) {
      DialogUtils.instance.showError(context: context);
      return null;
    } else {
      _saldoKolektorMenu = listSaldokol;
      setListLoading(false);
    }
  }

  //pencarian

  List<NasabahProdukModel>? _nasabahList;
  List<NasabahProdukModel>? get getNasabahList => _nasabahList;

  void clearSearchNasabah({isListen = true}) {
    _nasabahList = null;
    if (isListen) notifyListeners();
  }

  List<MutasiProdukCollection>? _mutasiProdukCollectionSearch;
  List<MutasiProdukCollection>? get mutasiProdukCollectionSearch =>
      _mutasiProdukCollectionSearch;
  void refreshMutasiProdukCollectionSearch() {
    _mutasiProdukCollectionSearch = null;
    notifyListeners();
  }

  bool _onSearch = false;
  bool get onSearch => _onSearch;

  void setOnSearch(bool status) {
    _onSearch = status;
    notifyListeners();
  }

  void goToSearchNasbah(BuildContext context) async {
    clearSearchNasabah();
    Navigator.pushNamed(context, RouterGenerator.adapterPencarianNasabah);
  }

  void goToSearchMutasi(BuildContext context) async {
    clearSearchNasabah();
    Navigator.pushNamed(context, RouterGenerator.adapterPencarianNasabah);
  }

  void getDataSearchMutasi({BuildContext? context, String? keyword}) {
    var dataJSon = json.encode(_muatasiProdukCollection);
    json.decode(dataJSon).forEach((val) {
      if (val.norek.contains(keyword)) {
        _mutasiProdukCollectionSearch!
            .add(MutasiProdukCollection.fromJson(val));
      }
    });
    notifyListeners();
  }

  Future getDataSerachNasbah(String keyword, BuildContext context) async {
    setOnSearch(true);

    clearSearchNasabah();

    final locationProv = Provider.of<GlobalProvider>(context, listen: false);
    try {
      var res = await produkCollectionServices.getDataSearchNasabah(
        keyword: keyword,
        rekCd: _selectedRekCdProduk,
        groupProduk: _selectedgroupProdukProduk,
        latitude: locationProv.myLatitude.toString(),
        longitude: locationProv.myLongitude.toString(),
        context: context,
      );
      if (res == null) {
        DialogUtils.instance.showError(context: context);
        return false;
      } else {
        _nasabahList = res;
        notifyListeners();
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return false;
    } catch (e) {
      print(e);
      DialogUtils.instance.showError(context: context);
      return false;
    }

    setOnSearch(false);
  }

  Future getDataPenagihanPinajaman(
    BuildContext context,
  ) async {
    final locationProv = Provider.of<GlobalProvider>(context, listen: false);
    locationProv.loadLocation(context);
    try {
      var res = await produkCollectionServices.getDataPenagihanPinajaman(
        tglAwal: DateFormat("yyyy-MM-dd").format(_tglAwal!),
        tglAkhir: DateFormat("yyyy-MM-dd").format(_tglAkhir!),
        context: context,
      );
      if (res == null) {
        DialogUtils.instance.showError(context: context);
        return false;
      } else {
        _nasabahList = res;
        notifyListeners();
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return false;
    } catch (e) {
      print(e);
      DialogUtils.instance.showError(context: context);
      return false;
    }
  }

  void getDataProdukByUserId(
    BuildContext context,
    String idUser,
    String rekCd,
  ) async {
    try {
      var listProdukCollection =
          await produkCollectionServices.getDataProdukByUserId(
        context: context,
        idUser: idUser,
        rekCd: rekCd,
      );
      if (listProdukCollection == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _listProdukCollection = listProdukCollection;
        setListLoading(false);
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  // detail produk
  List<DetailProdukCollection>? _detailProdukCollection;
  List<DetailProdukCollection>? get detailProdukCollection =>
      _detailProdukCollection;
  void refreshDetailProdukCollection() {
    _detailProdukCollection = null;
    notifyListeners();
  }

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;
  void setDetailLoading(bool isDetailLoading) {
    _isDetailLoading = isDetailLoading;
    notifyListeners();
  }

  void getDataDetailProdukByProdukId(
    BuildContext context,
    String produkId,
    String rekCd,
  ) async {
    try {
      dynamic detailProdukCollection =
          await produkCollectionServices.getDataDetailProdukByProdukId(
        context: context,
        produkId: produkId,
        rekCd: rekCd,
      );

      if (detailProdukCollection == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _detailProdukCollection = detailProdukCollection;
        setDetailLoading(false);
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      print(e);
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  void getDataDetailProdukByNasabahId(
    BuildContext context,
    String idUser,
    String rekCd,
  ) async {
    try {
      var detailProdukCollection =
          await produkCollectionServices.getDataDetailProdukByNasabahId(
        context: context,
        idUser: idUser,
        rekCd: rekCd,
      );

      if (detailProdukCollection == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _detailProdukCollection = detailProdukCollection;
        setDetailLoading(false);
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      print(e);
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  Future getDataProdukByRek(
    BuildContext context,
    String norek,
  ) async {
    EasyLoading.show(status: config.Loading);
    // final globalProv = Provider.of<GlobalProvider>(context, listen: false);
    try {
      var detailProdukCollection =
          await produkCollectionServices.getDataProdukByRek(
        context: context,
        norek: norek,
        groupProduk: _selectedgroupProdukProduk,
        rekCd: _selectedRekCdProduk,
      );

      var result = detailProdukCollection == null
          ? null
          : json.decode(detailProdukCollection);
      if (result == null) {
        EasyLoading.dismiss();
        DialogUtils.instance.showError(context: context);
        return false;
      } else {
        if (result[0]['res_status'] == 'Gagal') {
          EasyLoading.dismiss();
          DialogUtils.instance
              .showError(context: context, text: result[0]['pesan']);
          return false;
        } else {
          var jsonData = json.decode(detailProdukCollection);
          List<DetailProdukCollection> detailProdukCollectionRes = [];
          jsonData.forEach((val) {
            print(val);
            detailProdukCollectionRes.add(DetailProdukCollection.fromJson(val));
          });
          _detailProdukCollection = detailProdukCollectionRes;
          EasyLoading.dismiss();
          return true;
        }
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return false;
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      DialogUtils.instance.showError(context: context);
      return false;
    }
  }

  Future getDataMigrasi({
    BuildContext? context,
    String? groupProduk,
    String? rekCd,
    String? descMigrasi,
  }) async {
    EasyLoading.show(status: config.Loading);
    final globalProv = Provider.of<GlobalProvider>(context!, listen: false);
    try {
      dynamic dataMigrasi = await produkCollectionServices.getDataMigrasi(
        context: context,
        groupProduk: groupProduk,
        rekCd: rekCd,
        tglAwal: DateFormat("yyyy-MM-dd").format(tglAwal),
        tglAkhir: DateFormat("yyyy-MM-dd").format(_tglAkhir!),
        lat: globalProv.latitude.toString(),
        long: globalProv.longitude.toString(),
      );
      var result = dataMigrasi == null ? null : json.decode(dataMigrasi);
      if (result == null) {
        EasyLoading.dismiss();
        DialogUtils.instance.showError(context: context);
        return false;
      } else {
        var firstResult = result[0] ?? result["0"];
        if (firstResult['res_status'] == 'Gagal') {
          EasyLoading.dismiss();
          DialogUtils.instance
              .showError(context: context, text: result[0]['pesan']);
          return false;
        } else {
          var actionMigrate;
          //if (['ANGGOTA', 'TABUNGAN', 'BERENCANA'].contains(groupProduk))

          if (groupProduk == 'DATA_AKUN') {
            actionMigrate = await dbHelper.manageDataMigrationAccount(
                dataMigrasi, groupProduk, rekCd);
          } else if (groupProduk == 'MASTER_NASABAH') {
            actionMigrate = await dbHelper.manageDataMigrationNasabah(
                dataMigrasi, groupProduk, rekCd);
          } else if (groupProduk == 'CONFIG') {
            actionMigrate =
                await dbHelper.manageDataMigrationConfig(dataMigrasi);
          } else {
            actionMigrate = await dbHelper.manageDataMigrationProduct(
                dataMigrasi, groupProduk, rekCd);
          }
          EasyLoading.dismiss();
          await DialogUtils.instance.showInfo(
            context: context,
            isCancel: false,
            title: "Pemberitahuan!",
            text: descMigrasi! +
                " per tanggal " +
                DateFormat("dd-MM-yyyy").format(tglAwal) +
                " - " +
                DateFormat("dd-MM-yyyy").format(tglAkhir) +
                " berhasil.  \n\n" +
                "Data ditambahkan : " +
                actionMigrate['row_add'].toString() +
                "\n" +
                "Data diperbarui : " +
                actionMigrate['row_edit'].toString(),
            clickOKText: "TUTUP",
          );
          return true;
        }
      }
    } on Exception {
      EasyLoading.dismiss();
      DialogUtils.instance.showError(context: context);
      return false;
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      DialogUtils.instance.showError(context: context);
      return false;
    }
  }

  // mutasi produk
  List<MutasiProdukCollection>? _muatasiProdukCollection;
  List<MutasiProdukCollection>? get muatasiProdukCollection =>
      _muatasiProdukCollection;

  void resetMutasiTransaksi({isListen = true}) {
    _muatasiProdukCollection = null;
    if (isListen) notifyListeners();
  }

  void refreshAllMenuKlad() {
    _produkCollection = null;
    _muatasiProdukCollection = null;
    notifyListeners();
  }

  bool _isMutasiLoading = true;
  bool get isMutasiLoading => _isMutasiLoading;
  void setMutasiLoading(bool isMutasiLoading, [bool isNotify = false]) {
    _isMutasiLoading = isMutasiLoading;
    if (isNotify) notifyListeners();
  }

  DateTime? _tglAwal;
  DateTime get tglAwal => _tglAwal ?? DateTime.now();
  void setTglAwal(DateTime tglAwal, [bool isNotify = false]) {
    _tglAwal = tglAwal;
    if (isNotify) notifyListeners();
  }

  DateTime? _tglAkhir;
  DateTime get tglAkhir => _tglAkhir ?? DateTime.now();
  void setTglAkhir(DateTime tglAkhir, [bool isNotify = false]) {
    _tglAkhir = tglAkhir;
    if (isNotify) notifyListeners();
  }

  String? _idProduk;
  String get idProduk => _idProduk!;
  void setIdProduk(String idProduk, [bool isNotify = false]) {
    _idProduk = idProduk;
    if (isNotify) notifyListeners();
  }

  void getMutasiProdukByProdukIdDateRage(
    BuildContext context,
    String produkId,
    String rekCd,
  ) async {
    try {
      print("mutasi data called");
      dynamic muatasiProdukCollection =
          await produkCollectionServices.getMutasiProdukByProdukIdDateRage(
        context: context,
        produkId: produkId,
        rekCd: rekCd,
        tglAwal: _tglAwal.toString(),
        tglAkhir: _tglAkhir.toString(),
      );
      print("mutasi data response $muatasiProdukCollection");
      if (muatasiProdukCollection == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _muatasiProdukCollection = muatasiProdukCollection;
        setMutasiLoading(false, true);
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }
}

class ProdukTabunganProvider extends ChangeNotifier {
  ProdukCollectionServices produkCollectionServices =
      setup<ProdukCollectionServices>();

  List<ProdukTabunganUserModel>? _produkTabunganUser;
  List<ProdukTabunganUserModel> get produkTabunganUser => _produkTabunganUser!;

  String? _rekSumber, _namaSumber, _saldoSumber;
  String get rekSumber => _rekSumber!;
  String get namaSumber => _namaSumber!;
  String get saldoSumber => _saldoSumber!;

  String? _rekDefaultSumber, _namaDefaultSumber, _saldoDefaultSumber;
  String get rekDefaultSumber => _rekDefaultSumber!;
  String get namaDefaultSumber => _namaDefaultSumber!;
  String get saldoDefaultSumber => _saldoDefaultSumber!;
  String get pemilikNamaRekSumber =>
      _namaSumber == null ? "" : _rekSumber! + " - " + _namaSumber!;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void resetTabunganUser() {
    _produkTabunganUser = null;
    notifyListeners();
  }

  void spGetTabunganIdUser(BuildContext context, String idUser,
      [bool isSet = false]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      var produkTabunganUser =
          await produkCollectionServices.spGetTabunganIdUser(
        context: context,
        idUser: idUser,
      );
      if (produkTabunganUser == null) {
        DialogUtils.instance.showError(context: context);
        return null;
      } else {
        _produkTabunganUser = produkTabunganUser;
        if (isSet) {
          final rekSumberDefault = prefs.getString('rekSumber');
          if (rekSumberDefault == null || rekSumberDefault == "") {
            prefs.setString('rekSumber', produkTabunganUser[0].no_rek!);
            setDefaultRekSumber(produkTabunganUser[0].no_rek!,
                produkTabunganUser[0].nama!, produkTabunganUser[0].saldo!);
          } else {
            produkTabunganUser.forEach((val) {
              if (val.no_rek == rekSumberDefault) {
                setDefaultRekSumber(val.no_rek!, val.nama!, val.saldo!);
              }
            });
          }
        }
        setLoading(false);
      }
    } on Exception {
      DialogUtils.instance.showError(context: context);
      return null;
    } catch (e) {
      DialogUtils.instance.showError(context: context);
      return null;
    }
  }

  void setDefaultRekSumber(String noRek, String nama, String saldo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rekDefaultSumber = noRek;
    _saldoDefaultSumber = saldo;
    _namaDefaultSumber = nama;
    _rekSumber = noRek;
    _saldoSumber = saldo;
    _namaSumber = nama;
    prefs.setString('rekSumber', noRek);
    notifyListeners();
  }

  void setRekSumber({String? noRek}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rekSumber = noRek ?? prefs.getString('rekSumber');
    produkTabunganUser.forEach((val) {
      if (val.no_rek == _rekSumber) {
        _saldoSumber = val.saldo;
        _namaSumber = val.nama;
      }
    });
    notifyListeners();
  }
}
