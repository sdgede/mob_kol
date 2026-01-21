import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

import '../../../database/databaseHelper.dart';
import '../../../database/table_config.dart';
import '../../../model/produk_model.dart';
import '../../../services/config/config.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/viewmodel/transaksi_provider.dart';
import '../../../ui/widgets/produk/produk_util_widget.dart';
import '../../../ui/widgets/util_button.dart';
import '../../../services/utils/text_utils.dart';

class FieldListKlad extends StatefulWidget {
  final MutasiProdukCollection dataTrans;
  final bool isKlad;
  FieldListKlad({required this.dataTrans, this.isKlad = false});

  @override
  _FieldListKlad createState() => _FieldListKlad();
}

class _FieldListKlad extends State<FieldListKlad> {
  ProdukCollectionProvider? produkProv;
  GlobalProvider? globalProv;
  TransaksiProvider? transProvider;
  final dbHelper = DatabaseHelper.instance;
  double? totalSetoran, totalTarikan, jml;

  @override
  void initState() {
    super.initState();
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    transProvider = Provider.of<TransaksiProvider>(context, listen: false);
  }

  _actionDataTrxOffline(
    MutasiProdukCollection dataTrans,
    String type,
    BuildContext context,
  ) async {
    if (type == 'UPLOAD') {
      await transProvider!.prosesTransaksiKolektor(
        context: context,
        tipeTrans: 'SETOR',
        norek: dataTrans.norek,
        jumlah: dataTrans.jumlah,
        remark: dataTrans.remark,
        produkId: '0',
        action: 'SINGLE_UPLOAD',
        trxOfflineId: dataTrans.trans_id,
        sendNotifTrx: true,
        forceSendNotifTrx: true,
      );
    } else {
      bool deleteAction = await dbHelper.deleteDataGlobalWithCLause(tbTrxGlobal, tbTrxGlobal_id, dataTrans.trans_id);

      if (deleteAction) produkProv!.resetMutasiTransaksi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7), bottomLeft: Radius.circular(7), bottomRight: Radius.circular(7)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      //color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: CustomDbCrBox(context, widget.dataTrans.dbcr!),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.dataTrans.tgl!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 15),
                              if (globalProv!.getConnectionMode == offlineMode)
                                badges.Badge(
                                  // toAnimate: true,
                                  // shape: BadgeShape.square,
                                  // badgeColor: widget.dataTrans.isUpload == 'Y'
                                  //     ? Colors.green
                                  //     : Colors.grey.shade500,
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: 5, vertical: 1),
                                  // borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: widget.dataTrans.isUpload == 'Y' ? Colors.green : Colors.grey.shade500,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    child: Text(widget.dataTrans.isUpload == 'Y' ? 'TERUPLOAD' : 'BELUM TERUPLOAD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        )),
                                  ),

                                  showBadge: false,
                                ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.dataTrans.nama! + ' - ' + widget.dataTrans.norek!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          hisrizontalTxtList(
            text: "Jumlah",
            value: widget.dataTrans.jumlah!,
          ),
          hisrizontalTxtList(
            text: "Saldo",
            value: widget.dataTrans.saldo!,
          ),
          hisrizontalTxtList(
            text: "Tipe",
            value: widget.dataTrans.kode!,
            isNumber: false,
          ),

          // hisrizontalTxtList(
          //   text: "Status",
          //   value: widget.dataTrans.isUpload == 'N'
          //       ? 'BELUM TERUPLOAD'
          //       : 'SUDAH TERUPLOAD',
          //   isNumber: false,
          //   customColor:
          //       widget.dataTrans.isUpload == 'N' ? Colors.red : Colors.green,
          // ),
          SizedBox(height: 10),
          if (globalProv!.getConnectionMode == offlineMode)
            Column(
              children: [
                Divider(),
                Row(
                  children: [
                    btnTxtAndIcon(
                      isEnable: widget.dataTrans.isUpload == 'N' ? true : false,
                      icon: Icons.upload_rounded,
                      label: 'Upload',
                      icColor: Colors.green,
                      onTap: () => _actionDataTrxOffline(widget.dataTrans, 'UPLOAD', context),
                    ),
                    SizedBox(width: 15),
                    btnTxtAndIcon(
                      isEnable: true,
                      icon: Icons.close_rounded,
                      label: 'Hapus',
                      icColor: Colors.red,
                      onTap: () async {
                        bool confirm = await DialogUtils.instance.dialogConfirm(context, 'Anda yakin ingin menghapus data transaksi ini?');
                        if (confirm) _actionDataTrxOffline(widget.dataTrans, 'HAPUS', context);
                      },
                    ),
                  ],
                )
              ],
            ),

          //Divider(),
        ],
      ),
    );
  }
}

Widget hisrizontalTxtList({
  String? text,
  bool isTextBold = false,
  String? value,
  bool isValueBold = false,
  bool isNumber = true,
  Color customColor = Colors.black,
}) {
  return Padding(
    padding: EdgeInsets.only(top: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            text ?? "",
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTextBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Flexible(
          child: Text(
            isNumber ? TextUtils.instance.numberFormat(value ?? "0") : (value ?? ""),
            style: TextStyle(
              fontSize: 14,
              color: customColor,
              fontWeight: isValueBold ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
