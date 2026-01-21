import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/config/config.dart';
import '../../../services/config/router_generator.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../constant/constant.dart';

class ListModel {
  String? title, navigator;
  IconData? icon;
  bool isDev;
  ListModel({this.title, this.navigator, this.icon, this.isDev = false});
}

class AkunScreen extends StatefulWidget {
  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  bool isVisible = false;
  ScrollController? scrollController;
  String? hp, wa;

  List<ListModel> dataListAkun = [
    ListModel(
      title: 'Ganti Password',
      navigator: RouterGenerator.resetPassword,
      // icon: FlutterIcons.lock_ant,
      icon: Iconsax.lock,
    ),
    ListModel(
      title: 'Ganti PIN',
      navigator: RouterGenerator.resetPin,
      // icon: FlutterIcons.dots_horizontal_mco,
      icon: Iconsax.more,
    ),
  ];

  List<ListModel> dataListBantuan = [
    ListModel(
      title: 'Petunjuk Penggunaan',
      navigator: RouterGenerator.kontakKami,
      // icon: FlutterIcons.ios_help_circle_outline_ion,
      icon: Iconsax.message_question,
      isDev: true,
    ),
    ListModel(
      title: 'Syarat dan ketentuan',
      navigator: RouterGenerator.kontakKami,
      // icon: FlutterIcons.file_check_outline_mco,
      icon: Iconsax.card_tick_1,
      isDev: true,
    ),
    ListModel(
        title: 'Kontak Kami',
        navigator: RouterGenerator.kontakKami,
        // icon: FlutterIcons.ios_call_ion,
        icon: Iconsax.call),
    ListModel(
        title: 'Tentang Aplikasi',
        navigator: RouterGenerator.about,
        // icon: FlutterIcons.ios_information_circle_outline_ion,
        icon: Iconsax.info_circle),
  ];

  _scrollListener() {
    if (scrollController!.offset >= 50) {
      setState(() {
        isVisible = true;
      });
    } else {
      setState(() {
        isVisible = false;
      });
    }
  }

  void logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool res = await DialogUtils.instance.showInfo(context: context, title: "Pemberitahuan!", text: "Apa Anda yakin ingin logout dari akun ini?") ?? false;

    if (res) {
      prefs.setBool('first_time_login', true);
      prefs.setString('nama', '');
      PersonName = 'User';

      Navigator.of(context).pushNamedAndRemoveUntil(RouterGenerator.pageHomeLogin, (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    scrollController!.addListener(_scrollListener);
    hp = dataLogin['hp'] ?? "-";
    wa = dataLogin['no_wa'] ?? "-";
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        appBarAkun(),
        headerAkun(),
        borderContent(height: 15, isSliver: true),
        contentAkun(),
      ],
    );
  }

  Widget appBarAkun() {
    return SliverAppBar(
      backgroundColor: isVisible ? accentColor : Colors.white,
      expandedHeight: 125,
      pinned: true,
      elevation: 2.0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isVisible ? companyName : "",
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        centerTitle: true,
        background: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 125,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_apps_splashscreen.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 50,
              child: Text(
                companyName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: (deviceWidth(context) / 2) - 25,
              bottom: 0,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: CircleAvatar(
                  backgroundColor: accentColor,
                  child: Container(
                    width: 25,
                    child: Image.asset("assets/icon/user.png"),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget headerAkun() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5),
            width: deviceWidth(context),
            child: Center(
              child: Container(
                width: deviceWidth(context) * 0.7,
                child: Text(
                  dataLogin['nama'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          iconValueHeader(
            // icon: FlutterIcons.ios_call_ion,
            icon: Iconsax.call,
            value: hp == null || hp == "" ? "-" : hp as String,
          ),
          SizedBox(height: 5),
          iconValueHeader(
            // icon: FlutterIcons.logo_whatsapp_ion,
            icon: BootstrapIcons.whatsapp,
            value: wa == null || wa == "" ? "-" : wa as String,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget iconValueHeader({IconData? icon, String? value}) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black38,
            size: 18,
          ),
          SizedBox(width: 5),
          Center(
            child: Text(
              value!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget contentAkun() {
    return SliverToBoxAdapter(
      child: ListView(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          titleContent(title: "Akun Saya"),
          listContentAkun(list: dataListAkun),
          borderContent(),
          titleContent(title: "Bantuan"),
          listContentAkun(list: dataListBantuan),
          borderContent(),
          listContentLogOut(),
        ],
      ),
    );
  }

  Widget titleContent({String? title}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 15),
      child: Text(
        title ?? "",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget listContentAkun({List<ListModel>? list}) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list!.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            if (list[index].isDev) {
              DialogUtils.instance.showError(
                context: context,
                text: "Layanan sedang dalam fase pengembangan!",
              );
            } else {
              Navigator.of(context).pushNamed(
                list[index].navigator!,
                arguments: {'title': list[index].title},
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(list[index].icon),
                ],
              ),
              title: Text(
                list[index].title!,
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
                    Iconsax.arrow_right,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget listContentLogOut() {
    return GestureDetector(
      onTap: logOut,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                  // FlutterIcons.logout_ant,
                  Iconsax.logout,
                  color: Colors.blue.shade400),
            ],
          ),
          title: Text(
            'Log Out',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget borderContent({double height = 10, bool isSliver = false}) {
    return isSliver
        ? SliverToBoxAdapter(
            child: Container(
              height: height,
              color: Colors.grey.shade100,
            ),
          )
        : Container(
            height: height,
            color: Colors.grey.shade100,
          );
  }
}
