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

class ResetPassword extends StatefulWidget {
  final bool isBuat;
  const ResetPassword({Key? key, this.isBuat = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool autoValidate = false, isVisible = false, isVisible1 = false, isVisible2 = false;
  TextEditingController passwordLamaController = new TextEditingController(), passwordController = new TextEditingController(), rePasswordController = new TextEditingController(), sumberDanaController = new TextEditingController();
  GlobalProvider? globalProv;
  TransaksiProvider? transaksiProvider;

  void savePassword() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      bool isReset = true;
      if (passwordLamaController.text != McryptUtils.instance.decrypt(dataLogin['password'])) {
        isReset = false;
        DialogUtils.instance.showError(
          context: context,
          text: "Password lama yang Anda massukan salah!",
        );
      }
      if (isReset) {
        if (widget.isBuat) {
          bool res = await globalProv!.resetPassword(context, passwordController.text, widget.isBuat);
          if (widget.isBuat && res) {
            Navigator.of(context).pushReplacementNamed(RouterGenerator.resetPin, arguments: {'isBuat': widget.isBuat});
          }
        } else {
          // Navigator.of(context).pushNamed(
          //   RouterGenerator.otpScreen,
          //   arguments: {
          //     'tipe': 'GANTI_PASSWORD',
          //     'isBuat': widget.isBuat,
          //     'password': passwordController.text,
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
    transaksiProvider!.setTipeOTP("GANTI_PASSWORD");
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
          key: scaffoldKey,
          appBar: DefaultAppBar(
            context,
            "Ganti Password",
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
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: <Widget>[
                                if (!widget.isBuat) _inputTextSumberDana(),
                                _inputText(
                                  desc: "Password Lama",
                                  isFirst: widget.isBuat ? true : false,
                                  isLast: false,
                                  isLeft: true,
                                  textController: passwordLamaController,
                                  isVisible: isVisible,
                                  isOldPassword: true,
                                  onVisible: () {
                                    setState(() {
                                      isVisible ? isVisible = false : isVisible = true;
                                    });
                                  },
                                ),
                                _inputText(
                                  desc: "Password Baru",
                                  isFirst: false,
                                  isLast: false,
                                  isLeft: true,
                                  textController: passwordController,
                                  isVisible: isVisible1,
                                  onVisible: () {
                                    setState(() {
                                      isVisible1 ? isVisible1 = false : isVisible1 = true;
                                    });
                                  },
                                ),
                                _inputText(
                                  desc: "Ulangi Password Baru",
                                  isFirst: false,
                                  isLast: false,
                                  isLeft: true,
                                  textController: rePasswordController,
                                  isRePassword: true,
                                  isVisible: isVisible2,
                                  onVisible: () {
                                    setState(() {
                                      isVisible2 ? isVisible2 = false : isVisible2 = true;
                                    });
                                  },
                                ),
                                textPassword(),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                          simpanPassword()
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

  Widget textPassword() {
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
              textKetentuanPassword(text: "Password bersifat rahasia dan jangan diberikan kepada siapa pun dengan alasan apapun termasuk pihak " + companyFullName + "."),
              textKetentuanPassword(text: "Password wajib berawalan dengan huruf kapital dan mengandung angka."),
              textKetentuanPassword(text: "Panjang minimal password adalah 8 digit."),
            ],
          ),
        ),
      ),
    );
  }

  Widget textKetentuanPassword({String? text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            "*",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
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
    bool isRePassword = false,
    bool isOldPassword = false,
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
              Stack(alignment: Alignment.centerRight, children: <Widget>[
                TextFormField(
                  controller: textController,
                  keyboardType: TextInputType.text,
                  obscureText: isVisible! ? false : true,
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
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return desc! + " masih kosong!";
                    }
                    if (value.length < 8 && !isOldPassword) {
                      return "Panjang karakter minimal 8 digit!";
                    }
                    if (isRePassword && passwordController.text != value) {
                      return "Password yang dimasukkan berbeda!";
                    }
                    if (value[0] != value[0].toUpperCase() && !isOldPassword) {
                      return "Karakter pertama harus huruf kapital!";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                IconButton(
                  icon: isVisible ? Icon(
                      // FlutterIcons.ios_eye_ion
                      Iconsax.eye) : Icon(
                      // FlutterIcons.ios_eye_off_ion
                      Iconsax.eye_slash),
                  onPressed: () => onVisible!(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget simpanPassword() {
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
            onTap: savePassword,
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
