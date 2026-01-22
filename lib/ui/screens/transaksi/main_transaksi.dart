import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../services/config/router_generator.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/utils/qr_utils.dart';
import '../../../ui/widgets/floating_action_button.dart';
import '../../../ui/widgets/slide/slide_list_produk.dart';
import '../../widgets/loader/lottie_loader.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';

class MainTransaksi extends StatefulWidget {
  @override
  _MainTransaksi createState() => _MainTransaksi();
}

class _MainTransaksi extends State<MainTransaksi> {
  ProdukCollectionProvider? produkProvider;
  double? _width, _primaryPadding = 15;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool? _isScan;
  ScrollController? produkScrollCOntroller;
  TextEditingController nomorRekController = new TextEditingController(),
      _controllerReq = new TextEditingController();
  // ignore: unused_field
  List<DropdownMenuItem<NorekShortcut>>? _countryItems;
  // ignore: unused_field
  NorekShortcut? _selectedShortcut;

  void _initNorekShortCut() {
    List<NorekShortcut> countries = NorekShortcut.allCountries;
    _countryItems = countries.map<DropdownMenuItem<NorekShortcut>>(
      (NorekShortcut countryOption) {
        return DropdownMenuItem<NorekShortcut>(
          value: countryOption,
          child: Text(countryOption.fullName),
        );
      },
    ).toList();
    _selectedShortcut = countries[0];
  }

  @override
  void initState() {
    super.initState();
    _isScan = false;
    produkProvider =
        Provider.of<ProdukCollectionProvider>(context, listen: false);
    produkProvider!
        .setAllDatafirstSelectedProduct(context: context, isListen: false);
    _initNorekShortCut();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Consumer<ProdukCollectionProvider>(
      builder: (contex, produkProv, _) {
        if (produkProv.produkCollection == null) {
          produkProv.dataProduk(context);
          return LottiePrimaryLoader();
        }
        return Scaffold(
          floatingActionButton: floatingActionSwitchMode(context),
          appBar: DefaultAppBar(
            context,
            "Transaksi " +
                (produkProv.getSelectedProdukName ?? ' - ').toLowerCase(),
            isCenter: true,
            isRefresh: true,
            onRefresh: () => produkProvider!.refreshProdukCollection(),
          ),
          key: scaffoldKey,
          body: Container(
            margin: EdgeInsets.only(top: 15),
            width: _width,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  scrollTag(context),
                  Divider(),
                  SizedBox(height: 10),
                  _checkBox(type: "isScan", text: "Mode scan"),
                  SizedBox(height: 20),
                  textFieldNorek(produkProv.getSelectedRekShortcut ?? '',
                      produkProv.getSelectedgroupProdukProduk ?? ''),
                  SizedBox(height: 10),
                  buttonCari(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _checkBox({
    String? type,
    String? text,
    bool isKetentuan = false,
    Widget? ketentuan,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _primaryPadding!),
      child: Row(
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _isScan,
              onChanged: (bool? value) {
                setState(() {
                  _isScan = value;
                });
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: isKetentuan
                ? ketentuan!
                : Text(
                    text!,
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
          ),
        ],
      ),
    );
  }

  Widget scrollTag(BuildContext context) {
    return Consumer<ProdukCollectionProvider>(
      builder: (context, produkProvider, _) {
        if (produkProvider.produkCollection == null) {
          produkProvider.dataProduk(context);
          return LinearProgressIndicator();
        }
        return Container(
          height: 90,
          margin: EdgeInsets.only(left: 10),
          child: ListView.builder(
            itemCount: produkProvider.produkCollection!.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            controller: produkScrollCOntroller,
            itemBuilder: (BuildContext context, int i) {
              var dataProduk = produkProvider.produkCollection![i];
              return SlideListProduk(dataProduk: dataProduk, isKlad: false);
            },
          ),
        );
      },
    );
  }

  Widget textFieldNorek(String rekParse, String groupProduk) {
    //NOREK SHORTCUT PARSE

    _controllerReq.text = rekParse;
    if (groupProduk != 'KREDIT')
      _controllerReq.selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerReq.text.length));
    return Container(
        padding:
            EdgeInsets.only(left: _primaryPadding!, right: _primaryPadding!),
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                Text(
                  "No rekening",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextFormField(
                  controller: _controllerReq,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Masukkan no rekening",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    contentPadding: EdgeInsets.only(top: 15),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Norek tidak boleh kosong!';
                    }
                    return null;
                  },
                  //onChanged: (value) => checkButtonReq(),
                ),
              ],
            ),
          ],
        ));
  }

  Widget buttonCari() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: (_isScan!) ? Colors.amber : accentColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.only(left: _primaryPadding!, right: _primaryPadding!),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            var _norekResult = _controllerReq.text;
            var _groupProduk = produkProvider!.getSelectedgroupProdukProduk;
            var _rekCd = produkProvider!.getSelectedRkCdProduk;
            var _produkIc = produkProvider!.getSelectedProdukIcon;
            if (_isScan!) {
              _norekResult = await QRUtils.instance.qrScanner(context);
              setState(() {
                _controllerReq.text = _norekResult;
              });
            }
            bool res = await produkProvider!.getDataProdukByRek(
                  context,
                  _norekResult,
                ) ??
                false;
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
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                (_isScan!) ? "SCAN" : "CARI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                (_isScan!) ? Iconsax.scan_barcode : Iconsax.search_normal_1,
                color: Colors.white,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NorekShortcut {
  final String key;
  final String fullName;

  NorekShortcut(this.key, this.fullName);

  static List<NorekShortcut> get allCountries => [
        NorekShortcut('001101.', 'PINJAMAN ANGSURAN FLAT'),
        NorekShortcut('001103.', 'PINJAMAN TANPA AGUNAN'),
        NorekShortcut('001501.', 'PINJAMAN ANGSURAN MENURUN'),
        NorekShortcut('001600.', 'PINJAMAN ANGSURAN ANUITAS'),
        NorekShortcut('001900.', 'PINJAMAN ANGSURAN FLAT MINGGUAN'),
      ];
}
