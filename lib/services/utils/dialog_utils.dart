import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/viewmodel/global_provider.dart';
import '../config/router_generator.dart';
import '../config/config.dart' as config;
import '../utils/mcrypt_utils.dart';
import '../utils/text_utils.dart';
import '../viewmodel/produk_provider.dart';
import '../../ui/widgets/dialog/info_dialog.dart';

class DialogUtils {
  GlobalProvider? globalProvider;
  ProdukCollectionProvider? produkProv;
  static DialogUtils instance = DialogUtils();

  dynamic showInfo({
    BuildContext? context,
    String? title,
    String? text,
    String? clickOKText,
    String? clickCancelText,
    Function? onClickOK,
    Function? onClickCancel,
    bool isCancel = true,
  }) {
    return showModal(
      context: context!,
      configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (context) {
        return InfoDialog(
          title: title ?? "",
          text: text!,
          clickOKText: clickOKText,
          onClickOK: onClickOK,
          clickCancelText: clickCancelText,
          onClickCancel: onClickCancel,
          isCancel: isCancel,
        );
      },
    );
  }

  dynamic showError({BuildContext? context, String? text}) {
    return showModal(
      context: context!,
      configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (context) {
        return ErrorDialog(
          text: text ?? '',
        );
      },
    );
  }

  dynamic getOTPSMSWA(context, tipe, nomor) async {
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "getSMSOTP";
    dataLogin["id_user"] = McryptUtils.instance.encrypt("0");
    dataLogin["nasabah_id"] = McryptUtils.instance.encrypt("0");
    dataLogin["remark"] = McryptUtils.instance.encrypt("REQUEST_OTP_VALIDATE_PHONE_NUMBER");
    dataLogin["phone"] = McryptUtils.instance.encrypt(nomor);
    dataLogin["mode_req_token"] = McryptUtils.instance.encrypt(tipe);

    // try {
    //   final data = await _appService.apiController
    //       .makePostFormDataRequestLogin(dataLogin);
    //   final result = data == null ? null : json.decode(data);

    //   if (result == null) {
    //     showError(context: context);
    //     return null;
    //   } else if (result[0]['status'] == "Gagal" ||
    //       result[0]['status'] == "Sukses") {
    //     showError(context: context, text: result[0]['pesan']);
    //     return null;
    //   } else {
    //     return result;
    //   }
    // } on Exception {
    //   showError(context: context);
    return null;
    // }
  }

  dynamic getOTPSMSWABerbayar(context, tipe, nomor, remark) async {
    var dataLogin = Map<String, dynamic>();
    dataLogin["req"] = "getSMSOTP";
    dataLogin["id_user"] = McryptUtils.instance.encrypt(config.dataLogin['ID_USER']);
    dataLogin["nasabah_id"] = McryptUtils.instance.encrypt(config.dataLogin['nasabah_id']);
    dataLogin["remark"] = McryptUtils.instance.encrypt(remark);
    dataLogin["phone"] = McryptUtils.instance.encrypt(nomor);
    dataLogin["mode_req_token"] = McryptUtils.instance.encrypt(tipe);
    dataLogin["isBayar"] = McryptUtils.instance.encrypt("true");

    // try {
    //   final data = await _appService.apiController
    //       .makePostFormDataRequestLogin(dataLogin);
    //   final result = data == null ? null : json.decode(data);

    //   if (result == null) {
    //     showError(context: context);
    //     return null;
    //   } else if (result[0]['status'] == "Gagal" ||
    //       result[0]['status'] == "Sukses") {
    //     showError(context: context, text: result[0]['pesan']);
    //     return null;
    //   } else {
    //     return result;
    //   }
    // } on Exception {
    //   showError(context: context);
    return null;
    // }
  }

  dynamic dialogDaftarOnline(BuildContext context, [isSave = false]) async {
    bool res = await showInfo(
          context: context,
          text: "Anda yakin ingin membatalkan proses ini? Data yang anda input" + (isSave ? "" : " tidak") + " akan disimpan",
        ) ??
        false;

    if (res) {
      Navigator.of(context).pushNamedAndRemoveUntil(RouterGenerator.pageHomeLogin, (Route<dynamic> route) => false);
    }
  }

  dynamic dialogOnBackHome(BuildContext context, [isSave = false]) async {
    bool res = await showInfo(
          context: context,
          text: "Anda yakin ingin ingin keluar dari aplikasi?",
        ) ??
        false;

    if (res) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouterGenerator.pageLogin,
        (Route<dynamic> route) => false,
      );
    }
  }

  dynamic dialogChangeMode(
    BuildContext context,
    String mode, {
    bool isKlad = false,
  }) async {
    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    bool res = await showInfo(
          context: context,
          text: 'Anda yakin ingin beralih ke mode ' + mode.toLowerCase() + '?',
        ) ??
        false;

    return res;

    // if (res) {
    //   globalProvider.setConnectionMode(mode);
    //   if (isKlad) produkProv.resetMutasiTransaksi();
    // }
  }

  dynamic dialogConfirm(BuildContext context, String messgae) async {
    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    bool res = await showInfo(
          context: context,
          text: messgae,
        ) ??
        false;

    return res;
  }

  Future<bool> onBackPressedDaftarOnline(BuildContext context, [isSave = false]) async {
    return (await dialogDaftarOnline(context, isSave)) ?? false;
  }

  Future<bool> onBackPressedHome(BuildContext context, [isSave = false]) async {
    return (await dialogOnBackHome(context, isSave)) ?? false;
  }

  dynamic dialogBackProses({
    BuildContext? context,
    bool isSave = false,
    String? navigator,
  }) async {
    bool res = await showInfo(
          context: context,
          text: "Anda yakin ingin membatalkan proses ini? Data yang anda input" + (isSave ? "" : " tidak") + " akan disimpan",
        ) ??
        false;

    if (res) {
      Navigator.of(context!).pushNamedAndRemoveUntil(navigator!, (Route<dynamic> route) => false);
    }
  }

  Future<bool> onBackPressedBackProses({
    BuildContext? context,
    bool isSave = false,
    String? navigator,
  }) async {
    return (await dialogBackProses(context: context, isSave: isSave, navigator: navigator)) ?? false;
  }

  Future validateSaldoTransaksi(
    BuildContext context, {
    String? price,
  }) async {
    ProdukTabunganProvider tabProvider = Provider.of<ProdukTabunganProvider>(context, listen: false);
    if (int.parse(price!) > int.parse(double.parse(tabProvider.saldoSumber).toStringAsFixed(0))) {
      DialogUtils.instance.showError(
        context: context,
        text: "Transaksi melebihi saldo rekening!",
      );
      return;
    }

    if (int.parse(double.parse(tabProvider.saldoSumber).toStringAsFixed(0)) - int.parse(price) <= int.parse(config.dataSetting['min_saldo'] ?? "0")) {
      DialogUtils.instance.showError(
        context: context,
        text: "Saldo pengendapan minimal adalah ${TextUtils.instance.numberFormat(config.dataSetting['min_saldo'] ?? '0')}!",
      );
      return;
    }

    return true;
  }
}
