import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../database/databaseHelper.dart';
import '../../database/table_config.dart';
import '../../services/viewmodel/global_provider.dart';
import '../../model/global_model.dart';
import '../../services/config/config.dart';
import '../../services/config/router_generator.dart';
import '../../services/collection/transaksi_collection.dart';
import '../../services/utils/dialog_utils.dart';
import '../../services/viewmodel/produk_provider.dart';
import '../../setup.dart';

class TransaksiProvider extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  GlobalProvider? gobalProv;
  ProdukCollectionProvider? produkProv;
  TransaksiCollectionServices transaksiCollectionServices = setup<TransaksiCollectionServices>();

  SuksesTransaksiModel? _dataSuksesTransaksi;
  SuksesTransaksiModel get dataSuksesTransaksi => _dataSuksesTransaksi!;
  void setSuksesTransaksi(value) {
    _dataSuksesTransaksi = value;
    notifyListeners();
  }

  void resetDataSuksesTransaksi() {
    _dataSuksesTransaksi = null;
    notifyListeners();
  }

  int _maxRequestOTP = 3;
  int get maxRequestOTP => _maxRequestOTP;

  int _requestOTP = 0;
  int get requestOTP => _requestOTP;

  int _countSuksesUpTrx = 0;
  int get countSuksesUpTrx => _countSuksesUpTrx;

  int _countGagalUpTrx = 0;
  int get countGagalUpTrx => _countGagalUpTrx;

  void resetCountUpTrx() {
    _countGagalUpTrx = 0;
    _countSuksesUpTrx = 0;
  }

  int _maxProgressUpload = 0;
  int get maxProgressUpload => _maxProgressUpload;

  int _countProgress = 0;
  int get countProgress => _countProgress;

  void resetCountProgress() {
    _maxProgressUpload = 0;
    _countProgress = 0;
  }

  bool _isLoadingUpload = false;
  bool get isLoadingUpload => _isLoadingUpload;

  void setLoadingUpload(bool load) {
    _isLoadingUpload = load;
    notifyListeners();
  }

  DateTime? _timeOTP;
  DateTime get timeOTP => _timeOTP!;

  void resetRequestOTP() {
    _requestOTP = 0;
    _timeOTP = null;
  }

  Future<dynamic> checkRequestOTP({BuildContext? context}) async {
    if (_requestOTP < 3) {
      return true;
    } else {
      DateTime newRequestDate = new DateTime(_timeOTP!.year, _timeOTP!.month, _timeOTP!.day, _timeOTP!.hour, _timeOTP!.minute + 5, _timeOTP!.second);
      if (newRequestDate.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
        await DialogUtils.instance.showError(
          context: context,
          text: "Anda telah melebihi batas permintaan Kode OTP, silakan coba 5 menit lagi.",
        );
        return false;
      } else {
        resetRequestOTP();
        return true;
      }
    }
  }

  OTPModel? _dataOTP;
  OTPModel get dataOTP => _dataOTP!;

  String? _tipeOTP;
  get tipeOTP => _tipeOTP!;
  void setTipeOTP(value) {
    _tipeOTP = value;
  }

  String _resultStatusTransaksi = '-';
  get resultStatusTransaksi => _resultStatusTransaksi;
  void setResultStatusTransaksi(value) {
    _resultStatusTransaksi = value;
    notifyListeners();
  }

  String _pesanResultTransaksi = '-';
  get pesanResultTransaksi => _pesanResultTransaksi;
  void setPesanResultTransaksi(value) {
    _pesanResultTransaksi = value;
    notifyListeners();
  }

  Future sendNotifikasiTransaksiWhatsApp({
    BuildContext? context,
    String? rekCd,
    String? transId,
    bool forceSendNotifTrx = false,
  }) async {
    try {
      if (gobalProv!.getConnectionMode == onlineMode || forceSendNotifTrx) {
        await transaksiCollectionServices.sendNotifikasiTransaksiWhatsApp(
          context: context,
          rekCd: rekCd,
          transId: transId,
        );
      }
    } on Exception {
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  multileUploadTrxOffline(
    BuildContext context,
  ) async {
    resetCountUpTrx();
    resetCountProgress();
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    int _countOffTrx = produkProv!.muatasiProdukCollection!.where((element) => element.isUpload == 'N').length;
    if (_countOffTrx == 0) {
      DialogUtils.instance.showError(
        context: context,
        text: "Tidak ditemukan data transaksi offline yang belum terupload",
      );
    } else {
      setLoadingUpload(true);
      int _lengthStart = 1;
      await Future.forEach<dynamic>(
        produkProv!.muatasiProdukCollection!.where((element) => element.isUpload == 'N'),
        (val) async {
          _maxProgressUpload = _countOffTrx;
          _countProgress++;
          int _incraseLen = _lengthStart++;
          bool res = await prosesTransaksiKolektor(
            context: context,
            tipeTrans: 'SETOR',
            isMultiple: true,
            norek: val!.norek!,
            jumlah: val.jumlah!,
            remark: val.remark!,
            produkId: '0',
            action: 'MULTIPLE_UPLOAD',
            trxOfflineId: val.trans_id,
            loadCount: _incraseLen,
            maxProgress: _countOffTrx,
            sendNotifTrx: true,
            forceSendNotifTrx: true,
          );
          if (res) {
            int _totalCount = _countGagalUpTrx + _countSuksesUpTrx;
            await DialogUtils.instance.showInfo(
              context: context,
              isCancel: false,
              text: "Proses upload " + _totalCount.toString() + " transaksi offline telah selesai \n\n" + "Sukses : " + _countSuksesUpTrx.toString() + "\n" + "Gagal : " + _countGagalUpTrx.toString(),
            );

            produkProv!.resetMutasiTransaksi();
            setLoadingUpload(false);
          }
        },
      );
    }
  }

  Future prosesTransaksiKolektor({
    BuildContext? context,
    bool? isMultiple,
    String? rekCd,
    String? groupProduk,
    String? tipeTrans,
    String? norek,
    String? jumlah,
    String? pokok,
    String? bunga,
    String? denda,
    String? lateCharge,
    String? remark,
    String? produkId,
    String? action = 'TRANSAKSI',
    int? trxOfflineId,
    int? loadCount = 0,
    int maxProgress = 0,
    bool sendNotifTrx = false,
    bool forceSendNotifTrx = false,
  }) async {
    isMultiple = isMultiple ?? false;

    gobalProv = Provider.of<GlobalProvider>(context!, listen: false);
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    if (action != 'MULTIPLE_UPLOAD') EasyLoading.show(status: Loading);
    //try {
    _dataSuksesTransaksi = null;
    var res = await transaksiCollectionServices.prosesTransaksiKolektor(
      context: context,
      rekCd: produkProv!.getSelectedRkCdProduk,
      groupProduk: produkProv!.getSelectedgroupProdukProduk,
      tipeTrans: tipeTrans,
      norek: norek,
      jumlah: jumlah == null ? "" : jumlah.replaceAll(".", ""),
      pokok: pokok == null ? "" : pokok.replaceAll(".", ""),
      bunga: bunga == null ? "" : bunga.replaceAll(".", ""),
      denda: denda == null ? "" : denda.replaceAll(".", ""),
      lateCharge: lateCharge == null ? "" : lateCharge.replaceAll(".", ""),
      remark: remark,
      produkId: produkId,
      lat: gobalProv!.myLatitude.toString(),
      long: gobalProv!.myLongitude.toString(),
      connMode: gobalProv!.getConnectionMode,
      action: action,
    );

    if (res == null) {
      if (isMultiple) {
        setLoadingUpload(false);
      }
      DialogUtils.instance.showError(context: context);
      return false;
    } else {
      setSuksesTransaksi(res);
      bool _isValid = false;
      if (_dataSuksesTransaksi!.status == 'Sukses') {
        _isValid = true;
        if (sendNotifTrx) {
          await sendNotifikasiTransaksiWhatsApp(
            context: context,
            rekCd: res.rekCd,
            transId: res.idTrx.toString(),
            forceSendNotifTrx: forceSendNotifTrx,
          );
        }
      } else {
        if (action == 'MULTIPLE_UPLOAD') _isValid = true;
      }

      if (_isValid) {
        if (action == 'SINGLE_UPLOAD') {
          EasyLoading.dismiss();
          DialogUtils.instance.showError(context: context, text: _dataSuksesTransaksi?.pesan);

          Map<String, dynamic> rowUpdate = {tbTrxGlobal_uploaded: 'Y'};
          await dbHelper.updateDataGlobal(
            tbTrxGlobal,
            rowUpdate,
            tbTrxGlobal_id,
            trxOfflineId!,
          );
          produkProv!.resetMutasiTransaksi();
          return true;
        } else if (action == 'MULTIPLE_UPLOAD') {
          if (_dataSuksesTransaksi!.status == 'Sukses') {
            _countSuksesUpTrx++;

            Map<String, dynamic> rowUpdate = {tbTrxGlobal_uploaded: 'Y'};
            await dbHelper.updateDataGlobal(
              tbTrxGlobal,
              rowUpdate,
              tbTrxGlobal_id,
              trxOfflineId!,
            );
          } else {
            _countGagalUpTrx++;
          }

          if (loadCount == maxProgress)
            return true;
          else
            return false;
        } else {
          EasyLoading.dismiss();
          Navigator.of(context).pushReplacementNamed(
            RouterGenerator.suksesTransaksi,
            arguments: _dataSuksesTransaksi,
          );
          return true;
        }
      } else {
        if (isMultiple) {
          setLoadingUpload(false);
        }
        EasyLoading.dismiss();
        DialogUtils.instance.showError(context: context, text: _dataSuksesTransaksi!.pesan);
        return false;
      }
    }
  }
}
