import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../services/config/config.dart';
import '../../../services/config/router_generator.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/viewmodel/transaksi_provider.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/utils/mcrypt_utils.dart';
import '../../constant/constant.dart';
import '../../widgets/dialog/produk_dialog.dart';
import '../../widgets/app_bar.dart';

class ResetPin extends StatefulWidget {
  final bool isBuat;
  const ResetPin({Key? key, this.isBuat = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResetPinState();
}

class _ResetPinState extends State<ResetPin> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool autoValidate = false, isVisible = false, isVisible1 = false, isVisible2 = false;
  TextEditingController pinLamaController = new TextEditingController(), pinController = new TextEditingController(), rePinController = new TextEditingController(), sumberDanaController = new TextEditingController();
  GlobalProvider? globalProv;
  TransaksiProvider? transaksiProvider;

  void savePin() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      bool isReset = true;
      if (pinLamaController.text != McryptUtils.instance.decrypt(dataLogin['pin'])) {
        isReset = false;
        DialogUtils.instance.showError(
          context: context,
          text: "PIN lama yang Anda massukan salah!",
        );
      }
      if (isReset) {
        if (widget.isBuat) {
          bool res = await globalProv!.resetPin(context, pinController.text, widget.isBuat);
          if (widget.isBuat && res) {
            Navigator.of(context).pushReplacementNamed(RouterGenerator.pageHomeLogin);
          }
        } else {
          // Navigator.of(context).pushNamed(
          //   RouterGenerator.otpScreen,
          //   arguments: {
          //     'tipe': 'GANTI_PIN',
          //     'isBuat': widget.isBuat,
          //     'pin': pinController.text,
          //   },
          // );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    transaksiProvider!.setTipeOTP("GANTI_PIN");
    transaksiProvider!.resetRequestOTP();
  }

  Future<bool> _onBackPressed() async {
    if (widget.isBuat)
      return (await DialogUtils.instance.onBackPressedBackProses(
        context: context,
        navigator: RouterGenerator.pageHomeLogin,
      ));
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: scaffoldKey,
          appBar: DefaultAppBar(
            context,
            "Ganti PIN",
            isCenter: true,
            onBack: widget.isBuat
                ? () async {
                    await DialogUtils.instance.dialogBackProses(
                      context: context,
                      navigator: RouterGenerator.pageHomeLogin,
                      isSave: true,
                    );
                  }
                : null,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: deviceWidth(context),
                height: deviceHeightWithoutAppBar(context),
                child: Consumer<ProdukTabunganProvider>(
                  builder: (context, produkTabunganProv, _) {
                    sumberDanaController.text = produkTabunganProv.pemilikNamaRekSumber;
                    return Form(
                      key: formKey,
                      // autovalidate: autoValidate,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: ListView(
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: <Widget>[
                                if (!widget.isBuat) _inputTextSumberDana(),
                                _inputText(
                                  desc: "PIN Lama",
                                  isFirst: widget.isBuat ? true : false,
                                  isLast: false,
                                  isLeft: true,
                                  textController: pinLamaController,
                                  isVisible: isVisible,
                                  onVisible: () {
                                    setState(() {
                                      isVisible ? isVisible = false : isVisible = true;
                                    });
                                  },
                                ),
                                _inputText(
                                  desc: "PIN Baru",
                                  isFirst: false,
                                  isLast: false,
                                  isLeft: true,
                                  textController: pinController,
                                  isVisible: isVisible1,
                                  onVisible: () {
                                    setState(() {
                                      isVisible1 ? isVisible1 = false : isVisible1 = true;
                                    });
                                  },
                                ),
                                _inputText(
                                  desc: "Ulangi PIN Baru",
                                  isFirst: false,
                                  isLast: false,
                                  isLeft: true,
                                  textController: rePinController,
                                  isRePin: true,
                                  isVisible: isVisible2,
                                  onVisible: () {
                                    setState(() {
                                      isVisible2 ? isVisible2 = false : isVisible2 = true;
                                    });
                                  },
                                ),
                                textPin(),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                          simpanPin()
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textPin() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: accentColor),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            children: [
              textKetentuanPin(text: "Pin bersifat rahasia dan jangan diberikan kepada siapa pun dengan alasan apapun termasuk pihak " + companyFullName + "."),
              textKetentuanPin(text: "Panjang pin adalah 6 digit."),
            ],
          ),
        ),
      ),
    );
  }

  Widget textKetentuanPin({String? text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "*",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            text!,
            style: TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget _inputText({
    String? desc,
    bool? isFirst,
    bool? isLast,
    bool? isLeft,
    TextEditingController? textController,
    bool? isVisible,
    Function? onVisible,
    bool isRePin = false,
  }) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: accentColor),
          borderRadius: BorderRadius.only(
            topLeft: isFirst! ? Radius.circular(8) : Radius.zero,
            topRight: isFirst ? Radius.circular(8) : Radius.zero,
            bottomLeft: isLast! ? Radius.circular(8) : Radius.zero,
            bottomRight: isLast ? Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            children: <Widget>[
              Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  TextFormField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    obscureText: isVisible! ? false : true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: desc,
                      labelText: desc,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.black),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.only(top: 10),
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return desc! + " masih kosong!";
                      }
                      if (value.length < 6) {
                        return "Panjang PIN adalah 6 digit!";
                      }
                      if (isRePin && pinController.text != value) {
                        return "PIN yang dimasukkan berbeda!";
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  IconButton(
                    icon: isVisible ? Icon(Iconsax.eye) : Icon(Iconsax.eye_slash),
                    onPressed: () => onVisible!(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget simpanPin() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: savePin,
            child: Center(
              child: Text(
                widget.isBuat ? "SIMPAN" : "LANJUT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputTextSumberDana() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: accentColor),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            children: <Widget>[
              Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  TextFormField(
                    controller: sumberDanaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Klik untuk memilih sumber dana",
                      labelText: "Sumber Dana",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.black),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.only(top: 10),
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Icon(
                          // FlutterIcons.ios_arrow_down_ion,
                          Iconsax.arrow_down,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Sumber dana masih kosong!";
                      }
                      return null;
                    },
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ProdukDialog(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
