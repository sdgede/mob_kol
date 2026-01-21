import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/transaksi_provider.dart';
import '../../constant/constant.dart';

class LottiePrimaryLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth(context),
      height: deviceHeight(context),
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: LottieBuilder.asset("assets/lottie/circle-loading.json"),
        ),
      ),
    );
  }
}

class LottieDownloadLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth(context),
      height: deviceHeight(context),
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: LottieBuilder.asset("assets/lottie/cloud_download.json"),
        ),
      ),
    );
  }
}

class LottieUploadLoader extends StatefulWidget {
  @override
  _LottieUploadLoaderState createState() => _LottieUploadLoaderState();
}

class _LottieUploadLoaderState extends State<LottieUploadLoader> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(builder: (contex, trxProv, _) {
      return Container(
        width: deviceWidth(context),
        height: deviceHeight(context),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: LottieBuilder.asset("assets/lottie/uploading_cloud.json"),
              ),
              Text(
                trxProv.countProgress.toString() + " of " + trxProv.maxProgressUpload.toString() + " Uploaded",
                style: TextStyle(fontSize: 17),
              )
            ],
          ),
        ),
      );
    });
  }
}
