import '../../model/global_model.dart';
import '../config/config.dart';

class SliderUtils {
  static SliderUtils instance = SliderUtils();

  final sliderArrayList = [
    Slider(
      sliderImageUrl: 'assets/images/slider_1.png',
      sliderHeading: "Aplikasi Mudah Digunakan",
      sliderSubHeading: "Aplikasi " + companyName + " Memiliki Antar Muka Sederhana Sehingga Sangat Mudah Digunakan",
    ),
    Slider(
      sliderImageUrl: 'assets/images/slider_2.png',
      sliderHeading: "Login Dengan PIN",
      sliderSubHeading: "Login ke Aplikasi Cukup Dengan PIN 6 Digit Sehingga Mudah Diingat",
    ),
    Slider(
      sliderImageUrl: 'assets/images/slider_3.png',
      sliderHeading: "Informasi Saldo dan Mutasi",
      sliderSubHeading: "Anda Dapat Melihat Saldo dan Mutasi Dari Masing-Masing Produk Kapan Saja dan Dimana Saja",
    ),
    Slider(
      sliderImageUrl: 'assets/images/slider_4.png',
      sliderHeading: "Notifikasi Transaksi",
      sliderSubHeading: "Anda Akan Mendapatkan Notifikasi Dari Setiap Transaksi yang Anda Lakukan",
    ),
  ];

  final sliderArrayListDaftarOnline = [
    Slider(sliderImageUrl: 'assets/icon/tdk_ke_cabang.png', sliderHeading: "Tidak Perlu Datang Ke Kantor", sliderSubHeading: "Praktis! Semua proses dapat dilakukan di ponsel Anda."),
    Slider(sliderImageUrl: 'assets/icon/dpt_mobile_int_bank.png', sliderHeading: "Langsung Dapat Fasilitas Mobile & Internet Banking", sliderSubHeading: "Transaksi jadi lebih mudah dengan fasilitas mobile & internet banking."),
    Slider(sliderImageUrl: 'assets/icon/trx_simple_dg_mobile_bank.png', sliderHeading: "Lebih Simple Transaksi Dengan Mobile Banking", sliderSubHeading: "Gunakan mobile banking Anda untuk melakukan transaksi."),
  ];

  final sliderArrayListPengajuanPinjaman = [
    Slider(sliderImageUrl: 'assets/icon/tdk_ke_cabang.png', sliderHeading: "Tidak Perlu Datang Ke Kantor", sliderSubHeading: "Praktis! Semua proses dapat dilakukan di ponsel Anda."),
    Slider(sliderImageUrl: 'assets/icon/dpt_mobile_int_bank.png', sliderHeading: "Proses Cepat dan Syarat Mudah", sliderSubHeading: "Proses pengajuan mudah dan cepat"),
    Slider(sliderImageUrl: 'assets/icon/trx_simple_dg_mobile_bank.png', sliderHeading: "Dana Cair dalam Hitungan Hari", sliderSubHeading: "Tidak perlu menunggu waktu lama untuk dana cair."),
  ];
}
