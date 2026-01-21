import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sevanam_mobkol/services/utils/date_time_extensions.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:provider/provider.dart';
import 'package:countup/countup.dart';

import '../../../services/config/config.dart' as config;
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/widgets/datetime_periode.dart';
import '../../../ui/widgets/floating_action_button.dart';
import '../../../ui/widgets/loader/lottie_loader.dart';
import '../../../ui/widgets/slide/slide_list_produk.dart';
import '../../../ui/widgets/text_list/field_list_histori_transaksi.dart';
import '../../../database/databaseHelper.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/viewmodel/transaksi_provider.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/not_found.dart';

class MainKlad extends StatefulWidget {
  @override
  _MainKlad createState() => _MainKlad();
}

class _MainKlad extends State<MainKlad> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  ProdukCollectionProvider? produkProvider;
  GlobalProvider? globalProv;
  TransaksiProvider? transProvider;
  var searchController = TextEditingController();
  double? _width, _primaryPadding = 15;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? produkScrollCOntroller;
  final dbHelper = DatabaseHelper.instance;

  DateTime _tglAwal = DateTime.now();
  DateTime _tglAkhir = DateTime.now();

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    transProvider = Provider.of<TransaksiProvider>(context, listen: false);
    globalProv!.loadLocation(context);
    produkProvider!.resetMutasiTransaksi(isListen: false);
    produkProvider!.setTglAwal(_tglAwal);
    produkProvider!.setTglAkhir(_tglAkhir);
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Consumer3<ProdukCollectionProvider, GlobalProvider, TransaksiProvider>(
      builder: (contex, produkProv, globalProvider, trxProv, _) {
        if (produkProv.produkCollection == null) {
          produkProv.dataProduk(context);
          return LottiePrimaryLoader();
        }
        if (trxProv.isLoadingUpload == true) {
          return LottieUploadLoader();
        }

        return Scaffold(
          floatingActionButton: globalProvider.getConnectionMode == config.offlineMode
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _floatingActionUploadTrx(contex),
                    ),
                    floatingActionSwitchMode(context, isKlad: true)
                  ],
                )
              : floatingActionSwitchMode(context, isKlad: true),
          appBar: DefaultAppBar(
            context,
            "Klad " + (produkProv.getSelectedProdukName ?? ' - ').toLowerCase(),
            isCenter: true,
            isRefresh: true,
            onRefresh: () => produkProvider!.refreshAllMenuKlad(),
          ),
          key: scaffoldKey,
          body: Container(
            width: _width,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _primaryPadding!),
                    child: getDatePeriode(contex, isKlad: true),
                  ),
                  SizedBox(height: 5),
                  Divider(),
                  SizedBox(height: 10),
                  scrollTag(context),
                  Divider(),
                  SizedBox(height: 10),
                  if (produkProv.getSelectedgroupProdukProduk != null && produkProv.muatasiProdukCollection != null) _cardInfoTotalTrans(produkProv),
                  //SizedBox(height: 10),
                  // _searchForm(),
                  SizedBox(height: 10),
                  _dataKlad(),
                  SizedBox(height: 90),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _floatingActionUploadTrx(BuildContext context) {
    //trxProv = Provider.of<TransaksiProvider>(context, listen: false);
    return Consumer2<GlobalProvider, ProdukCollectionProvider>(
      builder: (context, globalProvider, produkProv, _) {
        return new FloatingActionButton(
          onPressed: () async {
            bool _confirm = await DialogUtils.instance.dialogConfirm(
              context,
              "Ingin mengupload seluruh data transaksi " + (produkProv.getSelectedProdukName ?? ' - ').toLowerCase() + "?",
            );
            if (_confirm) startService();
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

  Future startService() async {
    transProvider!.multileUploadTrxOffline(context);
  }

  Widget _cardInfoTotalTrans(ProdukCollectionProvider produkProv) {
    String tipe = produkProvider!.getSelectedgroupProdukProduk!;
    dynamic mutasiData = produkProvider!.muatasiProdukCollection;
    double _totSaldo = 0, _totalTrx = 0;
    int _countSetoran = 0, _countTarikan = 0;

    _totSaldo = double.parse(mutasiData![0].totSetoran!) - double.parse(mutasiData[0].totTarikan!);
    _totalTrx = double.parse(mutasiData[0].totSetoran!) + double.parse(mutasiData[0].totTarikan!);
    _countSetoran = mutasiData.where((element) => element.dbcr == 'CR').length ?? 0;
    _countTarikan = mutasiData.where((element) => element.dbcr == 'DB').length ?? 0;

    int _countTotal = mutasiData != null ? mutasiData.where((element) => element.status != 'Gagal').length : 0;
    return TicketWidget(
      width: MediaQuery.of(context).size.width, //test
      height: MediaQuery.of(context).size.height * 0.35, //test
      isCornerRounded: false,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, primaryColor],
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black87.withOpacity(.3),
              offset: Offset(0.0, 5.0),
              blurRadius: 8.0,
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Summary transaksi " + (produkProv.getSelectedProdukName ?? ' - ').toLowerCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          // FlutterIcons.calendar_alt_faw5,
                          Iconsax.calendar,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          DateTime.now().format("dd MMMM yyyy"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              (globalProv!.getConnectionMode == config.onlineMode)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _cardValSummary(
                            valSummary: mutasiData != null
                                ? tipe == 'KREDIT'
                                    ? mutasiData[0].totPokok!
                                    : mutasiData[0].totSetoran!
                                : '0',
                            tittle: tipe == 'KREDIT' ? 'Pokok' : 'Setoran',
                            // icon: FlutterIcons.arrow_circle_o_down_faw,
                            icon: Iconsax.arrow_circle_down,
                            iCcolor: primaryColor,
                            isCount: tipe == 'KREDIT' ? false : true,
                            countVal: _countSetoran.toString()),
                        SizedBox(width: 20),
                        _cardValSummary(
                            valSummary: mutasiData != null
                                ? tipe == 'KREDIT'
                                    ? mutasiData[0].totBunga!
                                    : mutasiData[0].totTarikan!
                                : '0',
                            tittle: tipe == 'KREDIT' ? 'Bunga' : 'Tarikan',
                            // icon: FlutterIcons.arrow_circle_o_up_faw,
                            icon: Iconsax.arrow_circle_up,
                            iCcolor: primaryColor,
                            isCount: tipe == 'KREDIT' ? false : true,
                            countVal: _countTarikan.toString()),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _cardValSummary(
                          valSummary: mutasiData != null ? mutasiData.where((element) => element.isUpload == 'Y').length.toString() : '0',
                          tittle: 'Ter-Upload',
                          // icon: FlutterIcons.upload_cloud_fea,
                          icon: Iconsax.document_cloud,
                          iCcolor: Colors.green,
                          isCount: false,
                        ),
                        SizedBox(width: 20),
                        _cardValSummary(
                          valSummary: mutasiData != null ? mutasiData.where((element) => element.isUpload == 'N').length.toString() : '0',
                          tittle: 'Belum Ter-Upload',
                          // icon: FlutterIcons.upload_cloud_fea,
                          icon: Iconsax.document_cloud,
                          iCcolor: Colors.red,
                          isCount: false,
                        ),
                      ],
                    ),
              SizedBox(height: 10),
              (globalProv!.getConnectionMode == config.onlineMode)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        tipe == 'KREDIT'
                            ? _cardValSummary(
                                valSummary: mutasiData != null ? mutasiData[0].totDenda! : '0',
                                tittle: 'Denda',
                                // icon: FlutterIcons.arrow_circle_o_down_faw,
                                icon: Iconsax.arrow_circle_down,
                                iCcolor: primaryColor,
                                isCount: false)
                            : _cardValSummary(
                                valSummary: _totalTrx.toString(),
                                tittle: 'Total',
                                // icon: FlutterIcons.chart_bar_faw5s,
                                icon: Iconsax.chart_1,
                                iCcolor: primaryColor,
                                countVal: _countTotal.toString(),
                              ),
                        SizedBox(width: 20),
                        _cardValSummary(
                          valSummary: _totSaldo.toString(),
                          tittle: 'Saldo',
                          // icon: FlutterIcons.coins_mco,
                          icon: Iconsax.arrange_circle,
                          iCcolor: primaryColor,
                          isCount: tipe == 'KREDIT' ? true : false,
                          countVal: _countTotal.toString(),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _cardValSummary(
                          valSummary: _countTotal.toString(),
                          tittle: 'Total',
                          // icon: FlutterIcons.chart_bar_faw5s,
                          icon: Iconsax.chart_1,
                          iCcolor: Colors.blue,
                          isCurrency: false,
                          isSilngleCard: true,
                          isCount: false,
                        ),
                      ],
                    ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardValSummary({
    String? valSummary,
    String? tittle,
    IconData? icon,
    Color? iCcolor,
    bool isCurrency = true,
    bool isSilngleCard = false,
    bool isCount = true,
    String countVal = '0',
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      width: isSilngleCard ? deviceWidth(context) / 1.2 : deviceWidth(context) / 2.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Countup(
            begin: 0,
            end: double.parse(valSummary!),
            duration: Duration(seconds: 1),
            separator: isCurrency ? '.' : '',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(icon, size: 20, color: iCcolor),
              //SizedBox(width: 5),
              Text(
                tittle!,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          (isCount)
              ? badges.Badge(
                  child: Container(
                      decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    color: primaryColor,
                  )),
                  // toAnimate: true,
                  // shape: BadgeShape.square,
                  // color: primaryColor,
                  // borderRadius: BorderRadius.circular(8),
                  badgeContent: Text(countVal, style: TextStyle(color: Colors.white)),
                )
              : Container(
                  height: 0,
                ),
        ],
      ),
    );
  }

  Widget _dataKlad() {
    return Container(
      width: deviceWidth(context),
      child: Consumer2<ProdukCollectionProvider, TransaksiProvider>(
        builder: (context, produkProv, trxProv, _) {
          if (produkProv.muatasiProdukCollection == null) {
            produkProv.getDataKlad(context);
            return Center(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (produkProv.muatasiProdukCollection![0].status == 'Gagal') {
            return Center(
              child: Column(
                children: [
                  DataNotFound(
                    pesan: produkProv.muatasiProdukCollection![0].pesan,
                  ),
                  SizedBox(height: 10),
                  refreshDataKlad(),
                ],
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: produkProv.muatasiProdukCollection == null ? 0 : produkProv.muatasiProdukCollection!.length,
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              var dataTrans = produkProv.muatasiProdukCollection![index];
              return FieldListKlad(dataTrans: dataTrans);
            },
          );
        },
      ),
    );
  }

  Widget scrollTag(BuildContext context) {
    return Consumer<ProdukCollectionProvider>(
      builder: (context, produkProvider, _) {
        if (produkProvider.produkCollection == null) {
          produkProvider.dataProduk(context);
          return LottiePrimaryLoader();
        }
        return Container(
          height: 90,
          margin: EdgeInsets.only(left: 10),
          child: ListView.builder(
            itemCount: produkProvider.produkCollection!.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            controller: produkScrollCOntroller,
            itemBuilder: (BuildContext context, int i) {
              var dataProduk = produkProvider.produkCollection![i];
              return SlideListProduk(dataProduk: dataProduk, isKlad: true);
            },
          ),
        );
      },
    );
  }

  Widget refreshDataKlad() {
    return Container(
      width: 200,
      height: 40,
      margin: EdgeInsets.only(left: _primaryPadding!, right: _primaryPadding!),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => produkProvider!.resetMutasiTransaksi(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Refresh",
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                  // FlutterIcons.refresh_faw,
                  Iconsax.refresh,
                  color: accentColor)
            ],
          ),
        ),
      ),
    );
  }
}
