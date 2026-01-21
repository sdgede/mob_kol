import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ClientType { lpd, koperasi }

extension ClientTypeExtension on ClientType {
  String get name {
    switch (this) {
      case ClientType.lpd:
        return 'LPD';
      case ClientType.koperasi:
        return 'Koperasi';
      default:
        return '';
    }
  }

  static ClientType fromString(String type) {
    switch (type) {
      case 'LPD':
        return ClientType.lpd;
      case 'KOPERASI':
        return ClientType.koperasi;
      default:
        return ClientType.koperasi;
    }
  }
}

//con mode
String onlineMode = "ONLINE";
String offlineMode = "OFFLINE";
dynamic forbidenOffline = ['KREDIT', 'PINJAMAN'];

// api map
String apiMapMobile = dotenv.env['API_MAP_ANDROID_KEY'] ?? '';
String apiMapIOS = dotenv.env['API_MAP_IOS_KEY'] ?? '';

// versi apk
String versiApkMobile = dotenv.env['VERSION_ANDROID'] ?? '';
String versiApkIOS = dotenv.env['VERSION_IOS'] ?? '';

//company profile
String mobileName = dotenv.env['MOBILE_NAME'] ?? '';
String companyName = dotenv.env['COMPANY_NAME'] ?? '';
String companyFullName = dotenv.env['COMPANY_FULL_NAME'] ?? '';
String companySlogan = dotenv.env['COMPANY_SLOGAN'] ?? '';
String companyShortName = dotenv.env['COMPANY_SHORT_NAME'] ?? '';
String nomorCompany = dotenv.env['COMPANY_NOMOR'] ?? '';
String nomorWhatsAppCompany = dotenv.env['COMPANY_NOMOR_WA'] ?? '';
String emailCompany = dotenv.env['COMPANY_EMAIL'] ?? '';
ClientType clientType = ClientTypeExtension.fromString(dotenv.env['CLIENT_TYPE'] ?? '');

String imageName = dotenv.env['IMAGE_NAME'] ?? '';
String jamAwalVC = "09.00";
String jamAkhirVC = "16.00";

// api berita link
String apiBeritaLink = "https://newsapi.org/v2/top-headlines?country=id&category=business&apiKey=";

// api ws link
String vendorApp = dotenv.env['VENDOR_APP'] ?? '';
String baseURL = dotenv.env['BASE_URL'] ?? '';
bool isAlvaibleTfBank = false;

class ConfigURL {
  String iconLink = "assets/icon/";
  String urlApiLogin = "Login";
  String urlApiNasabah = "Nasabah";
  String urlApiNasabahProduk = "Nasabah_tabungan";
  String urlApiNasabahKredit = "Nasabah_kredit";
  String urlApiNasabahDeposito = "Nasabah_deposito";
  String urlApiPembelian = "Pembelian";
  String urlApiMerchant = "Merchant";
  String urlApiTransaksiTabungan = "Trans_tabungan";
  String urlApiTransaksiDeposito = "Trans_deposito";
  String urlApiTransaksiKredit = "Trans_kredit";
  String urlApiNotifikasi = "Notifikasi";
  String urlApiEform = "Eform";
  String urlApiTransferBank = "Transfer_bank";
  String urlProductCollector = "productCollector";
  String urlImg = "assets/foto/";

  ConfigURL() {
    this.iconLink = "$baseURL${this.iconLink}";
    this.urlApiLogin = "$baseURL${this.urlApiLogin}";
    this.urlApiNasabah = "$baseURL${this.urlApiNasabah}";
    this.urlApiNasabahProduk = "$baseURL${this.urlApiNasabahProduk}";
    this.urlApiNasabahKredit = "$baseURL${this.urlApiNasabahKredit}";
    this.urlApiNasabahDeposito = "$baseURL${this.urlApiNasabahDeposito}";
    this.urlApiPembelian = "$baseURL${this.urlApiPembelian}";
    this.urlApiMerchant = "$baseURL${this.urlApiMerchant}";
    this.urlApiTransaksiTabungan = "$baseURL${this.urlApiTransaksiTabungan}";
    this.urlApiTransaksiDeposito = "$baseURL${this.urlApiTransaksiDeposito}";
    this.urlApiTransaksiKredit = "$baseURL${this.urlApiTransaksiKredit}";
    this.urlApiNotifikasi = "$baseURL${this.urlApiNotifikasi}";
    this.urlApiEform = "$baseURL${this.urlApiEform}";
    this.urlApiTransferBank = "$baseURL${this.urlApiTransferBank}";
    this.urlProductCollector = "$baseURL${this.urlProductCollector}";
    this.urlImg = "$baseURL${this.urlImg}";
  }
}

// mcrypt
String saltHashKey = dotenv.env['SALT_HASH_KEY'] ?? '';
String secretKey = dotenv.env['SECRET_KEY'] ?? '';
String iv = dotenv.env['IV'] ?? '';
String secretKeyMerchant = dotenv.env['SECRET_KEY_MERCHANT'] ?? '';
String ivMerchant = dotenv.env['IV_MERCHANT'] ?? '';
String clientId = dotenv.env['CLIENT_ID'] ?? '';
String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';

//custom
String SKIP = "Selesai";
String PREVIOUS = "Sebelumnya";
String NEXT = "Selanjutnya";
String Loading = "Loading...";
String Reconnect = "Menghubungkan...";
String ForgetPassword = "Lupa username/password ?";
String PersonName = "User";
String DateSystem = DateFormat("yyyy-MM-dd").format(new DateTime.now());
String Date = DateFormat("dd-MM-yyyy").format(new DateTime.now());
String Greeting = ((DateTime.now().hour >= 0 && DateTime.now().hour < 11) ? "Selamat Pagi" : ((DateTime.now().hour >= 11 && DateTime.now().hour < 15) ? "Selamat Siang" : ((DateTime.now().hour >= 15 && DateTime.now().hour < 18) ? "Selamat Sore" : "Selamat Malam")));
String firebaseId = "0";
String? platform;
String RelateApp = "Aplikasi Terbaru";
String PIN = "PIN Anda";
String payName = "AMM-PAY";
String Jelajahi = "Jelajahi";
Map<String, dynamic> dataLogin = {}, dataSetting = {}, dataUser = {};
List<dynamic>? dataProvider, plnWarning;
String tabName = "TABUNGAN";
String defaultRekSumber = "";
String defaultNamaRekSumber = "";
String defaultPemilikNamaRekSumber = defaultRekSumber + " - " + defaultNamaRekSumber;
String currentRoutes = "/";

// updates
const MANDATORY_UPDATE = 'MANDATORY';
const NORMAL_UPDATE = 'NORMAL_UPDATE';
const NO_UPDATE = 'NO_UPDATE';
const MAINTENANCE = 'MAINTENANCE';

bool isPrintDecryptRequest = true;
