import 'package:flutter/material.dart';
import '../constant/constant.dart';

class DataNotFound extends StatelessWidget {
  final String? pesan, icon, title;
  final double? heightParse, widthParse;

  DataNotFound({this.title, this.pesan, this.icon, this.heightParse, this.widthParse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Container(
            width: (widthParse == null) ? MediaQuery.of(context).size.width * 0.6 : widthParse,
            height: (heightParse == null) ? 300 : heightParse,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage((icon == null) ? noDataImage : icon as String)),
            ),
          ),
          SizedBox(height: 10),
          Text(
            title ?? '',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            pesan!,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
