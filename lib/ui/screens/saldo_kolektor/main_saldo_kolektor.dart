import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/widgets/loader/lottie_loader.dart';
import '../../widgets/floating_action_button.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';

class MainSaldoKolektor extends StatefulWidget {
  @override
  _MainSaldoKolektor createState() => _MainSaldoKolektor();
}

class _MainSaldoKolektor extends State<MainSaldoKolektor> {
  ProdukCollectionProvider? produkProvider;
  GlobalProvider? globalProvider;
  var searchController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? produkScrollCOntroller;

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    //produkProvider!.refreshSaldoKolektor();
    initData();
  }

  void initData() async {
    await produkProvider!.getDataSaldoKolektor(context);
    await produkProvider!.getDataSaldoKolektorMenu(context);
  }

  void _refresh() {
    produkProvider!.refreshSaldoKolektor();
    produkProvider!.refreshSaldoKolektorMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionSwitchMode(context),
      appBar: DefaultAppBar(
        context,
        "Saldo Kolektor",
        isCenter: true,
        isRefresh: true,
        onRefresh: _refresh,
      ),
      key: scaffoldKey,
      body: Consumer<ProdukCollectionProvider>(
        builder: (contex, produkProv, _) {
          if (produkProv.saldoKolektorMenu == null) {
            if (produkProv.saldoKolektorCollection == null) produkProv.getDataSaldoKolektor(context);
            if (produkProv.saldoKolektorMenu == null) produkProv.getDataSaldoKolektorMenu(context);
            return LottiePrimaryLoader();
          }
          return Container(
            width: deviceWidth(context),
            height: deviceHeight(context),
            color: Colors.grey.shade200,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  if (produkProv.saldoKolektorCollection != null) _ticketViewSaldokol(produkProv.saldoKolektorCollection![0]),
                  SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ticketViewSaldokol(dynamic produkProv) {
    return Container(
      margin: EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TicketWidget(
            width: 350, //test
            height: 850, //test
            isCornerRounded: true,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 12.0),
                    child: Row(
                      children: [
                        Image.asset('assets/icon/rp.png', width: 40, height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Saldo Kolektor',
                          style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Column(
                      children: <Widget>[
                        Column(
                          children: [
                            // if (globalProvider!.getConnectionMode == onlineMode) _dynamicData(data: produkProvider!.saldoKolektorMenu),
                            _dynamicData(data: produkProvider!.saldoKolektorMenu),
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dynamicData({var data}) {
    return Column(
      children: data.asMap().entries.map<Widget>((entry) {
        int index = entry.key;
        var item = entry.value;
        return Column(
          children: [
            _fieldTicketViewProduk(
              isHeader: true,
              headerTxt: item.title,
            ),
            Column(
              children: item.data
                  .map<Widget>((dt) => _fieldTicketViewProduk(
                        firstField: dt['subtitle'],
                        secondField: dt['value'].toString(),
                        isCurrency: true,
                      ))
                  .toList(),
            ),
            if (index != data.length - 1) Divider(),
          ],
        );
      }).toList(),
    );
  }

  Widget _fieldTicketViewProduk({
    bool isHeader = false,
    String headerTxt = '-',
    String firstField = '-',
    String? secondField = '0',
    bool isCurrency = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isHeader)
                Text(
                  headerTxt,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              if (!isHeader)
                Row(
                  children: [
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        firstField,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (!isHeader)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    (isCurrency) ? TextUtils.instance.numberFormat(secondField?.toString() ?? "0") : secondField.toString(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget dashDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Dash(
        direction: Axis.horizontal,
        length: 340,
        dashLength: 12,
        dashColor: Colors.grey.shade400,
      ),
    );
  }
}
