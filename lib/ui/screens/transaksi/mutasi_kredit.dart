import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../ui/screens/printer/main_setting_printer.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/not_found.dart';

class MutasiKredit extends StatefulWidget {
  final Map? arguments;
  const MutasiKredit({Key? key, this.arguments}) : super(key: key);

  @override
  _MutasiKredit createState() => _MutasiKredit();
}

class _MutasiKredit extends State<MutasiKredit> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _idProduk, _rekCd, _groupProduk, _norek;
  ProdukCollectionProvider? produkProvider;

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    _idProduk = widget.arguments!['idProduk'];
    _rekCd = widget.arguments!['rekCd'];
    _groupProduk = widget.arguments!['groupProduk'];
    _norek = widget.arguments!['norek'];
    print(_rekCd);

    produkProvider!.resetMutasiTransaksi(isListen: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(context, 'Mutasi Kredit', isRefresh: true, onRefresh: () => produkProvider!.resetMutasiTransaksi()),
      key: scaffoldKey,
      body: Consumer<ProdukCollectionProvider>(
        builder: (context, produkProv, _) {
          if (produkProv.muatasiProdukCollection == null) {
            produkProv.getDataMutasi(
              context: context,
              idProduk: _idProduk,
              norek: _norek!,
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

          return SafeArea(
            child: Container(
              height: deviceHeight(context),
              width: deviceWidth(context),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  DataTable(
                    columnSpacing: 2.5,
                    columns: <DataColumn>[
                      DataColumn(label: Text("Tanggal")),
                      DataColumn(label: Text("Pokok")),
                      DataColumn(label: Text("Bunga")),
                      DataColumn(label: Text("Denda")),
                      DataColumn(label: Text("Setoran")),
                      DataColumn(label: Text("Bakidebet")),
                      DataColumn(label: Text("Print")),
                    ],
                    rows: produkProv.muatasiProdukCollection!
                        .map(
                          ((element) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(element.tgl!)),
                                  DataCell(Text(
                                    TextUtils.instance.numberFormat(
                                      element.pokok?.toString() ?? '0',
                                      isRp: false,
                                    ),
                                  )),
                                  DataCell(Text(
                                    TextUtils.instance.numberFormat(element.bunga?.toString() ?? "0", isRp: false),
                                  )),
                                  DataCell(Text(
                                    TextUtils.instance.numberFormat(
                                      element.denda?.toString() ?? '0',
                                      isRp: false,
                                    ),
                                  )),
                                  DataCell(Text(
                                    TextUtils.instance.numberFormat(
                                      element.jumlah?.toString() ?? '0',
                                      isRp: false,
                                    ),
                                  )),
                                  DataCell(Text(
                                    TextUtils.instance.numberFormat(
                                      element.saldo?.toString() ?? '0',
                                      isRp: false,
                                    ),
                                  )),
                                  DataCell(GestureDetector(
                                    onTap: () {
                                      ThermalPrinterAction.instance.printActionV2(
                                        contex: context,
                                        groupProduk: _groupProduk,
                                        kode: element.kode,
                                        trxDate: element.tgl,
                                        noref: element.referensi_id,
                                        norek: element.norek,
                                        nama: element.nama,
                                        hp: element.hp,
                                        pokok: element.pokok,
                                        bunga: element.bunga,
                                        denda: element.denda,
                                        lateCHarge: element.adm,
                                        jumlah: element.jumlah,
                                        terbilang: element.terbilang,
                                        saldoAkhir: element.saldo,
                                        who: element.op,
                                      );
                                    },
                                    child: Icon(
                                      Icons.print_outlined,
                                      color: accentColor,
                                    ),
                                  )),
                                ],
                              )),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
