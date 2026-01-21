import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../services/config/config.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/transaksi_provider.dart';
import '../../widgets/app_bar.dart';
import '../../constant/constant.dart';

class OTPScreen extends StatefulWidget {
  final Map? arguments;
  const OTPScreen({Key? key, this.arguments}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  TextEditingController boxOTPController = new TextEditingController();
  bool isFirst = true;
  var serverID = "-";
  var textSendOTP = "-";
  var timerString = "-";
  var hpwa = "-";
  var tipe = "SMS";
  var kodeOTP;
  var boxOTP = "";
  var count = 1;
  var requestOTPId;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? controller;
  TransaksiProvider? transaksiProvider;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  void generateOTP() async {
    bool cekRequestOTP = await transaksiProvider!.checkRequestOTP(context: context) ?? false;
    if (cekRequestOTP) {
      bool res = await DialogUtils.instance.showInfo(
            context: context,
            title: "Pemberitahuan!",
            text: dataSetting['otp_wa'] == "false" ? "Apakah Anda yakin meminta OTP? Rekening Sumber Dana Anda akan dipotong " + dataSetting['biaya_sms'] + " untuk biaya pengiriman SMS. Kode OTP akan dikirimkan ke nomor Handphone yang telah Anda daftarkan." : "Apakah Anda yakin meminta OTP? Kode OTP akan dikirimkan ke nomor WhatsApp yang telah Anda daftarkan.",
          ) ??
          false;
      if (res) {
        setState(() {
          if (dataSetting['otp_wa'] == "false")
            tipe = "SMS";
          else
            tipe = "WhatsApp";
        });

        String nomor = tipe == "SMS" ? dataLogin['hp'] : dataLogin['no_wa'];
        String jenis = tipe == "SMS" ? "Handphone" : "WhatsApp";
        String textError = "Nomor $jenis tidak valid. Silakan datang ke kantor $companyFullName untuk melakukan pemutakhiran data.";
        if (nomor == "" || nomor.length > 14) {
          DialogUtils.instance.showError(context: context, text: textError);
          return;
        }

        if (!["62", "08"].contains(nomor.substring(0, 2))) {
          DialogUtils.instance.showError(context: context, text: textError);
          return;
        }

        // await transaksiProvider.getOTPSMSWABerbayar(
        //     context: context, tipe: tipe);

        setHpWA(tipe == "SMS" ? dataLogin['hp'] : dataLogin['no_wa']);
        final time = TextUtils.instance.getMinutesFromIntervalTwoDate(
          transaksiProvider!.dataOTP.tglExpired,
          transaksiProvider!.dataOTP.tglRequest,
        );

        startCountdown(time ?? 0);

        setState(() {
          serverID = transaksiProvider!.dataOTP.serverId ?? "";
          isFirst = false;
          boxOTPController.text = "";
        });
      }
    }
  }

  void _validateOTP() async {
    if (boxOTP.length != 6) {
      DialogUtils.instance.showError(
        context: context,
        text: "Silakan masukkan Kode OTP terlebih dahulu.",
      );
    } else if (timerString == 'EXPIRED') {
      DialogUtils.instance.showError(
        context: context,
        text: "Maaf, Kode OTP Anda sudah EXPIRED.",
      );
    } else if (transaksiProvider!.dataOTP.serverId != serverID || transaksiProvider!.dataOTP.kodeOtp != boxOTP) {
      DialogUtils.instance.showError(
        context: context,
        text: "Maaf, Kode OTP yang Anda masukkan tidak valid.",
      );
    } else {
      // DialogUtils.instance.showTransaksi(
      //   context: context,
      //   arguments: widget.arguments,
      // );
    }
  }

  void setHpWA(noHpWa) {
    setState(() {
      var lengX = "";
      for (var i = 0; i < noHpWa.length - 4; i++) {
        lengX = lengX + "X";
      }
      hpwa = lengX + "" + noHpWa.substring(noHpWa.length - 4);
      textSendOTP = "Kami baru saja mengirim " + tipe + " 6 digit Kode OTP ke " + hpwa + " dengan SERVER ID : ";
    });
  }

  void startCountdown(time) {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: time),
    )..addListener(() {
        Duration duration = controller!.duration! * controller!.value;
        setState(() {
          if (controller!.value == 0.0) {
            timerString = "EXPIRED";
            serverID = "-";
          } else {
            timerString = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
          }
        });
      });

    controller!.reverse(from: controller!.value == 0.0 ? 1.0 : controller!.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: DefaultAppBar(context, "OTP", isCenter: true),
        key: scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: deviceHeightWithoutAppBar(context),
              width: deviceWidth(context),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _imageOTP,
                      _textOTP,
                      _getServerID,
                      _otpBox,
                      _countdown,
                      SizedBox(height: 10),
                      _resendOTP,
                    ],
                  ),
                  Expanded(child: Container()),
                  _buttonVerify,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  get _imageOTP {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: FlareActor(
        "assets/images/otp.flr",
        animation: "otp",
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
      ),
    );
  }

  get _textOTP {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: RichText(
        text: TextSpan(
          text: textSendOTP,
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  get _getServerID {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        serverID,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        textAlign: TextAlign.center,
      ),
    );
  }

  get _otpBox {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
      child: PinCodeTextField(
        appContext: context,
        controller: boxOTPController,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        animationDuration: Duration(milliseconds: 300),
        keyboardType: TextInputType.number,
        enableActiveFill: true,
        onCompleted: (v) {},
        enabled: isFirst ? false : true,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          activeFillColor: Colors.white,
          inactiveFillColor: Colors.white,
          selectedFillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            boxOTP = value;
          });
        },
      ),
    );
  }

  get _resendOTP {
    return !isFirst
        ? RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Tidak Menerima " + tipe + "? ",
              style: TextStyle(color: Colors.black54, fontSize: 15),
              children: [
                TextSpan(
                  text: "Kirim Ulang",
                  recognizer: TapGestureRecognizer()..onTap = () => generateOTP(),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                )
              ],
            ),
          )
        : Container();
  }

  get _buttonVerify {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: !isFirst ? _validateOTP : generateOTP,
            child: Center(
              child: Text(
                !isFirst ? "KONFIRMASI" : "GENERATE OTP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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

  get _countdown {
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, child) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              timerString,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}
