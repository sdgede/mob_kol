import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/config/config.dart' as config;
import '../constant/constant.dart';

// ignore: non_constant_identifier_names
Widget AppBarLogo() {
  return new AppBar(
    backgroundColor: accentColor,
    title: Container(
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              config.companyName,
              style: GoogleFonts.ubuntu(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              )),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
AppBar DefaultAppBar(
  BuildContext context,
  String title, {
  bool isRefresh = false,
  Function? onRefresh,
  bool isCenter = false,
  Function? onBack,
  bool isBack = true,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
  double? elevation,
}) {
  return new AppBar(
    backgroundColor: accentColor,
    elevation: elevation,
    leading: isBack
        ? IconButton(
            icon: new Icon(
              // FlutterIcons.ios_arrow_back_ion,\
              Iconsax.arrow_left,
              color: Colors.white,
            ),
            onPressed: () => onBack != null ? onBack() : Navigator.pop(context),
          )
        : null,
    actions: actions != null
        ? actions
        : isRefresh
            ? [
                IconButton(
                  icon: new Icon(
                    // FlutterIcons.ios_refresh_ion,
                    Iconsax.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () => onRefresh != null ? onRefresh() : {},
                )
              ]
            : null,
    title: Text(
      title,
      style: GoogleFonts.ubuntu(
          textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
      )),
    ),
    centerTitle: isCenter,
    bottom: bottom,
  );
}

// ignore: non_constant_identifier_names
Widget CloseAppBar(BuildContext context, String title, [bool isCenter = false]) {
  return new AppBar(
    backgroundColor: accentColor,
    leading: IconButton(
      icon: new Icon(
        Icons.close,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: isCenter
        ? Center(
            child: Container(
              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 6),
              child: Text(
                title,
                style: GoogleFonts.ubuntu(
                    textStyle: TextStyle(
                  fontSize: 16,
                )),
              ),
            ),
          )
        : Text(
            title,
            style: GoogleFonts.ubuntu(
                textStyle: TextStyle(
              fontSize: 16,
            )),
          ),
  );
}

// ignore: non_constant_identifier_names
Widget DefaultAppBarWithoutShadow(BuildContext context, String title) {
  return new AppBar(
    backgroundColor: accentColor,
    leading: IconButton(
      icon: new Icon(
        // FlutterIcons.ios_arrow_back_ion,
        Iconsax.arrow_left,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: Text(
      title,
      style: GoogleFonts.ubuntu(
          textStyle: TextStyle(
        fontSize: 16,
      )),
    ),
    elevation: 0.0,
  );
}

// ignore: non_constant_identifier_names
Widget DefaultAppBarDaftarOnline({
  BuildContext? context,
  String? title,
  bool isIcon = true,
  bool isExit = true,
  Function? onClick,
}) {
  return new AppBar(
    backgroundColor: accentColor,
    leading: isIcon
        ? IconButton(
            icon: new Icon(
              isExit
                  // ? FlutterIcons.md_exit_ion
                  ? Iconsax.logout
                  // : FlutterIcons.ios_arrow_back_ion,
                  : Iconsax.arrow_left,
              color: Colors.white,
            ),
            onPressed: onClick != null ? () => onClick() : null,
          )
        : IconButton(icon: Icon(null), onPressed: null),
    title: Center(
      child: Container(
        margin: EdgeInsets.only(right: MediaQuery.of(context!).size.width / 6),
        child: Text(
          title!,
          style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget AppBarDaftarTersimpan({
  BuildContext? context,
  String? title,
  TabController? tabController,
}) {
  return AppBar(
    backgroundColor: accentColor,
    leading: IconButton(
      icon: Icon(
        // FlutterIcons.ios_arrow_back_ion,
        Iconsax.arrow_left,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context!);
      },
    ),
    title: Text(
      title!,
      style: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          fontSize: 16,
        ),
      ),
    ),
    bottom: TabBar(
      unselectedLabelColor: Colors.white,
      labelColor: Colors.white,
      controller: tabController,
      indicatorColor: Colors.amber,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 15),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: [
        Tab(
          child: Container(
            color: Colors.transparent,
            child: Text("Masukkan Baru", style: GoogleFonts.ubuntu()),
          ),
        ),
        Tab(
          child: Container(
            color: Colors.transparent,
            child: Text("Daftar Tersimpan", style: GoogleFonts.ubuntu()),
          ),
        ),
      ],
    ),
    bottomOpacity: 1,
  );
}

// ignore: non_constant_identifier_names
Widget AppBarTransparent(BuildContext context, {Color? colors}) {
  return AppBar(
    backgroundColor: colors ?? Colors.transparent,
    leading: IconButton(
      icon: new Icon(
        // FlutterIcons.ios_arrow_back_ion,
        Iconsax.arrow_left,
        color: Colors.white,
      ),
      onPressed: () => Navigator.pop(context),
    ),
    elevation: 0.0,
  );
}

// ignore: non_constant_identifier_names
PreferredSizeWidget AppBarGoogleMaps({BuildContext? context, String? title}) {
  return AppBar(
    backgroundColor: accentColor,
    leading: IconButton(
      icon: new Icon(
        // FlutterIcons.ios_arrow_back_ion,
        Iconsax.arrow_left,
        color: Colors.white,
      ),
      onPressed: () => Navigator.pop(context!),
    ),
    title: Text(
      title ?? 'Loading...',
      style: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          fontSize: 16,
        ),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget NoAppBar() {
  return PreferredSize(
    preferredSize: Size(0.0, 0.0),
    child: AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );
}

// ignore: non_constant_identifier_names
Widget AppBarHistoryTransaksi({
  BuildContext? context,
  String? title,
  TabController? tabController,
  Function? onRefresh,
}) {
  return AppBar(
    backgroundColor: accentColor,
    leading: null,
    centerTitle: true,
    title: Text(
      title!,
      style: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          fontSize: 16,
        ),
      ),
    ),
    actions: [
      IconButton(
        icon: new Icon(
          // FlutterIcons.ios_refresh_ion,
          Iconsax.refresh,
          color: Colors.white,
        ),
        onPressed: () => onRefresh!(),
      )
    ],
    bottom: TabBar(
      unselectedLabelColor: Colors.white,
      labelColor: Colors.white,
      controller: tabController,
      indicatorColor: Colors.amber,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 15),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: [
        Tab(
          child: Container(
            color: Colors.transparent,
            child: Text("Transfer", style: GoogleFonts.ubuntu()),
          ),
        ),
        Tab(
          child: Container(
            color: Colors.transparent,
            child: Text("PPOB", style: GoogleFonts.ubuntu()),
          ),
        ),
        // Tab(
        //   child: Container(
        //     color: Colors.transparent,
        //     child: Text("Merchant", style: GoogleFonts.ubuntu()),
        //   ),
        // ),
      ],
    ),
    bottomOpacity: 1,
  );
}
