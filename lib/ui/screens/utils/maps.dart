import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/global_provider.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  Completer<GoogleMapController> _controller = Completer();
  GlobalProvider? globalProvider;
  bool isDisabled = false;

  void currentLocation() async {
    final GoogleMapController controller = await _controller.future;

    await globalProvider!.loadLocation(context);

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(globalProvider!.latitude, globalProvider!.longitude),
        zoom: 20.0,
      ),
    ));
  }

  Future getLocation() async {
    final GoogleMapController controller = await _controller.future;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double middleX = screenWidth / 2;
    double middleY = screenHeight / 2;

    ScreenCoordinate screenCoordinate = ScreenCoordinate(x: middleX.round(), y: middleY.round());

    LatLng location = await controller.getLatLng(screenCoordinate);

    await globalProvider!.setLocation(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  @override
  void initState() {
    super.initState();

    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    currentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(builder: (context, globalProv, _) {
      return Scaffold(
        appBar: AppBarGoogleMaps(
          context: context,
          title: isDisabled ? null : globalProv.address,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onCameraMove: (_controller) {
                setState(() {
                  isDisabled = true;
                });
              },
              onCameraIdle: () async {
                setState(() {
                  isDisabled = false;
                });
                await getLocation();
              },
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                bearing: 0,
                target: LatLng(-8.6726769, 115.1542325),
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            centerFindLocationMarker(),
            buttonMyLocation(),
            buttonKonfirmasi(),
          ],
        ),
      );
    });
  }

  Widget buttonMyLocation() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 65, right: 20),
        width: 30,
        height: 30,
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

  Widget centerFindLocationMarker() {
    return Center(
      child: Container(
        width: 30,
        height: 40,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icon/marker_get_location.png'),
          ),
        ),
      ),
    );
  }

  Widget buttonKonfirmasi() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 40,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade300 : accentColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => null,
            child: Center(
              child: Text(
                "KONFIRMASI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
