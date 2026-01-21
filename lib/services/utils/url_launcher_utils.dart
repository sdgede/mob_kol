import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtils {
  static UrlLauncherUtils instance = UrlLauncherUtils();

  void launchWhatsApp({required String phone}) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone";
      } else {
        return "whatsapp://send?phone=$phone";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  void launchCall({required String phone}) async {
    String url = "tel:$phone";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void launchEmail({required String email}) async {
    String url = "mailto:$email";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $email';
    }
  }

  void launchMaps({String? myAddress, String? destAddress}) async {
    String googleMapslocationUrl = "https://www.google.co.id/maps/dir/" + myAddress!.replaceAll(' ', '+') + "/" + destAddress!.replaceAll(' ', '+');

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      print('Could not launch $encodedURl');
      throw 'Could not launch $encodedURl';
    }
  }

  void launchBrowser({@required String? browser}) async {
    var url = browser;
    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
