import 'package:flutter/material.dart';

//* Device size
double deviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double deviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double deviceHeightWithoutAppBar(BuildContext context, {double height = 25}) {
  return MediaQuery.of(context).size.height -
      (AppBar().preferredSize.height + height);
}

//colors
Color primaryColor = Color(0xff388e3c);
Color accentColor = Color(0xfffbc02d);

//images
String bgCustom = "assets/images/bg_mobkol_default.png";
final String companyLogo = "assets/images/logo.png";
final String splashLogo = "assets/images/logo.png";
final String noDataImage = "assets/images/no_data.png";
final String icDebet = "assets/icon/d_google.png";
final String icCredit = "assets/icon/c_google.png";
final String icHeaderInvoice = "assets/images/header_invoice.png";
final String headerInvoiceImgName = "header_invoice.png";
