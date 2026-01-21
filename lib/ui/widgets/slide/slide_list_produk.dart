import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/produk_model.dart';
import '../../../services/config/config.dart' as config;
import '../../../services/utils/dialog_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../constant/constant.dart';

class SlideListProduk extends StatefulWidget {
  final ProdukCollection dataProduk;
  final bool isKlad;
  SlideListProduk({required this.dataProduk, required this.isKlad});

  @override
  _SlideListProduk createState() => _SlideListProduk();
}

class _SlideListProduk extends State<SlideListProduk> {
  ProdukCollectionProvider? produkProv, dta;
  GlobalProvider? globalProv;
  ProdukCollection? dataFirst;

  @override
  void initState() {
    super.initState();
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    produkProv!.setAllDatafirstSelectedProduct(isListen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (config.forbidenOffline.contains(widget.dataProduk.slug) && globalProv!.getConnectionMode == config.offlineMode) {
                DialogUtils.instance.showError(context: context, text: "Tidak dapat menggunakan mode offline pada jenis transaksi ini, silakan beralih ke mode online terlebih dahulu");
              } else {
                produkProv!.setSelectedRekCdProduk(widget.dataProduk.rekCd!);
                produkProv!.setSelectedgroupProdukProduk(widget.dataProduk.slug!);
                produkProv!.setSelectedProdukName(widget.dataProduk.nama!);
                produkProv!.setSelectedProdukIcon(widget.dataProduk.icon!);
                produkProv!.setSelectedMinSetoran(widget.dataProduk.min_setoran!);
                print(widget.dataProduk.rekCd);
                print(widget.dataProduk.slug);
                produkProv!.setSelectedRekShortcut(widget.dataProduk.rek_shortcut!);
                if (widget.isKlad) produkProv!.resetMutasiTransaksi();
              }
            },
            child: Column(
              children: [
                Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  elevation: 3.0,
                  color: (produkProv!.getSelectedRkCdProduk == widget.dataProduk.rekCd) ? accentColor : Colors.white,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 120,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: (produkProv!.getSelectedRkCdProduk == widget.dataProduk.rekCd) ? Colors.white : Colors.grey.shade200,
                          child: Container(
                            padding: EdgeInsets.all(7),
                            child: globalProv!.getConnectionMode == config.onlineMode
                                ? Image.network(
                                    config.ConfigURL().iconLink + widget.dataProduk.icon!,
                                    height: 30,
                                    width: 30,
                                  )
                                : Image.asset('assets/icon/' + widget.dataProduk.icon!),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.dataProduk.nama!.toUpperCase(),
                          style: TextStyle(
                            color: (produkProv!.getSelectedRkCdProduk == widget.dataProduk.rekCd) ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 3),
        ],
      ),
    );
  }
}
