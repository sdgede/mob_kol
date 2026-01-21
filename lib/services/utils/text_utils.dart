import 'package:intl/intl.dart';
import 'dart:math';

import '../config/config.dart' as config;

class TextUtils {
  static TextUtils instance = TextUtils();

  String capitalizeEachWord(String str) {
    var splitStr = str.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
      splitStr[i] = splitStr[i][0].toUpperCase() + splitStr[i].substring(1);
    }
    return splitStr.join(' ');
  }

  String? getBulanString({dynamic date, String? bulan}) {
    var bln;
    if (date != null)
      bln = date.split('-')[1];
    else
      bln = bulan;
    switch (int.parse(bln)) {
      case 1:
        return "Januari";
      case 2:
        return "Februari";
      case 3:
        return "Maret";
      case 4:
        return "April";
      case 5:
        return "Mei";
      case 6:
        return "Juni";
      case 7:
        return "Juli";
      case 8:
        return "Agustus";
      case 9:
        return "September";
      case 10:
        return "Oktober";
      case 11:
        return "November";
      case 12:
        return "Desember";
    }
    return null;
  }

  String getHariString(dynamic day) {
    switch (int.parse(day)) {
      case 0:
        return "Minggu";
      case 1:
        return "Senin";
      case 2:
        return "Selasa";
      case 3:
        return "Rabu";
      case 4:
        return "Kamis";
      case 5:
        return "Jumat";
      case 6:
        return "Sabtu";
      default:
        return "";
    }
  }

  dynamic numberFormat(dynamic number, {isRp = true}) {
    String currencyId = "Rp. ";
    if (!isRp) currencyId = "";
    try {
      return NumberFormat.currency(locale: 'id', decimalDigits: 0).format(double.parse(number ?? '0')).toString().replaceAll("IDR", currencyId);
    } catch (e) {
      print("error number format with message: $e");
      return NumberFormat.currency(locale: 'id', decimalDigits: 0).format(double.parse('0')).toString().replaceAll("IDR", currencyId);
    }
  }

  dynamic getProvider(hp) {
    hp = hp.replaceAll(' ', '').substring(0, 4);
    for (var provider in config.dataProvider!) {
      if (provider['value'] == hp) {
        return provider['jenis_provider'];
      }
    }

    return null;
  }

  dynamic getMinutesFromIntervalTwoDate(firstDate, lastDate) {
    DateTime dateTimefirstDate = DateTime.parse(firstDate);
    DateTime dateTimelastDate = DateTime.parse(lastDate);
    final differenceInMinutes = dateTimefirstDate.difference(dateTimelastDate).inSeconds;
    return differenceInMinutes;
  }

  dynamic customDecrypt(String decrypt) {
    String reDecrypt;
    if (decrypt.substring(0, 8) == '{value: ') {
      reDecrypt = decrypt.substring(8, decrypt.length);
      reDecrypt = reDecrypt.substring(0, reDecrypt.length - 1);
    } else {
      reDecrypt = decrypt;
    }
    return reDecrypt;
  }

  String? getDateIndo(String? date) {
    if (date == null) return null;
    var newDate = date.split('-');
    String hari = newDate[0];
    String bulan = getBulanString(bulan: newDate[1]) as String;
    String tahunjam = newDate[2];
    return hari + " " + bulan + " " + tahunjam;
  }

  String getSmallDateIndo(String? date) {
    if (date == null) return "";
    var newDate = date.split('-');
    String hari = newDate[0];
    String bulan = getBulanString(bulan: newDate[1])!.substring(0, 3);
    var tahunjam = newDate[2].toString().split(' ');
    String tahun = tahunjam[0];
    return hari + " " + bulan + " " + tahun;
  }

  String getRandomString({int length = 64}) {
    Random _rnd = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  String? allToString(dynamic input) {
    if (input == null) return '';
    if (input is int || input is double) return '$input';
    if (input is String) return input;
    return null;
  }

  String allToStringStrict(dynamic input) {
    return (allToString(input) ?? '').trim();
  }
}
