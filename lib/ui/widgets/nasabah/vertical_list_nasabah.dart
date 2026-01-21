import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:two_letter_icon/two_letter_icon.dart';
import 'package:flutter_initicon/flutter_initicon.dart';

import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/config/router_generator.dart';
import '../../../model/produk_model.dart';
import '../../constant/constant.dart';

class VerticalListNasabah extends StatefulWidget {
  final NasabahProdukModel dataNasabah;
  VerticalListNasabah({required this.dataNasabah});

  @override
  _VerticalListNasbahState createState() => _VerticalListNasbahState();
}

class _VerticalListNasbahState extends State<VerticalListNasabah> {
  ProdukCollectionProvider? _produkProvider;
  bool isLongPress = false;
  double marginVertical = 5;
  double marginHorizontal = 0;

  @override
  void initState() {
    super.initState();
    _produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
  }

  void onLongPress() {
    setState(() {
      isLongPress = true;
      marginVertical = 25;
      marginHorizontal = 25;
    });
  }

  void onLongPressEnd() {
    setState(() {
      marginVertical = 5;
      marginHorizontal = 0;
    });
  }

  void goToInfoProduk() async {
    //real metohod disabled by request
    var _norekResult = widget.dataNasabah.norek;
    var _groupProduk = _produkProvider!.getSelectedgroupProdukProduk;
    var _rekCd = _produkProvider!.getSelectedRkCdProduk;
    var _produkIc = _produkProvider!.getSelectedProdukIcon;

    bool res = await _produkProvider!.getDataProdukByRek(context, _norekResult!) ?? false;
    if (res) {
      Navigator.pushNamed(
        context,
        RouterGenerator.hasilPencarianProduk,
        arguments: {
          'tipe': _groupProduk,
          'rekCd': _rekCd,
          'icon': _produkIc,
          'norek': _norekResult,
          'title': 'Detail Produk',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => goToInfoProduk(),
      onLongPress: () => onLongPress(),
      onLongPressEnd: (val) => onLongPressEnd(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: deviceWidth(context),
        margin: EdgeInsets.symmetric(
          vertical: marginVertical,
          horizontal: marginHorizontal,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _photoUser(),
                SizedBox(width: 10),
                _content(),
              ],
            ),
            Divider(color: Colors.black12),
          ],
        ),
      ),
    );
  }

//user_circle_faw
  Widget _photoUser() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Initicon(
        text: widget.dataNasabah.nama!,
        // backgroundColor:
        //         Colors.primaries[Random().nextInt(Colors.primaries.length)])
      ),
      // child: TwoLetterIcon(widget.dataNasabah.nama!.replaceAll(" ", "")),
    );
  }

  Widget _content() {
    return Flexible(
      child: GestureDetector(
        onTap: () => goToInfoProduk(),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.dataNasabah.norek!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 7),
              Text(
                widget.dataNasabah.nama!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                widget.dataNasabah.alamat!,
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
