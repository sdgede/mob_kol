import 'package:flutter/material.dart';
import 'package:sevanam_mobkol/ui/screens/transaksi/v2/mutasi_transaksi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../ui/screens/daftar_penagihan_pinjaman/daftar_penagihan_pinjaman.dart';
import '../../ui/screens/klad/adapter_pencarian_klad.dart';

//model
import '../../model/global_model.dart';
//landing page and login screen
import '../../ui/screens/login/splash_page.dart';
import '../../ui/screens/login/landing_page.dart';
import '../../ui/screens/login/login_form.dart';
import '../../ui/screens/login/update_page.dart';
import '../../ui/screens/login/ota_update.dart';
//setting
import '../../ui/screens/setting/about.dart';
import '../../ui/screens/setting/reset_password.dart';
import '../../ui/screens/setting/reset_pin.dart';
//printer
import '../../ui/screens/printer/list_printer_device.dart';
import '../../ui/screens/printer/main_setting_printer.dart';
//home kolektor
import '../../ui/screens/home_page/home_kolektor.dart';
//transaksi
import '../../ui/screens/transaksi/hasil_pencarian_produk.dart';
import '../../ui/screens/transaksi/main_transaksi.dart';
import '../../ui/screens/transaksi/mutasi_kredit.dart';
import '../../ui/screens/transaksi/sukses_transaksi.dart';
//saldokol
import '../../ui/screens/saldo_kolektor/main_saldo_kolektor.dart';
//klad kolektor
import '../../ui/screens/klad/main_klad.dart';
//nasabah
import '../../ui/screens/nasabah/adapter_pencarian_nasabah.dart';
import '../../ui/screens/nasabah/pencarian_nasabah.dart';
//migrasi data
import '../../ui/screens/migrasi_data/main_migrasi_data.dart';
//migrasi export database
import '../../ui/screens/export_database/main_export_database.dart';

class RouterGenerator {
  //* Routing list
  static const pageSplash = "/";
  static const pageLanding = "/pageLanding";
  static const pageHomeLogin = "/pageHomeLogin";
  static const pageLogin = "/pageLogin";
  static const homePage = "/homePage";
  static const homeKolektor = "/homeKolektor";
  static const pinLogin = "/pinLogin";
  static const pageUpdate = "/pageUpdate";
  static const otaUpdate = "/otaUpdate";

  //settings
  static const resetPassword = "/settings/resetPassword";
  static const resetPin = "/settings/resetPin";
  static const kontakKami = "/settings/kontakKami";
  static const about = "/settings/about";

  //menu transaksi
  static const mainTransaksi = "/transaksi/mainTransaksiPage";
  static const suksesTransaksi = "/transaksi/suksesTransaksiPage";
  static const hasilPencarianProduk = "/transaksi/hasilPencarianProdukPage";
  static const mutasiTransaksi = "/transaksi/mutasiTransaksiPage";
  static const mutasiKredit = "/transaksi/mutasiKreditPage";
  //menu klad
  static const mainKlad = "/klad/mainKladPage";
  static const adapterPencarianKlad = "/nasabah/asapterPencarianKladPage";
  // menu saldokol
  static const saldoKolektor = "/saldoKolektor/mainSaldoKolektorPage";
  // menu nasabah
  static const pencarianNasabah = "/nasabah/pencarianNasabahPage";
  static const adapterPencarianNasabah = "/nasabah/asapterPencarianNasabahPage";
  // menu printer
  static const mainSettingPrinter = "/printer/mainSettingPrinter";
  static const listPrinterDevice = "/printer/listPrinterDevice";
  // menu migrasi
  static const mainMigrasiData = "/migrasi/mainMigrasiDataPage";
  // menu daftar pinjaman jatuh tempo
  static const pinjamanJatuhTempo = "/migrasi/pinjamanJatuhTempoPage";
  // menu export database
  static const exportDatabase = "/export_database/exportDatabasePage";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // routes main, login, homepage
      case pageSplash:
        return MaterialPageRoute(builder: (_) => SplashPage());

      case pageUpdate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UpdatePage(),
        );

      case otaUpdate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtaUpdatePage(),
        );

      case pageLanding:
        return MaterialPageRoute(builder: (_) => LandingPage());

      case pageLogin:
        return MaterialPageRoute(builder: (_) => LoginPage());

      case homeKolektor:
        return MaterialPageRoute(
          builder: (_) => ShowCaseWidget(
            enableAutoPlayLock: true,
            disableMovingAnimation: false,
            onFinish: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('first_time', false);
            },
            builder: (context) => HomeKolektor(),
          ),
        );

      //setting
      case resetPassword:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => ResetPassword(
              isBuat: args['isBuat'] ?? false,
            ),
          );
        }
        return _errorRoute('Invalid arguments for resetPassword');

      case resetPin:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => ResetPin(
              isBuat: args['isBuat'] ?? false,
            ),
          );
        }
        return _errorRoute('Invalid arguments for resetPin');

      case about:
        return MaterialPageRoute(builder: (_) => AboutScreen());

      //transaksi
      case mainTransaksi:
        return MaterialPageRoute(builder: (_) => MainTransaksi());

      case hasilPencarianProduk:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => HasilPencarianProduk(
              arguments: args,
            ),
          );
        }
        return _errorRoute('Invalid arguments for hasilPencarianProduk');

      case suksesTransaksi:
        if (args is SuksesTransaksiModel) {
          return MaterialPageRoute(
            builder: (_) => SeuksesTransaksiScreen(
              dataSuksesTransaksi: args,
            ),
          );
        }
        return _errorRoute('Invalid arguments for suksesTransaksi');

      case mutasiTransaksi:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => MutasiTransaksi(
              arguments: args,
            ),
          );
        }
        return _errorRoute('Invalid arguments for mutasiTransaksi');

      case mutasiKredit:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => MutasiKredit(
              arguments: args,
            ),
          );
        }
        return _errorRoute('Invalid arguments for mutasiKredit');

      //klad
      case mainKlad:
        return MaterialPageRoute(builder: (_) => MainKlad());

      case adapterPencarianKlad:
        return MaterialPageRoute(builder: (_) => AdapterPencarianKlad());

      //saldo kolektor
      case saldoKolektor:
        return MaterialPageRoute(builder: (_) => MainSaldoKolektor());

      //nasabah
      case pencarianNasabah:
        return MaterialPageRoute(builder: (_) => PencarianNasabah());

      case adapterPencarianNasabah:
        return MaterialPageRoute(builder: (_) => AdapterPencarianNasabah());

      //printer
      case mainSettingPrinter:
        return MaterialPageRoute(builder: (_) => MainSettingPrinter());

      case listPrinterDevice:
        return MaterialPageRoute(builder: (_) => ListPrinterDevice());

      //migrasi data
      case mainMigrasiData:
        return MaterialPageRoute(builder: (_) => MainMigrasiData());

      case pinjamanJatuhTempo:
        return MaterialPageRoute(builder: (_) => DaftarPenagihanPinjaman());

      //export database
      case exportDatabase:
        return MaterialPageRoute(builder: (_) => ExportDatabase());

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Returns an error route when navigation fails
  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Navigation Error',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // This will be handled by the navigator
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
