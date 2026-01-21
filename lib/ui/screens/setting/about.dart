import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../services/config/config.dart';
import '../../constant/constant.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, primaryColor],
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Icon(null),
          actions: [
            IconButton(
              icon: Icon(
                  // FlutterIcons.ios_close_ion,
                  Iconsax.close_circle,
                  size: 30),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
        body: Container(
          width: deviceWidth(context),
          height: deviceHeight(context),
          child: Center(
            child: Container(
              margin: EdgeInsets.only(top: deviceWidth(context) * 0.4),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 25),
                  Text(
                    mobileName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // SizedBox(height: 15),
                  // Text(
                  //   companyFullName,
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: 16.0,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  SizedBox(height: 10),
                  Text(
                    "v" + (Platform.isAndroid ? versiApkMobile : versiApkIOS),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: deviceHeight(context) / 4),
                  Text(
                    'Powered By',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      fontSize: 12.5,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sevanam ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Enterprise',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
