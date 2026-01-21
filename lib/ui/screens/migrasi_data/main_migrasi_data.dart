import 'package:intl/intl.dart';
import 'package:sevanam_mobkol/services/viewmodel/global_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../../services/utils/dialog_utils.dart';
import '../../../ui/widgets/datetime_periode.dart';
import '../../../ui/constant/constant.dart';
import '../../../ui/widgets/app_bar.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/utils/text_utils.dart';
import '../../widgets/loader/lottie_loader.dart';
import '../../../services/config/config.dart' as config;

class MainMigrasiData extends StatefulWidget {
  MainMigrasiData({Key? key}) : super(key: key);

  @override
  _MainMigrasiData createState() => _MainMigrasiData();
}

class _MainMigrasiData extends State<MainMigrasiData> {
  ProdukCollectionProvider? produkProv;
  GlobalProvider? globalProv;
  final format = DateFormat("dd-MM-yyyy");
  DateTime _tglAwal = DateTime.parse(DateTime.now().year.toString() + (DateTime.now().month < 10 ? "-0" : "-") + DateTime.now().month.toString() + "-01");
  DateTime _tglAkhir = DateTime.now();
  String? tglAwalParse, tglAkhirParse;

  var masterDataListMigrasi = [
    {'title': 'Master Nasabah', 'desc': 'Migrasi data master nasabah', 'icon': 'icons8-nas_migrate.png', 'rekCd': 'MASTER_NASABAH', 'groupProduk': 'MASTER_NASABAH', 'color': '0xff1967d2', 'color2': '0xff03d0ea', 'isDev': false, 'isMaster': true},
    {'title': 'Data Akun', 'desc': 'Migrasi data akun kolektor', 'icon': 'icons8-user-100.png', 'rekCd': 'DATA_AKUN', 'groupProduk': 'DATA_AKUN', 'color': '0xff1967d2', 'color2': '0xff03d0ea', 'isDev': false, 'isMaster': true},
    {'title': 'Data Config', 'desc': 'Migrasi data config', 'icon': 'icons8_migrate.png', 'rekCd': 'CONFIG', 'groupProduk': 'CONFIG', 'color': '0xff1967d2', 'color2': '0xff03d0ea', 'isDev': false, 'isMaster': true},
  ];

  var dataListMigrasi = [];

  @override
  void initState() {
    super.initState();
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    produkProv!.setTglAwal(_tglAwal);
    produkProv!.setTglAkhir(_tglAkhir);

    setMenuCollection(false);
  }

  void setMenuCollection(bool isRefresh) async {
    if (isRefresh) {
      produkProv!.dataProdukMigrasi(context);
    }

    dataListMigrasi = [...masterDataListMigrasi];
    if (produkProv!.produkCollectionMigrasi != null) {
      for (var product in produkProv!.produkCollectionMigrasi!) {
        dataListMigrasi.add({'title': TextUtils().capitalizeEachWord(product.nama!), 'desc': "Migrasi data ${TextUtils().capitalizeEachWord(product.nama!)}", 'icon': product.icon, 'rekCd': product.rekCd, 'groupProduk': product.slug, 'color': '0xff1967d2', 'color2': '0xff03d0ea', 'isDev': false, 'isMaster': false});
      }
    }
  }

