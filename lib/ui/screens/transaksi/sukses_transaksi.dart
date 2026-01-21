import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../model/global_model.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/screens/printer/main_setting_printer.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/viewmodel/transaksi_provider.dart';
import '../../../services/config/config.dart';

import '../../constant/constant.dart';

class SeuksesTransaksiScreen extends StatefulWidget {
  final SuksesTransaksiModel dataSuksesTransaksi;
  SeuksesTransaksiScreen({required this.dataSuksesTransaksi});

  @override
  _SeuksesTransaksiScreenState createState() => _SeuksesTransaksiScreenState();
}

class _SeuksesTransaksiScreenState extends State<SeuksesTransaksiScreen> {
  GlobalProvider? globalProvider;
  TransaksiProvider? transaksiProvider;
  ProdukCollectionProvider? produkProv;
  @override
  void initState() {
    super.initState();
    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      produkProv!.setSaldoResult(widget.dataSuksesTransaksi.saldo_akhir.toString());
    });
    sendNotifikasiTransaksiWhatsApp();
  }

  void sendNotifikasiTransaksiWhatsApp() async {
    if (globalProvider!.getConnectionMode == onlineMode) {
      transaksiProvider!.sendNotifikasiTransaksiWhatsApp(
        context: context,
        rekCd: widget.dataSuksesTransaksi.rekCd,
        transId: widget.dataSuksesTransaksi.idTrx.toString(),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavBar(),
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                ClipPath(
                  clipper: OrangeClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 250.0,
                    decoration: BoxDecoration(
                      color: primaryColor,
                    ),
                  ),
                ),
                ClipPath(
                  clipper: BlackClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 230.0,
                    height: MediaQuery.of(context).size.height - 250.0,
                    decoration: BoxDecoration(
                      color: accentColor,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Material(
                      elevation: 30.0,
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(18.0),
                      child: Container(
                        width: 320.0,
                        height: 545.0,
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(18.0)),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50),
                    Center(
                      child: ClipPath(
                        clipper: ZigZagClipper(),
                        child: Container(
                          width: 330.0,
                          height: 580.0,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.0)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  width: 70.0,
                                  height: 70.0,
                                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/icon/tarik.png'))),
                                ),
                              ),
                              Text('Success!', style: TextStyle(fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold)),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(widget.dataSuksesTransaksi.pesan!, style: TextStyle(fontSize: 15.0)),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                width: 300.0,
                                height: widget.dataSuksesTransaksi.groupProduk == 'KREDIT' ? 400 : 200,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.grey, width: 1.0)),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      if (widget.dataSuksesTransaksi.groupProduk == 'KREDIT')
                                        Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                // FlutterIcons.coins_faw5s,
                                                Iconsax.money,
                                                color: Colors.green,
                                                size: 28.0,
                                              ),
                                              title: Text(
                                                'Pokok : ',
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12.0),
                                              ),
                                              subtitle: Text(
                                                TextUtils.instance.numberFormat(widget.dataSuksesTransaksi.pokok ?? "0"),
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
                                              ),
                                            ),
                                            Container(
                                              width: 300.0,
                                              height: 1.0,
                                              color: Colors.grey,
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Iconsax.money,
                                                color: Colors.green,
                                                size: 28.0,
                                              ),
                                              title: Text(
                                                'Bunga : ',
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12.0),
                                              ),
                                              subtitle: Text(
                                                TextUtils.instance.numberFormat(widget.dataSuksesTransaksi.bunga ?? "0"),
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
                                              ),
                                            ),
                                            Container(
                                              width: 300.0,
                                              height: 1.0,
                                              color: Colors.grey,
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Iconsax.money,
                                                color: Colors.green,
                                                size: 28.0,
                                              ),
                                              title: Text(
                                                'Denda : ',
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12.0),
                                              ),
                                              subtitle: Text(
                                                TextUtils.instance.numberFormat(widget.dataSuksesTransaksi.denda ?? "0"),
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
                                              ),
                                            ),
                                            Container(
                                              width: 300.0,
                                              height: 1.0,
                                              color: Colors.grey,
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Iconsax.money,
                                                color: Colors.green,
                                                size: 28.0,
                                              ),
                                              title: Text(
                                                'Late charge : ',
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12.0),
                                              ),
                                              subtitle: Text(
                                                TextUtils.instance.numberFormat(widget.dataSuksesTransaksi.adm ?? "0"),
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
                                              ),
                                            ),
                                            Container(
                                              width: 300.0,
                                              height: 1.0,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ListTile(
                                        leading: Icon(
                                          Iconsax.money,
                                          color: Colors.green,
                                          size: 28.0,
                                        ),
                                        title: Text(
                                          'Jumlah : ',
                                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12.0),
                                        ),
                                        subtitle: Text(
                                          TextUtils.instance.numberFormat(
                                            widget.dataSuksesTransaksi.jumlah ?? "0",
                                          ),
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
                                        ),
                                      ),
                                      Container(
                                        width: 300.0,
                                        height: 1.0,
                                        color: Colors.grey,
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          // FlutterIcons.pencil_box_outline_mco,
                                          Iconsax.edit,
                                          color: Colors.green,
                                          size: 28.0,
                                        ),
                                        title: Text(
                                          'Keterangan : ',
                                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12.0),
                                        ),
                                        subtitle: Text(
                                          widget.dataSuksesTransaksi.keterangan ?? '-',
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.dataSuksesTransaksi.groupProduk != 'KREDIT')
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40.0),
                                      child: Text(
                                        'Total Transaksi',
                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        TextUtils.instance.numberFormat(widget.dataSuksesTransaksi.jumlah ?? "0"),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // globalProvider.getConnectionMode == offlineMode
                    //     ? SizedBox(height: 80)
                    //     : Padding(
                    //         padding: const EdgeInsets.only(top: 30.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //           children: <Widget>[
                    //             Column(
                    //               children: <Widget>[
                    //                 GestureDetector(
                    //                   onTap: () {
                    //                     ThermalPrinterAction.instance
                    //                         .printAction(
                    //                       contex: context,
                    //                       dataTrx: widget.dataSuksesTransaksi,
                    //                     );
                    //                   },
                    //                   child: Container(
                    //                     width: 40.0,
                    //                     height: 40.0,
                    //                     decoration: BoxDecoration(
                    //                       borderRadius:
                    //                           BorderRadius.circular(40.0),
                    //                       color: Colors.indigo[700],
                    //                     ),
                    //                     child: Center(
                    //                       child: Icon(
                    //                         Icons.print,
                    //                         color: Colors.white,
                    //                         size: 20.0,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   'Print',
                    //                   style: TextStyle(
                    //                     color: Colors.indigo[700],
                    //                     fontSize: 12.0,
                    //                   ),
                    //                 )
                    //               ],
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 30.0),
                    //   child: InkWell(
                    //     splashColor: Colors.red,
                    //     onTap: () => Navigator.pop(context),
                    //     child: Container(
                    //       width: 300.0,
                    //       height: 50.0,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(12.0),
                    //           border: Border.all(
                    //               color: Colors.indigo[700], width: 1.5),
                    //           color: Colors.white),
                    //       child: Center(
                    //         child: Text(
                    //           'Done',
                    //           style: TextStyle(
                    //               color: Colors.indigo[700], fontSize: 15.0),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _bottomNavBar() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: _bottomNavbarBody(),
        ));
  }

  _bottomNavbarBody() {
    return BottomAppBar(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        height: 100,
        width: double.maxFinite, //set your width here
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  splashColor: Colors.red,
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 280.0,
                    height: 50.0,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), border: Border.all(color: Colors.indigo[700]!, width: 1.5), color: Colors.white),
                    child: Center(
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.indigo[700], fontSize: 15.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: globalProvider!.getConnectionMode == offlineMode ? 0 : 10),
                globalProvider!.getConnectionMode == offlineMode
                    ? SizedBox(height: 0)
                    : Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              ThermalPrinterAction.instance.printAction(
                                contex: context,
                                dataTrx: widget.dataSuksesTransaksi,
                              );
                            },
                            child: Container(
                              width: 50.0,
                              height: 45.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.indigo[700],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.print,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(3.0, size.height - 10.0);

    var firstControlPoint = Offset(23.0, size.height - 40.0);
    var firstEndPoint = Offset(38.0, size.height - 5.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(58.0, size.height - 40.0);
    var secondEndPoint = Offset(75.0, size.height - 5.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint = Offset(93.0, size.height - 40.0);
    var thirdEndPoint = Offset(110.0, size.height - 5.0);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy, thirdEndPoint.dx, thirdEndPoint.dy);

    var fourthControlPoint = Offset(128.0, size.height - 40.0);
    var fourthEndPoint = Offset(150.0, size.height - 5.0);
    path.quadraticBezierTo(fourthControlPoint.dx, fourthControlPoint.dy, fourthEndPoint.dx, fourthEndPoint.dy);

    var fifthControlPoint = Offset(168.0, size.height - 40.0);
    var fifthEndPoint = Offset(185.0, size.height - 5.0);
    path.quadraticBezierTo(fifthControlPoint.dx, fifthControlPoint.dy, fifthEndPoint.dx, fifthEndPoint.dy);

    var sixthControlPoint = Offset(205.0, size.height - 40.0);
    var sixthEndPoint = Offset(220.0, size.height - 5.0);
    path.quadraticBezierTo(sixthControlPoint.dx, sixthControlPoint.dy, sixthEndPoint.dx, sixthEndPoint.dy);

    var sevenControlPoint = Offset(240.0, size.height - 40.0);
    var sevenEndPoint = Offset(255.0, size.height - 5.0);
    path.quadraticBezierTo(sevenControlPoint.dx, sevenControlPoint.dy, sevenEndPoint.dx, sevenEndPoint.dy);

    var eightControlPoint = Offset(275.0, size.height - 40.0);
    var eightEndPoint = Offset(290.0, size.height - 5.0);
    path.quadraticBezierTo(eightControlPoint.dx, eightControlPoint.dy, eightEndPoint.dx, eightEndPoint.dy);

    var ninthControlPoint = Offset(310.0, size.height - 40.0);
    var ninthEndPoint = Offset(330.0, size.height - 5.0);
    path.quadraticBezierTo(ninthControlPoint.dx, ninthControlPoint.dy, ninthEndPoint.dx, ninthEndPoint.dy);

    path.lineTo(size.width, size.height - 10.0);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BlackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width / 2, size.height - 50.0);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OrangeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 250.0, size.height - 50.0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
