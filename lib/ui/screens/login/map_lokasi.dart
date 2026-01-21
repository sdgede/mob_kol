import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../services/utils/image_utils.dart';
import '../../../services/utils/text_utils.dart';
import '../../widgets/app_bar.dart';

class MapLokasiScreen extends StatefulWidget {
  final LatLng? lokasiKantor;
  final String? namaKantor;
  const MapLokasiScreen({
    Key? key,
    this.lokasiKantor,
    this.namaKantor,
  }) : super(key: key);

  @override
  _MapLokasiScreenState createState() => _MapLokasiScreenState();
}

class _MapLokasiScreenState extends State<MapLokasiScreen> {
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor? iconLokasiKantor;

  void currentLocation() async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: widget.lokasiKantor!,
        zoom: 16.0,
      ),
    ));
  }

  Set<Marker> createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId(widget.lokasiKantor.toString() + DateTime.now().millisecondsSinceEpoch.toString()),
        position: widget.lokasiKantor!,
        icon: iconLokasiKantor!,
      ),
    ].toSet();
  }

  void setIconMarker() async {
    var iconLokasiKantor1 = await ImageUtils.instance.getBytesFromAsset('assets/icon/office_marker.png', 70);
    setState(() {
      iconLokasiKantor = BitmapDescriptor.fromBytes(iconLokasiKantor1);
    });
  }

  @override
  Widget build(BuildContext context) {
    setIconMarker();
    return Scaffold(
      appBar: AppBarGoogleMaps(
        context: context,
        title: "Lokasi " + TextUtils.instance.capitalizeEachWord(widget.namaKantor!),
      ),
      body: Stack(
        children: [
          GoogleMap(
            markers: createMarker(),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              bearing: 0,
              target: widget.lokasiKantor!,
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          buttonMyLocation(),
        ],
      ),
    );
  }

  Widget buttonMyLocation() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 20, right: 20),
        width: 50,
        height: 50,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              // FlutterIcons.my_location_mdi,
              Iconsax.location,
              color: Colors.grey,
            ),
            onPressed: currentLocation,
          ),
        ),
      ),
    );
  }
}
