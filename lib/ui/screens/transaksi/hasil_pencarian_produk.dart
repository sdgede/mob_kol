import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/config/router_generator.dart';
import '../../../services/config/config.dart' as config;
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/dialog/custom_trans_dialog.dart';

class HasilPencarianProduk extends StatefulWidget {
  final Map? arguments;
  const HasilPencarianProduk({Key? key, this.arguments}) : super(key: key);

  @override
  _HasilPencarianProduk createState() => _HasilPencarianProduk();
}

class _HasilPencarianProduk extends State<HasilPencarianProduk> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>(), _formKeyStep1 = GlobalKey<FormState>();
  GlobalProvider? _globalProvider;
  ProdukCollectionProvider? _produkProv;
  bool _btnTarikStatus = true, _btnHistoryStatus = true;
  String _produkId = '0';

  @override
  void initState() {
    super.initState();
    _globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    _produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _produkProv!.setSaldoResult(null, isListen: false);

      setState(() {
        if (['ANGGOTA', 'DEPOSITO', 'BERENCANA'].contains(widget.arguments!['tipe']) || _globalProvider!.getConnectionMode == config.offlineMode) {
          _btnTarikStatus = false;
        } else {
          _btnTarikStatus = true;
        }

        if (_globalProvider!.getConnectionMode == config.offlineMode) _btnHistoryStatus = false;
      });
    });
  }

  String _getNoRekDesc() {
    if (widget.arguments!['tipe'] == 'ANGGOTA') return 'No Anggota';
    if (widget.arguments!['tipe'] == 'KREDIT')
      return config.clientType == config.ClientType.koperasi ? 'No Pinjaman' : 'No Kredit';
    else
      return 'No Rekening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(context, widget.arguments!['title']),
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _formKeyStep1,
            // autovalidate: _autoValidateStep1,
            autovalidateMode: AutovalidateMode.disabled,
            child: Consumer<ProdukCollectionProvider>(
              builder: (context, produkProv, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _dataNasabah(produkProv),
                    Container(height: 10, color: Colors.grey.shade100),
                    _dataProduk(produkProv),
                    _btnTransaksi(produkProv),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataNasabah(ProdukCollectionProvider produkProv) {
    _produkId = produkProv.detailProdukCollection!.first.produk_id;
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
                backgroundColor: Colors.grey.shade200,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icon/' + widget.arguments!['icon']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 35,
                  height: 35,
                ),
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
                            "Data Nasabah",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].nama,
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
          // if (widget.arguments!['tipe'] == 'BERENCANA')
          // Column(
          //   children: [
          //     SizedBox(height: 10),
          //     textTagihan(
          //       text: "Jenis",
          //       value: produkProv.detailProdukCollection == null
          //           ? ""
          //           : produkProv.detailProdukCollection![0].jenis_siber,
          //       isNumber: false,
          //     ),
          //   ],
          // ),

          // textTagihan(
          //   text: "No. Rekening",
          //   value: produkProv.detailProdukCollection == null
          //       ? ""
          //       : produkProv.detailProdukCollection![0].no_rek,
          //   isNumber: false,
          // ),
          textTagihan(
            text: _getNoRekDesc(),
            value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].no_rek,
            isNumber: false,
          ),
          textTagihan(
            text: "Status Produk",
            value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].status,
            isNumber: false,
          ),
          textTagihan(
            text: "Wilayah",
            value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].wilayah,
            isNumber: false,
          ),
          // textTagihan(
          //   text: "Alamat",
          //   value: produkProv.detailProdukCollection == null
          //       ? ""
          //       : produkProv.detailProdukCollection![0].alamat,
          //   isNumber: false,
          // ),
        ],
      ),
    );
  }

  Widget _dataProduk(ProdukCollectionProvider produkProv) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "Data Produk",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            if (widget.arguments!['tipe'] == 'KREDIT')
              Column(
                children: [
                  // textTagihan(
                  //   text: "Kolektibilitas",
                  //   value: produkProv.detailProdukCollection == null
                  //       ? ""
                  //       : produkProv.detailProdukCollection![0].kolek,
                  //   isNumber: false,
                  // ),
                  textTagihan(
                    text: "Metode Angsuran",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].metode_angsuran,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Sistem Bunga",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].sistem_bunga,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Suku Bunga",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].sb,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Jangka Waktu",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].jangka_waktu,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Tgl Realisasi",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tgl_daftar,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Tgl Jatuh tempo",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tgl_jatem,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Tgl Bayar",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tgl_bayar,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Kolektibilitas",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].kolektibilitas,
                    isNumber: false,
                  ),
                  Text(
                    "Rincian",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  textTagihan(
                    text: "Plafon",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].plafon,
                  ),
                  textTagihan(
                    text: "Baki Debet",
                    value: produkProv.saldoResult == null
                        ? produkProv.detailProdukCollection == null
                            ? ""
                            : produkProv.detailProdukCollection![0].baki_debet
                        : produkProv.saldoResult,
                  ),
                  textTagihan(
                    text: produkProv.detailProdukCollection![0].metode_angsuran == 'Harian' ? 'Pokok Hari ini' : "Pokok Bulan ini",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].pokok_bln_ini,
                  ),
                  textTagihan(
                    text: "Tunggakan Pokok",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tg_pokok,
                  ),
                  textTagihan(
                    text: produkProv.detailProdukCollection![0].metode_angsuran == 'Harian' ? 'Bunga Hari ini' : "Bunga Bulan ini",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].bnga_bln_ini,
                  ),
                  textTagihan(
                    text: "Tunggakan Bunga",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tunggakan_bunga,
                  ),
                  textTagihan(
                    text: "Denda",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].denda,
                  ),

                  textTagihan(
                    text: "Total Tagihan",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].total_bayar,
                  ),
                ],
              ),
            if (['DEPOSITO', 'BERENCANA'].contains(widget.arguments!['tipe']))
              Column(
                children: [
                  textTagihan(
                    text: "Jangka Waktu",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].jangka_waktu,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Tgl Mulai",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tgl_daftar,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Tgl Akhir",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].tgl_jatem,
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Setoran Per Bulan",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].setoran_per_bulan.toString(),
                  ),
                  textTagihan(
                    text: "Setoran Awal",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].setoran_awal.toString(),
                  ),
                  textTagihan(
                    text: "Suku Bunga",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].sb.toString() + ' %',
                    isNumber: false,
                  ),
                  textTagihan(
                    text: "Jumlah Diterima",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].jumlah_diterima.toString(),
                  ),
                  textTagihan(
                    text: "Saldo",
                    value: produkProv.saldoResult == null
                        ? produkProv.detailProdukCollection == null
                            ? ""
                            : produkProv.detailProdukCollection![0].saldo
                        : produkProv.saldoResult,
                  ),
                  textTagihan(
                    text: "Nominal Tunggakan",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].nominal_tunggakan,
                  ),
                  textTagihan(
                    text: "Kali Nunggak",
                    value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].kali_nunggak,
                    isNumber: false,
                  ),
                ],
              ),
            if (['ANGGOTA', 'TABUNGAN'].contains(widget.arguments!['tipe']))
              Column(
                children: [
                  textTagihan(
                    text: "Saldo",
                    value: produkProv.saldoResult == null
                        ? produkProv.detailProdukCollection == null
                            ? ""
                            : produkProv.detailProdukCollection![0].saldo
                        : produkProv.saldoResult,
                  ),
                  if (widget.arguments!['tipe'] == 'TABUNGAN')
                    Column(
                      children: [
                        textTagihan(
                          text: "Saldo diblokir",
                          value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].saldoblokir,
                        ),
                        textTagihan(
                          text: "Keterangan blokir",
                          value: produkProv.detailProdukCollection == null ? "" : produkProv.detailProdukCollection![0].remarkBlokir!,
                          isNumber: false,
                        ),
                      ],
                    ),
                ],
              ),
            Divider(color: Colors.grey.shade200, thickness: 1),
            textTagihan(
              text: "Kolektor",
              value: config.dataLogin['username'],
              isNumber: false,
            ),
            if (['ANGGOTA', 'TABUNGAN'].contains(widget.arguments!['tipe']))
              textTagihan(
                text: "Tgl Transaksi Terakhir",
                value: produkProv.detailProdukCollection![0].last_trans_date,
                isNumber: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget textTagihan({
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
          Text(
            text ?? "",
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTextBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            isNumber ? TextUtils.instance.numberFormat(value ?? "0") : (value ?? ""),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isValueBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnTransaksi(ProdukCollectionProvider produkProv) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                width: deviceWidth(context) / 2.3,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomTransDialog(
                            img: widget.arguments!['icon'],
                            groupProduk: widget.arguments!['tipe'],
                            rekCd: widget.arguments!['rekCd'],
                            norek: widget.arguments!['norek'],
                            tipeTrans: widget.arguments!['tipe'] == 'KREDIT' ? 'ANGSURAN' : 'SETOR',
                            produkModel: produkProv.detailProdukCollection![0],
                            produkId: _produkId,
                          );
                        },
                      );
                    },
                    child: Center(
                      child: Text(
                        widget.arguments!['tipe'] == 'KREDIT' ? "ANGSURAN" : "SETOR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                width: deviceWidth(context) / 2.3,
                decoration: BoxDecoration(
                  color: (_btnTarikStatus) ? Colors.orange : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_btnTarikStatus)
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomTransDialog(
                              img: widget.arguments!['icon'],
                              groupProduk: widget.arguments!['tipe'],
                              rekCd: widget.arguments!['rekCd'],
                              norek: widget.arguments!['norek'],
                              tipeTrans: widget.arguments!['tipe'] == 'KREDIT' ? 'PELUNASAN' : 'TARIK',
                              produkModel: produkProv.detailProdukCollection![0],
                              produkId: _produkId,
                            );
                          },
                        );
                    },
                    child: Center(
                      child: Text(
                        widget.arguments!['tipe'] == 'KREDIT' ? "PELUNASAN" : "TARIK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //if (widget.arguments!['tipe'] != 'KREDIT')
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 40,
            width: deviceWidth(context),
            decoration: BoxDecoration(
              color: (_btnHistoryStatus) ? accentColor : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_btnHistoryStatus) {
                    Map<String, dynamic> dataParse = {
                      'tipe': widget.arguments!['tipe'],
                      'groupProduk': widget.arguments!['tipe'],
                      'rekCd': widget.arguments!['rekCd'],
                      'norek': widget.arguments!['norek'],
                      'idProduk': produkProv.detailProdukCollection![0].tab_id,
                      'title': 'Mutasi Transaksi',
                    };
                    if (widget.arguments!['tipe'] == 'KREDIT')
                      Navigator.pushNamed(
                        context,
                        RouterGenerator.mutasiKredit,
                        arguments: dataParse,
                      );
                    else
                      Navigator.pushNamed(
                        context,
                        RouterGenerator.mutasiTransaksi,
                        arguments: dataParse,
                      );
                  }
                },
                child: Center(
                  child: Text(
                    "HISTORI TRANSAKSI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
