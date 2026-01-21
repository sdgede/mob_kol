import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/utils/text_utils.dart';
import '../../../model/produk_model.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../ui/screens/printer/main_setting_printer.dart';
import '../../../ui/widgets/produk/produk_util_widget.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/not_found.dart';

class MutasiTransaksi extends StatefulWidget {
  final Map? arguments;
  const MutasiTransaksi({Key? key, this.arguments}) : super(key: key);

  @override
  _MutasiTransaksi createState() => _MutasiTransaksi();
}

class _MutasiTransaksi extends State<MutasiTransaksi> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>(), _formKeyStep1 = GlobalKey<FormState>();
  String? _idProduk, _rekCd, _groupProduk;
  ProdukCollectionProvider? produkProvider;

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    _idProduk = widget.arguments!['idProduk'];
    _rekCd = widget.arguments!['rekCd'];
    _groupProduk = widget.arguments!['groupProduk'];
    produkProvider!.resetMutasiTransaksi(isListen: false);
    print(_rekCd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(context, widget.arguments!['title'], isRefresh: true, onRefresh: () => produkProvider!.resetMutasiTransaksi()),
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          height: deviceHeight(context),
          width: deviceWidth(context),
          child: Form(
            key: _formKeyStep1,
            // autovalidate: _autoValidateStep1,
            autovalidateMode: AutovalidateMode.disabled,
            child: Consumer<ProdukCollectionProvider>(
              builder: (context, produkProv, _) {
                if (produkProv.muatasiProdukCollection == null) {
                  produkProv.getDataMutasi(
                    context: context,
                    idProduk: _idProduk,
                  );
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (produkProv.muatasiProdukCollection![0].status == 'Gagal') {
                  return Center(
                    child: DataNotFound(
                      pesan: produkProv.muatasiProdukCollection![0].pesan,
                    ),
                  );
                }
                return ListView.builder(
                  //shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: produkProv.muatasiProdukCollection == null ? 0 : produkProv.muatasiProdukCollection!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        children: [
                          dataNasabah(
                            produkProv.muatasiProdukCollection![index].kode!,
                            produkProv.muatasiProdukCollection![index].tgl!,
                            produkProv.muatasiProdukCollection![index].jumlah!,
                            produkProv.muatasiProdukCollection![index].saldo!,
                            produkProv.muatasiProdukCollection![index].remark!,
                            produkProv.muatasiProdukCollection![index].op!,
                            produkProv.muatasiProdukCollection![index].saldo_awal!,
                            produkProv.muatasiProdukCollection![index].dbcr!,
                            produkProv.muatasiProdukCollection![index],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget dataNasabah(
    String tipe,
    String tglTrans,
    String jumlah,
    String saldo,
    String keterangan,
    String creator,
    String saldoAwal,
    String trxType,
    MutasiProdukCollection rowDataTrx,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: CustomDbCrBox(context, trxType),
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
                          Text(
                            tglTrans,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tipe,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ThermalPrinterAction.instance.printActionV2(
                                    contex: context,
                                    groupProduk: _groupProduk ?? '0',
                                    kode: rowDataTrx.kode ?? '0',
                                    trxDate: rowDataTrx.tgl ?? '0',
                                    noref: rowDataTrx.referensi_id ?? '0',
                                    norek: rowDataTrx.norek ?? '0',
                                    nama: rowDataTrx.nama ?? '0',
                                    hp: rowDataTrx.hp,
                                    pokok: rowDataTrx.pokok ?? '0',
                                    bunga: rowDataTrx.bunga ?? '0',
                                    denda: rowDataTrx.denda ?? '0',
                                    jumlah: rowDataTrx.jumlah ?? '0',
                                    terbilang: rowDataTrx.terbilang ?? '0',
                                    saldoAwal: rowDataTrx.saldo_awal ?? '0',
                                    saldoAkhir: rowDataTrx.saldo ?? '0',
                                    who: rowDataTrx.op,
                                  );
                                },
                                child: Icon(Icons.print_outlined),
                              )
                            ],
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
          listMutasi(
            text: "Operator",
            value: creator,
            isNumber: false,
          ),
          listMutasi(
            text: "Jumlah",
            value: jumlah,
          ),
          listMutasi(
            text: "Saldo",
            value: saldo,
          ),
          listMutasi(
            text: "Keterangan",
            value: keterangan,
            isNumber: false,
          ),
        ],
      ),
    );
  }

  Widget listMutasi({
    String? text,
    bool isTextBold = false,
    String? value,
    bool isValueBold = false,
    bool isNumber = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text ?? "",
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTextBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isNumber ? TextUtils.instance.numberFormat(value ?? "0") : (value ?? ""),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isValueBold ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