  void refreshMenuCollection() async {
    produkProv!.refreshProdukCollectionMigrasi();
    setMenuCollection(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(context, 'Migrasi Data', isRefresh: true, onRefresh: () => refreshMenuCollection()),
      body: Consumer<ProdukCollectionProvider>(
        builder: (context, mutasiProdukProvider, _) {
          if (produkProv!.produkCollectionMigrasi == null) {
            // produkProv.dataProduk(context);
            setMenuCollection(true);
            return LottiePrimaryLoader();
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: deviceWidth(context),
            height: deviceHeight(context),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: getDatePeriode(context),
                ),
                SizedBox(height: 15),
                Divider(),
                _listDaftarMigrasiData(dataListMigrasi),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _listDaftarMigrasiData(var mutasiProdukProvider) {
    print(DateTime.now());
    return Expanded(
      child: Container(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: dataListMigrasi.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                if (dataListMigrasi[index]['isDev']) {
                  DialogUtils.instance.showError(
                    context: context,
                    text: "Layanan sedang dalam fase pengembangan!",
                  );
                } else {
                  produkProv!.getDataMigrasi(
                    context: context,
                    rekCd: dataListMigrasi[index]['rekCd'],
                    groupProduk: dataListMigrasi[index]['groupProduk'],
                    descMigrasi: dataListMigrasi[index]['desc'],
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(dataListMigrasi[index]['color'])),
                        Color(int.parse(dataListMigrasi[index]['color2'])),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: globalProv!.getConnectionMode == config.onlineMode && !dataListMigrasi[index]['isMaster']
                        ? Image.network(
                            config.ConfigURL().iconLink + dataListMigrasi[index]['icon'],
                          )
                        : Image.asset('assets/icon/' + dataListMigrasi[index]['icon']),
                    title: Text(
                      dataListMigrasi[index]['title'],
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      dataListMigrasi[index]['desc'],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget _getDatePeriodeMigrasi(ProdukCollectionProvider mutasiProdukProvider) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 0),
  //     margin: EdgeInsets.only(top: 10),
  //     child: Consumer<ProdukCollectionProvider>(
  //       builder: (context, mutasiProdukProvider, _) {
  //         return Row(
  //           children: <Widget>[
  //             Expanded(
  //               child: DateTimeField(
  //                 format: format,
  //                 onShowPicker: (context, currentValue) {
  //                   return showDatePicker(
  //                     context: context,
  //                     firstDate: DateTime(1900),
  //                     initialDate: DateTime.now(),
  //                     lastDate: DateTime(3100),
  //                     locale: const Locale('id', 'ID'),
  //                   );
  //                 },
  //                 initialValue: mutasiProdukProvider.tglAwal,
  //                 decoration: InputDecoration(
  //                   suffixIcon: Icon(Icons.calendar_today),
  //                 ),
  //                 textAlign: TextAlign.center,
  //                 onChanged: (currentValue) {
  //                   mutasiProdukProvider.setTglAwal(currentValue, true);
  //                   if (mutasiProdukProvider.tglAwal
  //                           .difference(mutasiProdukProvider.tglAkhir)
  //                           .inDays <
  //                       1) {
  //                     mutasiProdukProvider.setMutasiLoading(true, true);
  //                   }
  //                 },
  //               ),
  //             ),
  //             Container(
  //               margin: EdgeInsets.symmetric(horizontal: 10),
  //               child: Icon(
  //                 Icons.arrow_forward,
  //                 size: 30,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             Expanded(
  //               child: DateTimeField(
  //                 format: format,
  //                 onShowPicker: (context, currentValue) {
  //                   return showDatePicker(
  //                     context: context,
  //                     firstDate: DateTime(1900),
  //                     initialDate: DateTime.now(),
  //                     lastDate: DateTime(3100),
  //                     locale: const Locale('id', 'ID'),
  //                   );
  //                 },
  //                 initialValue: mutasiProdukProvider.tglAkhir,
  //                 decoration: InputDecoration(
  //                   suffixIcon: Icon(Icons.calendar_today),
  //                 ),
  //                 textAlign: TextAlign.center,
  //                 onChanged: (currentValue) {
  //                   mutasiProdukProvider.setTglAkhir(currentValue, true);
  //                   if (mutasiProdukProvider.tglAkhir
  //                           .difference(mutasiProdukProvider.tglAwal)
  //                           .inDays >
  //                       0) {
  //                     mutasiProdukProvider.setMutasiLoading(true, true);
  //                   }
  //                 },
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
}
