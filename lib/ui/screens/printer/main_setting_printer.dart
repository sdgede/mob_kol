import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;

import '../../widgets/app_bar.dart';
import '../../constant/constant.dart';
import '../../../model/global_model.dart';
import '../../../services/config/config.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/config/router_generator.dart';

class MainSettingPrinter extends StatefulWidget {
  @override
  _MainSettingPrinter createState() => new _MainSettingPrinter();
}

class _MainSettingPrinter extends State<MainSettingPrinter> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _device;
  bool _connected = false;
  bool _pressed = false;
  bool _isConnected = false;
  String? pathImage;
  GlobalProvider? globalProv;

  @override
  void initState() {
    super.initState();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    initPlatformState();
    initSavetoPath();
    checkConnectionStatus();
  }

  Future<void> checkConnectionStatus() async {
    bool status = await PrintBluetoothThermal.connectionStatus;
    setState(() {
      _connected = status;
      _isConnected = status;
    });
  }

  initSavetoPath() async {
    final filename = headerInvoiceImgName;
    var bytes = await rootBundle.load(icHeaderInvoice);
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    setState(() {
      pathImage = '$dir/$filename';
    });
  }

  Future<void> initPlatformState() async {
    List<BluetoothInfo> devices = [];

    try {
      devices = await PrintBluetoothThermal.pairedBluetooths;
    } on PlatformException {
      print('ERR_404: Failed to get paired devices');
    }

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: DefaultAppBar(
          context,
          "Konfigurasi printer",
          isCenter: true,
          isRefresh: false,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Consumer<GlobalProvider>(
                      builder: (contex, globalProv, _) {
                        return Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            _headerInfo(globalProv),
                            SizedBox(height: 10),
                            _selectPrinter(),
                            _connectPrinter(context, globalProv),
                            if (_isConnected)
                              Column(
                                children: [
                                  if (clientType == ClientType.koperasi)
                                    _btnSamplePrint(
                                      tittle: 'PRINT SAMPLE SIMP ANGGOTA',
                                      printAction: _formatAgt,
                                    ),
                                  _btnSamplePrint(
                                    tittle: 'PRINT SAMPLE TABUNGAN',
                                    printAction: _formatTab,
                                  ),
                                  _btnSamplePrint(
                                    tittle: 'PRINT SAMPLE SIMP BERENCANA',
                                    printAction: _formatJangka,
                                  ),
                                  _btnSamplePrint(
                                    tittle: clientType == ClientType.koperasi
                                        ? 'PRINT SAMPLE SIMP PINJAMAN'
                                        : 'PRINT SAMPLE KREDIT',
                                    printAction: _formatKredit,
                                  ),
                                  _disconnect(),
                                ],
                              )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerInfo(GlobalProvider globalProv) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 30),
          Image.asset(
            "assets/images/bluetooth_logo.png",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Pilih koneksi printer dan klik connect printer untuk menghubungkan device anda",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Pastikan Bluetooth Anda telah aktif untuk dapat menggunakan fitur ini!",
              style: TextStyle(fontSize: 13, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "SELECTED PRINTER : ",
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              globalProv.getSelectedPrinterName ?? "-",
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _selectPrinter() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                RouterGenerator.listPrinterDevice,
              );
            },
            child: Center(
              child: Text(
                'Select printer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _disconnect() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              bool confirm = await DialogUtils.instance.dialogConfirm(
                context,
                'Disconnect printer from your device?',
              );
              if (confirm) {
                await PrintBluetoothThermal.disconnect;
                setState(() {
                  _pressed = true;
                  _isConnected = false;
                  _connected = false;
                });
              }
            },
            child: Center(
              child: Text(
                'DISCONNECT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnSamplePrint({
    String? tittle,
    Function? printAction,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              printAction!();
            },
            child: Center(
              child: Text(
                tittle!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _connectPrinter(BuildContext context, GlobalProvider globalProv) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: globalProv.getSelectedPrinter == null
              ? Colors.grey
              : Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              connectToPrinter(context, globalProv.getSelectedPrinter);
            },
            child: Center(
              child: Text(
                'Connect printer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void connectToPrinter(BuildContext context, dynamic blDevice) async {
    if (blDevice == null) {
      alertSnack(context, 'No device selected');
    } else {
      setState(() {
        _pressed = true;
      });

      // Pastikan blDevice adalah BluetoothInfo
      String macAddress = '';
      if (blDevice is BluetoothInfo) {
        macAddress = blDevice.macAdress;
      } else if (blDevice is Map && blDevice.containsKey('macAdress')) {
        macAddress = blDevice['macAdress'];
      }

      bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

      if (result) {
        alertSnack(context, 'Printer connected successfully');
        setState(() {
          _isConnected = true;
          _connected = true;
        });
      } else {
        alertSnack(context, 'Failed to connect printer');
        setState(() {
          _isConnected = false;
          _connected = false;
        });
      }

      setState(() {
        _pressed = false;
      });
    }
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  // Helper method untuk print image
  Future<void> _printImage(String imagePath) async {
    try {
      final ByteData data = await rootBundle.load(imagePath);
      final Uint8List bytes = data.buffer.asUint8List();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // Resize image untuk thermal printer (max width 384 pixels untuk 58mm)
        final resized = img.copyResize(image, width: 384);
        final imageBytes = Uint8List.fromList(img.encodeJpg(resized));

        // Convert ke base64 dan print (sesuaikan dengan API package)
        await PrintBluetoothThermal.writeBytes(imageBytes);
      }
    } catch (e) {
      print('Error printing image: $e');
    }
  }

  // Helper method untuk print text
  Future<void> _printText(String text, {int size = 1, int align = 0}) async {
    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: size, text: text));
  }

  void _formatTab() async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      await _printImage(icHeaderInvoice);
      await _printText("\n\n");
      await _printText("SETORAN TUNAI TABUNGAN\n", size: 2, align: 1);
      await _printText("\n");
      await _printText("Tanggal    : 10-10-2021 09:10:20\n");
      await _printText("\n");
      await _printText("No.Slip    : T0000002\n");
      await _printText("No.Rek     : 001100.0000778\n");
      await _printText("Nama       : I PUTU SURYA ANTARA\n");
      await _printText("No.Telp    : 081887776554\n");
      await _printText("\n");
      await _printText("Saldo Awal : Rp 1.000.000\n");
      await _printText("Total      : Rp 200.000\n");
      await _printText("(Dua ratus ribu rupiah)\n");
      await _printText("Saldo Akhir: Rp 1.200.000\n");
      await _printText("\n");
      await _printText("Petugas    : MALIK\n");
      await _printText("089661348315\n");
      await _printText("081252797850\n");
      await _printText("\n\n\n");
    }
  }

  void _formatAgt() async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      await _printImage(icHeaderInvoice);
      await _printText("\n\n");
      await _printText("SETORAN TUNAI SIMPANAN WAJIB\n", size: 2, align: 1);
      await _printText("\n");
      await _printText("Tanggal    : 10-10-2021 09:10:20\n");
      await _printText("\n");
      await _printText("No.Slip    : T0000003\n");
      await _printText("No.Rek     : 001100.00006676\n");
      await _printText("Nama       : I PUTU SURYA ANTARA\n");
      await _printText("No.Telp    : 081887776554\n");
      await _printText("\n");
      await _printText("Saldo Awal : Rp 1.000.000\n");
      await _printText("Total      : Rp 200.000\n");
      await _printText("(Dua ratus ribu rupiah)\n");
      await _printText("Saldo Akhir: Rp 1.200.000\n");
      await _printText("\n");
      await _printText("Petugas    : MALIK\n");
      await _printText("089661348315\n");
      await _printText("081252797850\n");
      await _printText("\n\n\n");
    }
  }

  void _formatJangka() async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      await _printImage(icHeaderInvoice);
      await _printText("\n\n");
      await _printText("SETORAN TUNAI TABUNGAN BERJANGKA\n", size: 2, align: 1);
      await _printText("\n");
      await _printText("Tanggal    : 10-10-2021 09:10:20\n");
      await _printText("\n");
      await _printText("No.Slip    : T0000004\n");
      await _printText("No.Rek     : 001100.000006654\n");
      await _printText("Nama       : I PUTU SURYA ANTARA\n");
      await _printText("No.Telp    : 081887776554\n");
      await _printText("\n");
      await _printText("Saldo Awal : Rp 2.000.000\n");
      await _printText("Total      : Rp 200.000\n");
      await _printText("(Dua ratus ribu rupiah)\n");
      await _printText("Saldo Akhir: Rp 2.200.000\n");
      await _printText("\n");
      await _printText("Petugas    : MALIK\n");
      await _printText("089661348315\n");
      await _printText("081252797850\n");
      await _printText("\n\n\n");
    }
  }

  void _formatKredit() async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      await _printImage(icHeaderInvoice);
      await _printText("\n\n");
      await _printText("PEMBAYARAN PINJAMAN TUNAI\n", size: 2, align: 1);
      await _printText("\n");
      await _printText("Tanggal    : 15-06-2021 09:10:20\n");
      await _printText("\n");
      await _printText("No.Slip    : T0000005\n");
      await _printText("No.Krdt    : 001100.000001212\n");
      await _printText("Nama       : I PUTU SURYA ANTARA\n");
      await _printText("No.Telp    : 081887776554\n");
      await _printText("\n");
      await _printText("Pokok      : Rp 499.084\n");
      await _printText("Bunga      : Rp 100.916\n");
      await _printText("Denda      : Rp 0\n");
      await _printText("Jumlah     : Rp 600.000\n");
      await _printText("(Enam ratus ribu rupiah)\n");
      await _printText("Bakidebet  : Rp 10.313.326\n");
      await _printText("\n");
      await _printText("Petugas    : MALIK\n");
      await _printText("089661348315\n");
      await _printText("081252797850\n");
      await _printText("\n\n\n");
    }
  }

  void alertSnack(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// Updated ThermalPrinterAction class
class ThermalPrinterAction {
  static ThermalPrinterAction instance = ThermalPrinterAction();

  String pathImage = '0', getPathImg = '0';

  dynamic printAction({
    BuildContext? contex,
    SuksesTransaksiModel? dataTrx,
  }) async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (!isConnected) {
      alertSnack(contex!, 'Tidak ada printer yang terhubung');
      return;
    }

    final _globalProv = Provider.of<GlobalProvider>(contex!, listen: false);
    String rekDesc = dataTrx!.groupProduk == 'KREDIT' ? 'No. Krdit' : 'No Rek';
    String saldoAkhirDesc =
        dataTrx.groupProduk == 'KREDIT' ? 'Bakidebet' : 'Saldo Akhir';

    // Print image (sesuaikan dengan cara print image di package baru)
    // await _printImageFromPath(_globalProv.getInvoiceImage);

    await _printText("\n");
    await _printText(dataTrx.kode! + "\n");
    await _printText("================================\n");
    await _printText("\n");
    await _printText("Tanggal    : ${dataTrx.trxDate ?? '-'}\n");
    await _printText("No.Slip    : ${dataTrx.noReferensi ?? '-'}\n");
    await _printText("$rekDesc     : ${dataTrx.norek ?? '-'}\n");
    await _printText("Nama       : ${dataTrx.nama ?? '-'}\n");
    await _printText("No.Telp    : ${dataTrx.hp?.toString() ?? '-'}\n");
    await _printText("\n");

    if (dataTrx.groupProduk != 'KREDIT') {
      await _printText(
          "Saldo Awal : ${_currency(dataTrx.saldo_awal?.toString()) ?? '-'}\n");
    }

    if (dataTrx.groupProduk == 'KREDIT') {
      await _printText(
          "Pokok      : ${_currency(dataTrx.pokok?.toString()) ?? '0'}\n");
      await _printText(
          "Bunga      : ${_currency(dataTrx.bunga?.toString()) ?? '0'}\n");
      await _printText(
          "Denda      : ${_currency(dataTrx.denda?.toString()) ?? '0'}\n");
    }

    await _printText(
        "Jumlah     : ${_currency(dataTrx.jumlah?.toString()) ?? '-'}\n");
    await _printText("(${dataTrx.terbilang!})\n");
    await _printText(
        "$saldoAkhirDesc: ${_currency(dataTrx.saldo_akhir?.toString()) ?? '-'}\n");
    await _printText("--------------------------------\n");
    await _printText("Petugas    : ${dataTrx.who ?? '-'}\n");
    await _printText("================================\n");
    await _printText("Mohon dicek kembali.Terima kasih\n");
    await _printText("\n\n\n");
  }

  dynamic printActionV2({
    BuildContext? contex,
    String? groupProduk,
    String? kode,
    String? trxDate,
    String? noref,
    String? norek,
    String? nama,
    String? hp,
    String? saldoAwal,
    String? pokok,
    String? bunga,
    String? denda,
    String? lateCHarge,
    String? jumlah,
    String? terbilang,
    String? saldoAkhir,
    String? who,
  }) async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (!isConnected) {
      alertSnack(contex!, 'Tidak ada printer yang terhubung');
      return;
    }

    final _globalProv = Provider.of<GlobalProvider>(contex!, listen: false);
    String rekDesc = groupProduk == 'KREDIT' ? 'No. Krdit' : 'No Rek';
    String saldoAkhirDesc =
        groupProduk == 'KREDIT' ? 'Bakidebet' : 'Saldo Akhir';

    // Print image (sesuaikan dengan cara print image di package baru)
    // await _printImageFromPath(_globalProv.getInvoiceImage);

    await _printText("\n");
    await _printText(kode! + "\n");
    await _printText("================================\n");
    await _printText("\n");
    await _printText("Tanggal    : ${trxDate ?? '-'}\n");
    await _printText("No.Slip    : ${noref ?? '-'}\n");
    await _printText("$rekDesc     : ${norek ?? '-'}\n");
    await _printText("Nama       : ${nama ?? '-'}\n");
    await _printText("No.Telp    : ${hp?.toString() ?? '-'}\n");
    await _printText("\n");

    if (groupProduk != 'KREDIT') {
      await _printText(
          "Saldo Awal : ${_currency(saldoAwal?.toString()) ?? '-'}\n");
    }

    if (groupProduk == 'KREDIT') {
      await _printText("Pokok      : ${_currency(pokok?.toString()) ?? '0'}\n");
      await _printText("Bunga      : ${_currency(bunga?.toString()) ?? '0'}\n");
      await _printText("Denda      : ${_currency(denda?.toString()) ?? '0'}\n");
    }

    await _printText("Jumlah     : ${_currency(jumlah?.toString()) ?? '-'}\n");
    await _printText("(${terbilang!})\n");
    await _printText(
        "$saldoAkhirDesc: ${_currency(saldoAkhir?.toString()) ?? '-'}\n");
    await _printText("--------------------------------\n");
    await _printText("Petugas    : ${who ?? '-'}\n");
    await _printText("================================\n");
    await _printText("Mohon dicek kembali.Terima kasih\n");
    await _printText("\n\n\n");
  }

  Future<void> _printText(String text, {int size = 1}) async {
    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: size, text: text));
  }

  String? _currency(String? val) {
    return val != null ? TextUtils.instance.numberFormat(val) : null;
  }

  void alertSnack(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
