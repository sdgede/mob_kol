import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sevanam_mobkol/model/model_datatable.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';
import 'package:sevanam_mobkol/services/collection/produk_collection.dart';
import 'package:sevanam_mobkol/services/utils/text_utils.dart';
import 'package:sevanam_mobkol/services/viewmodel/produk_provider.dart';
import 'package:sevanam_mobkol/ui/constant/constant.dart';
import 'package:sevanam_mobkol/ui/screens/printer/main_setting_printer.dart';
import 'package:sevanam_mobkol/ui/widgets/app_bar.dart';
import 'package:sevanam_mobkol/ui/widgets/datetime_periode.dart';
import 'package:sevanam_mobkol/ui/widgets/loader/bottom_loading.dart';
import 'package:sevanam_mobkol/ui/widgets/not_found.dart';
import 'package:sevanam_mobkol/ui/widgets/produk/produk_util_widget.dart';

class MutasiTransaksi extends StatefulWidget {
  final Map? arguments;
  const MutasiTransaksi({Key? key, this.arguments}) : super(key: key);

  @override
  _MutasiTransaksi createState() => _MutasiTransaksi();
}

class _MutasiTransaksi extends State<MutasiTransaksi>
    with SingleTickerProviderStateMixin {
  final bool _showFilterDate = false;

  final scaffoldKey = GlobalKey<ScaffoldState>(),
      _formKeyStep1 = GlobalKey<FormState>();
  String? _idProduk, _rekCd, _groupProduk;
  ProdukCollectionProvider? produkProvider;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  final _scrollController = ScrollController();
  ModelDatatable _datatable =
      ModelDatatable(total: 0, limit: 0, page: 0, totalPage: 0, data: []);
  bool _isLoading = false;

  Future<void> refreshPage(
    int page,
  ) async {
    setState(() => _isLoading = true);
    var responseDatatable = await ProdukCollectionServices().getDataMutasiV2(
      context,
      page: page,
      limit: 5,
      idProduk: _idProduk,
      rekCd: _rekCd,
      groupProduk: _groupProduk,
      norek: "0",
      startDate: _showFilterDate ? _startDate : null,
      endDate: _showFilterDate ? _endDate : null,
    );
    setState(() {
      _datatable =
          _datatable.addReplaceData(responseDatatable, isReset: page <= 1);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _idProduk = widget.arguments!['idProduk'];
    _rekCd = widget.arguments!['rekCd'];
    _groupProduk = widget.arguments!['groupProduk'];

    produkProvider =
        Provider.of<ProdukCollectionProvider>(context, listen: false);
    produkProvider!.setTglAwal(
        DateTime(DateTime.now().year, DateTime.now().month, 1), true);
    produkProvider!.setTglAkhir(DateTime.now(), true);

    refreshPage(1);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        refreshPage(_datatable.page + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(
        context,
        widget.arguments!['title'],
        isRefresh: true,
        onRefresh: () {
          if (!_isLoading) refreshPage(1);
        },
        elevation: 0,
        bottom: _showFilterDate
            ? PreferredSize(
                preferredSize: Size.fromHeight(83),
                child: getDatePeriode(
                  context,
                  margin: EdgeInsets.zero,
                  padding:
                      EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 15),
                  color: Colors.white,
                  fnChangeStart: (date) {
                    setState(() {
                      _startDate = date;
                      refreshPage(1);
                    });
                  },
                  fnChangeEnd: (date) {
                    setState(() {
                      _endDate = date;
                      refreshPage(1);
                    });
                  },
                ),
              )
            : null,
      ),
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          height: deviceHeight(context),
          width: deviceWidth(context),
          child: Form(
            key: _formKeyStep1,
            autovalidateMode: AutovalidateMode.disabled,
            child: ListView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              children: [
                ..._uiContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _uiContent() {
    uiCard(MutasiProdukCollection row) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: dataNasabah(
          row.kode!,
          row.tgl!,
          row.jumlah!,
          row.saldo!,
          row.remark!,
          row.op!,
          row.saldo_awal!,
          row.dbcr!,
          row,
        ),
      );
    }

    List<Widget> result = [];

    if (_datatable.isEmpty()) {
      return [
        Center(
          child: DataNotFound(
            pesan: "Belum ada data untuk ditampilkan",
          ),
        ),
      ];
    } else {
      for (var element in _datatable.data) {
        result.add(uiCard(element));
      }
    }

    result.add(BottomLoading(isFinish: !_isLoading));

    return result;
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
              isNumber
                  ? TextUtils.instance.numberFormat(value ?? "0")
                  : (value ?? ""),
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
