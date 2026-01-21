import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';

import '../config/config.dart';
import '../utils/dialog_utils.dart';

class LocationUtils {
  double? latitude;
  double? longitude;
  static LocationUtils instance = LocationUtils();

  Future getLocation(BuildContext context, {bool isLoading = false}) async {
    if (isLoading) EasyLoading.show(status: Loading);
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    // }

    if (!_serviceEnabled) {
      EasyLoading.dismiss();
      await DialogUtils.instance.showInfo(
        isCancel: false,
        context: context,
        clickOKText: "OK",
        title: "Opps...",
        text: 'Pastikan Anda mengaktifkan GPS dan coba lagi',
      );
      return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        EasyLoading.dismiss();
        await DialogUtils.instance.showInfo(
          isCancel: false,
          context: context,
          clickOKText: "OK",
          title: "Opps...",
          text: 'Pastikan Anda mengizinkan $companyName untuk mengakses lokasi Anda.',
        );
        return;
      }
    }

    EasyLoading.dismiss();
    _locationData = await location.getLocation();
    latitude = _locationData.latitude;
    longitude = _locationData.longitude;
    return true;
  }

  Future getLocationOnly() async {
    Location location = new Location();
    bool _serviceEnabled = await location.serviceEnabled();
    return _serviceEnabled;
  }

  Future<String> getAddress() async {
    String finalAddress = 'Alamat tidak ditemukan';

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude!, longitude!);

      if (placemarks.isNotEmpty) {
        geo.Placemark firstPlacemark = placemarks.first;
        String address = '${firstPlacemark.subThoroughfare} ${firstPlacemark.thoroughfare}, ${firstPlacemark.subLocality}, ${firstPlacemark.locality}, ${firstPlacemark.country}';

        finalAddress = address;
      } else {
        print('Geocoding error: Alamat tidak ditemukan.');
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    print("Geocoding result address: $finalAddress");
    return finalAddress;
  }

  Future<String> getAddressByCoordinates({
    @required double? latitude,
    @required double? longitude,
  }) async {
    String finalAddress = 'Alamat tidak ditemukan';

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude!, longitude!);

      if (placemarks.isNotEmpty) {
        geo.Placemark firstPlacemark = placemarks.first;
        String address = '${firstPlacemark.subThoroughfare} ${firstPlacemark.thoroughfare}, ${firstPlacemark.subLocality}, ${firstPlacemark.locality}, ${firstPlacemark.country}';

        finalAddress = address;
      } else {
        print('Geocoding error: Alamat tidak ditemukan.');
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    print("Geocoding result address: $finalAddress");
    return finalAddress;
  }

  Future<Map<String, dynamic>> getDistanceTime({
    double? latitude1,
    double? longitude1,
    double? latitude2,
    double? longitude2,
  }) async {
    Dio dio = new Dio();
    Response response = await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=" + latitude1.toString() + "," + longitude1.toString() + "&destinations=" + latitude2.toString() + "," + longitude2.toString() + "&language=id&key=" + (Platform.isAndroid ? apiMapMobile : apiMapIOS));

    if (response.data == null) return {'distance': "0", 'time': "0 menit"};

    return {
      'distanceValue': response.data['rows'][0]['elements'][0]['distance']['value'],
      'distance': (response.data['rows'][0]['elements'][0]['distance']['value'] / 1000).toStringAsFixed(2) + " km",
      'time': response.data['rows'][0]['elements'][0]['duration']['text'].replaceAll('min', 'menit'),
    };
  }

  String calculateDistance({
    @required double? latitude1,
    @required double? longitude1,
    @required double? latitude2,
    @required double? longitude2,
  }) {
    double theta = longitude1! - longitude2!;
    double dist = sin(deg2rad(latitude1!)) * sin(deg2rad(latitude2!)) + cos(deg2rad(latitude1)) * cos(deg2rad(latitude2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    dist = dist * 1.609344;
    return dist.toStringAsFixed(2);
  }

  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

  String estimateTime(String distance) {
    double waktu = double.parse(distance) / 40;
    double minutes = double.parse((waktu * 60).toStringAsFixed(0));
    String estimasi;
    if (minutes > 60) {
      String jam = (minutes / 60).toStringAsFixed(0);
      String menit = (minutes % 60).toStringAsFixed(0);
      estimasi = jam + " jam " + menit + " menit";
    } else {
      estimasi = minutes.toString() + " menit";
    }
    return estimasi;
  }
}
