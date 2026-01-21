import 'package:flutter/cupertino.dart';

import '../config/router_generator.dart';
import '../../model/global_model.dart';

class IconUtils {
  static IconUtils instance = IconUtils();

  List dataSetting() {
    return [
      ListModelKol(type: 'PRINTER_CONFIG', title: 'Konfigurasi Printer', navigator: RouterGenerator.mainSettingPrinter, icon: 'assets/icon/print.png', key: GlobalKey(), description: 'Klik disini untuk mengkoneksikan printer bluetooth'),
      ListModelKol(type: 'MIGRASI_DATA', title: 'Data Migrasi', navigator: RouterGenerator.mainMigrasiData, icon: 'assets/icon/migrasi.png', key: GlobalKey(), description: 'Klik disini untuk mengupdate data nasabah,produk & konfigurasi offline'),
      ListModelKol(type: 'EKSPOR_DATABASE', title: 'Ekspor Database', navigator: RouterGenerator.exportDatabase, icon: 'assets/icon/download.png', key: GlobalKey(), description: 'Klik disini untuk mendownload data offline'),
      ListModelKol(type: 'ABOUT', title: 'Tentang Aplikasi', navigator: RouterGenerator.about, icon: 'assets/icon/tentang.png', key: GlobalKey(), description: 'Klik disini untuk melihat informasi aplikasi'),
      ListModelKol(type: 'LOGOUT', title: 'Log Out', navigator: RouterGenerator.about, icon: 'assets/icon/logout.png', key: GlobalKey(), description: 'Klik disini untuk keluar dari aplikasi'),
    ];
  }

  List dataMenuKolektor() {
    return [
      ListModelKol(type: 'TRX_KOL', title: 'Transaksi Kolektor', navigator: RouterGenerator.mainTransaksi, icon: 'assets/icon/transaksi.png', key: GlobalKey(), description: 'Klik disini untuk melakukan transaksi kolektor via nomor rekening'),
      ListModelKol(type: 'KLAD', title: 'Daftar Klad', navigator: RouterGenerator.mainKlad, icon: 'assets/icon/daftar.png', key: GlobalKey(), description: 'Klik disini untuk melihat history transaksi kolektor'),
      ListModelKol(type: 'SALDOKOL', title: 'Saldo Kolektor', navigator: RouterGenerator.saldoKolektor, icon: 'assets/icon/saldo.png', key: GlobalKey(), description: 'Klik disini untuk melihat saldo kolektor'),
      ListModelKol(type: 'PENCARIAN_NASABAH', title: 'Pencarian Nasabah', navigator: RouterGenerator.pencarianNasabah, icon: 'assets/icon/pencarian.png', key: GlobalKey(), description: 'Klik disini untuk melakukan pencarian nama nasabah'),
      // ListModelKol(
      //   type: 'DATA_PENAGIHAN',
      //   title: 'Daftar Penagihan Pinjaman',
      //   navigator: RouterGenerator.pinjamanJatuhTempo,
      //   icon: 'assets/icon/icons8_jatemp.png',
      // ),
    ];
  }
}
