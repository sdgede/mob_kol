import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../services/utils/icons_utils.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/config/config.dart' as config;
import '../../../services/config/router_generator.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/constant/constant.dart';

class HomeKolektor extends StatefulWidget {
  @override
  HomeKolektorState createState() => HomeKolektorState();
}

class HomeKolektorState extends State<HomeKolektor> {
  GlobalProvider? globalProv;
  ProdukCollectionProvider? produkProv;
  List? dataMenuKolektor, dataSetting;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _setting = GlobalKey();

  void logOut() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    bool res = await DialogUtils.instance.showInfo(
          context: context,
          title: "Pemberitahuan!",
          text: "Apa Anda yakin ingin logout dari akun ini?",
        ) ??
        false;

    if (res) {
      produkProv!.resetSelectedgroupProdukProduk();
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouterGenerator.pageLogin, (Route<dynamic> route) => false);
    }
  }

  _initPathImgInvoice() async {
    final filename = headerInvoiceImgName;
    var bytes = await rootBundle.load(icHeaderInvoice);
    String dir = (await getApplicationDocumentsDirectory()).path;
    _writeToFile(bytes, '$dir/$filename');

    globalProv!.setInvoiceImage('$dir/$filename');
  }

  Future<void> _writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  _checkAccountMigration(BuildContext context) async {
    bool checkSync = await globalProv!.isNeedSync();
    bool isOnline = globalProv!.getConnectionMode == config.onlineMode;
    if (checkSync && isOnline) {
      await DialogUtils.instance.showInfo(
          context: context,
          isCancel: true,
          title: 'Sinkronasi data',
          text:
              'Perbaharui migrasi data untuk menyimpan perubahan sebelumnya. Proses ini memerlukan beberapa waktu.',
          clickCancelText: "Nanti",
          clickOKText: "Perbaharui",
          onClickOK: () async {
            Navigator.of(context).pop();
            await globalProv!
                .syncData(context, produkProv!.produkCollectionMigrasi);
          });
    }
    return;
  }

  _showShowcase(context) {
    ShowCaseWidget.of(context).startShowCase([
      ...dataMenuKolektor!.map((item) => item.key).toList(),
      _setting,
      ...dataSetting!.map((item) => item.key).toList(),
    ]);
  }

  _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('first_time') == null
        ? true
        : prefs.getBool('first_time')!;

    // cek migrasi
    if (globalProv!.getConnectionMode == config.onlineMode && !firstTime) {
      globalProv!.syncAcount();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAccountMigration(context);
      });
    }

    // check showcase
    if (firstTime) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _showShowcase(context);
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    dataSetting = IconUtils.instance.dataSetting();
    dataMenuKolektor = IconUtils.instance.dataMenuKolektor();
    produkProv!.setAllDatafirstSelectedProduct(
      context: context,
      isListen: false,
    );
    globalProv!.loadLocation(context);
    _initPathImgInvoice();

    _checkFirstTime();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      produkProv!.setAllDatafirstSelectedProduct(isListen: false);
    }
  }

  Future<bool> _onBackPressed() async {
    return (await DialogUtils.instance.onBackPressedHome(context, true));
  }

  Widget build(BuildContext context) {
    var h = deviceHeight(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showShowcase(context);
          },
          child: Icon(Icons.help),
          backgroundColor: accentColor,
        ),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: deviceHeight(context) * 0.34,
                  floating: false,
                  pinned: true,
                  titleSpacing: 0,
                  backgroundColor:
                      innerBoxIsScrolled ? primaryColor : accentColor,
                  actionsIconTheme: IconThemeData(opacity: 0.0),
                  title: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Text(
                            '',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentColor, primaryColor],
                              ),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0)),
                            ),
                          ),
                          ListView(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: (h * 0.12)),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Image.asset(
                                        'assets/icon/icons8-user-100.png',
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      config.dataLogin['nama'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'KOLEKTOR',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: primaryColor,
                      indicatorColor: primaryColor,
                      unselectedLabelColor: Colors.black87,
                      tabs: [
                        Tab(text: 'Home'),
                        Showcase(
                            key: _setting,
                            description: "Klik untuk ke menu setting",
                            child: Tab(text: 'Setting')),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                listMenuHome(list: dataMenuKolektor!, typeMenu: 'menu_home'),
                listMenuHome(list: dataSetting!, typeMenu: 'menu_setting'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listMenuHome({List? list, String? typeMenu}) {
    return Column(
      children: [
        Container(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: list!.length,
            itemBuilder: (BuildContext context, int index) {
              return Showcase(
                key: list[index].key,
                description: list[index].description,
                child: GestureDetector(
                  onTap: () {
                    if (list[index].isDev) {
                      DialogUtils.instance.showError(
                        context: context,
                        text: "Layanan sedang dalam fase pengembangan!",
                      );
                    } else {
                      if (list[index].type == 'LOGOUT') {
                        logOut();
                      } else {
                        Navigator.of(context).pushNamed(
                          list[index].navigator,
                          arguments: {'title': list[index].title},
                        );
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                badges.Badge(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade400
                                              .withOpacity(.3),
                                          offset: Offset(0.0, 3.0),
                                          blurRadius: 8.0,
                                        )
                                      ],
                                    ),
                                    width: 45,
                                    height: 45,
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset(
                                      list[index].icon,
                                    ),
                                  ),
                                  // toAnimate: true,
                                  showBadge: globalProv!.getConnectionMode ==
                                              config.onlineMode &&
                                          list[index].type == "DATA_PENAGIHAN"
                                      ? true
                                      : false,
                                  badgeContent: Text(
                                    config.dataSetting[
                                                'total_kredit_jatuhtempo']
                                            ?.toString() ??
                                        "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              list[index].title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  // FlutterIcons.ios_arrow_forward_ion,
                                  Iconsax.arrow_right_3,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget borderContent({double height = 10, bool isSliver = false}) {
  //   return isSliver
  //       ? SliverToBoxAdapter(
  //           child: Container(
  //             height: height,
  //             color: Colors.grey.shade100,
  //           ),
  //         )
  //       : Container(
  //           height: height,
  //           color: Colors.grey.shade100,
  //         );
  // }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(.3),
              offset: Offset(0.0, 8.0),
              blurRadius: 8.0,
            )
          ],
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
