import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../services/utils/dialog_utils.dart';
import '../../services/viewmodel/transaksi_provider.dart';
import '../../services/viewmodel/produk_provider.dart';
import '../../services/viewmodel/global_provider.dart';
import '../../services/config/config.dart' as config;

GlobalProvider? globalProv;
String _mode = config.onlineMode;
TransaksiProvider? trxProv;

Widget floatingActionSwitchMode(BuildContext context, {isKlad = false}) {
  return Consumer2<GlobalProvider, ProdukCollectionProvider>(
    builder: (context, globalProvider, produkProv, _) {
      return new FloatingActionButton.extended(
        label: Text(
          globalProvider.getConnectionMode,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if (globalProvider.getConnectionMode == config.onlineMode)
            _mode = config.offlineMode;
          else
            _mode = config.onlineMode;

          if (config.forbidenOffline.contains(produkProv.getSelectedgroupProdukProduk)) {
            DialogUtils.instance.showError(
              context: context,
              text: "Tidak dapat menggunakan mode offline pada jenis transaksi ini",
            );
          } else {
            bool confirm = await DialogUtils.instance.dialogChangeMode(context, _mode, isKlad: isKlad);
            if (confirm) {
              globalProvider.setConnectionMode(_mode);
              if (isKlad) produkProv.resetMutasiTransaksi();
            }
          }
        },
        icon: Icon(
          globalProvider.getConnectionMode == config.onlineMode ? Icons.wifi : Icons.wifi_off,
          color: Colors.white,
        ),
        backgroundColor: globalProvider.getConnectionMode == config.onlineMode ? Colors.green : Colors.grey,
        heroTag: null,
      );
    },
  );
}

Widget floatingActionUploadTrx(BuildContext context) {
  trxProv = Provider.of<TransaksiProvider>(context, listen: false);
  return Consumer2<GlobalProvider, ProdukCollectionProvider>(
    builder: (context, globalProvider, produkProv, _) {
      return new FloatingActionButton(
        onPressed: () async {
          bool _confirm = await DialogUtils.instance.dialogConfirm(
            context,
            "Ingin mengupload seluruh data transaksi " + produkProv.getSelectedProdukName!.toLowerCase() + "?",
          );
          if (_confirm) {}
        },
        child: Icon(
          // FlutterIcons.upload_multiple_mco,
          Iconsax.document_upload,
          color: Colors.white,
        ),
        heroTag: null,
        backgroundColor: Colors.green,
      );
    },
  );
}
