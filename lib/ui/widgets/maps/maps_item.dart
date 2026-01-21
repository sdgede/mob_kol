import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../services/utils/image_utils.dart';

class MapsItem extends StatefulWidget {
  final Completer<GoogleMapController>? controller;
  final LatLng? myLocation, merchantLocation;
  const MapsItem({
    Key? key,
    this.controller,
    this.myLocation,
    this.merchantLocation,
  }) : super(key: key);

  @override
  _MapsItemState createState() => _MapsItemState();
}

class _MapsItemState extends State<MapsItem> {
  BitmapDescriptor? iconMyLocation, iconMerchantLocation;

  Set<Marker> createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId(widget.myLocation.toString() + DateTime.now().millisecondsSinceEpoch.toString()),
        position: widget.myLocation!,
        icon: iconMyLocation!,
      ),
      Marker(
        markerId: MarkerId(widget.merchantLocation.toString() + DateTime.now().millisecondsSinceEpoch.toString()),
        position: widget.merchantLocation!,
        icon: iconMerchantLocation!,
      ),
    ].toSet();
  }

  void setIconMarker() async {
    var iconMyLocation1 = await ImageUtils.instance.getBytesFromAsset('assets/icon/marker_get_location.png', 70);
    var iconMerchantLocation1 = await ImageUtils.instance.getBytesFromAsset('assets/merchant/marker_merchant.png', 70);
    setState(() {
      iconMyLocation = BitmapDescriptor.fromBytes(iconMyLocation1);
      iconMerchantLocation = BitmapDescriptor.fromBytes(iconMerchantLocation1);
    });
  }

  @override
  Widget build(BuildContext context) {
    setIconMarker();
    return Stack(
      children: [
        GoogleMap(
          markers: createMarker(),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          initialCameraPosition: CameraPosition(
            bearing: 0,
            target: widget.merchantLocation!,
            zoom: 11,
          ),
          onMapCreated: (GoogleMapController controller) {
            widget.controller!.complete(controller);
          },
        ),
      ],
    );
  }
}
