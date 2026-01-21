import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/utils/text_utils.dart';
import '../../constant/constant.dart';

class ProdukDialog extends StatelessWidget {
  final bool isSetDefault;
  ProdukDialog({this.isSetDefault = false});
  @override
  Widget build(BuildContext context) {
    var nasabahTabunganProvider = Provider.of<ProdukTabunganProvider>(context, listen: false);
    return StreamBuilder(
      initialData: nasabahTabunganProvider.produkTabunganUser,
      stream: null,
      builder: (contex, dynamic snapshot) {
        return Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Stack(
            children: <Widget>[
              _titleDialog(context),
              Container(
                margin: EdgeInsets.only(top: 60),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (BuildContext ctx, int index) {
                    return _cardListProduk(context, snapshot.data![index]);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _titleDialog(context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              isSetDefault ? "Pilih Default Rekening" : "Pilih Rekening Sumber",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.clear,
                size: 35,
                color: Colors.red[400],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardListProduk(context, data) {
    return Consumer<ProdukTabunganProvider>(
      builder: (contex, produkTabunganProvider, _) {
        return InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Navigator.of(context).pop();
            if (isSetDefault) {
              produkTabunganProvider.setDefaultRekSumber(data.no_rek, data.nama, data.saldo);
            } else {
              produkTabunganProvider.setRekSumber(noRek: data.no_rek);
            }
          },
          child: Card(
            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _cardTextLeft(
                    data.nama,
                    TextStyle(
                      fontFamily: "SemiBoldFont",
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                  _cardTextLeft(
                    data.no_rek,
                    TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _cardTextRight(
                    TextUtils.instance.numberFormat(data.saldo),
                    TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cardTextLeft(String text, TextStyle textStyle) {
    return Container(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(5),
        child: Text(
          text == '' ? '-' : text,
          textAlign: TextAlign.left,
          style: textStyle,
        ),
      ),
    );
  }

  Widget _cardTextRight(String text, TextStyle textStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            text == '' ? '-' : text,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class ProdukMutasiDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var produkCollectionProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    return StreamBuilder(
      stream: null,
      initialData: produkCollectionProvider.listProdukCollection,
      builder: (contex, dynamic snapshot) {
        return Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Stack(
            children: <Widget>[
              _titleDialog(context),
              Container(
                margin: EdgeInsets.only(top: 60),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (BuildContext ctx, int index) {
                    return _cardListProduk(context, snapshot.data![index]);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _titleDialog(context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "Pilih Rekening Sumber",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.clear,
                size: 35,
                color: Colors.red[400],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardListProduk(context, data) {
    return Consumer<ProdukCollectionProvider>(
      builder: (contex, produkCollectionProvider, _) {
        return InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Navigator.of(context).pop();
            produkCollectionProvider.setIdProduk(data.produk_id, true);
            produkCollectionProvider.setMutasiLoading(true, true);
            produkCollectionProvider.getMutasiProdukByProdukIdDateRage(context, data.produk_id, data.jenis_produk);
          },
          child: Card(
            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _cardTextLeft(
                    data.nama,
                    TextStyle(
                      fontFamily: "SemiBoldFont",
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                  _cardTextLeft(
                    data.no_rek,
                    TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _cardTextRight(
                    TextUtils.instance.numberFormat(data.saldo),
                    TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cardTextLeft(String text, TextStyle textStyle) {
    return Container(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(5),
        child: Text(
          text == '' ? '-' : text,
          textAlign: TextAlign.left,
          style: textStyle,
        ),
      ),
    );
  }

  Widget _cardTextRight(String text, TextStyle textStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            text == '' ? '-' : text,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
