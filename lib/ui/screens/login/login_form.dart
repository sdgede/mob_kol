import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../database/databaseHelper.dart';
import '../../../ui/widgets/floating_action_button.dart';
import '../../../services/config/config.dart';
import '../../../services/utils/location_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../constant/constant.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;
  bool _isVisible = false;
  FocusNode? _usernameNode, _passwordNode;
  String? _username, _password, platform;
  GlobalProvider? globalProv;

  @override
  void initState() {
    super.initState();
    _usernameNode = FocusNode();
    _passwordNode = FocusNode();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _usernameNode!.dispose();
    _passwordNode!.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    EasyLoading.show(status: Loading);
    var isLocation = await LocationUtils.instance.getLocation(context);
    if (isLocation != null) {
      await globalProv!.getLogin(context, _username!, _password!);
      //Navigator.pushReplacementNamed(context, RouterGenerator.homeKolektor);
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1334));
    // ScreenUtil.instance =
    //     ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Scaffold(
          floatingActionButton: floatingActionSwitchMode(context),
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  // autovalidate: _autoValidate,
                  child: Container(
                    // padding: EdgeInsets.only(
                    //   left: 10.0,
                    //   right: 10.0,
                    // ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(bgCustom),
                              fit: BoxFit.cover,
                            ),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black87.withOpacity(.3),
                            //     offset: Offset(0.0, 8.0),
                            //     blurRadius: 5.0,
                            //   )
                            // ],
                          ),
                          width: deviceWidth(context),
                          height: 500,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: 130,
                                height: 130,
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: deviceHeight(context) / 4),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: ScreenUtil().setHeight(30),
                              ),
                              _formCard,
                              SizedBox(
                                height: ScreenUtil().setHeight(40),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(30),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  get _loginButton {
    return Container(
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, primaryColor],
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final form = _formKey.currentState;
            if (form!.validate()) {
              form.save();
              _login(context);
            }
            //_testRowCount();
          },
          child: Center(
            child: Text(
              "LOGIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  get _formCard {
    return Container(
      width: double.infinity,
      height: deviceHeight(context) - 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Login",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(45),
                letterSpacing: .6,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(30)),
            Text(
              "Username",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
            TextFormField(
              focusNode: _usernameNode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Username",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
              onSaved: (String? value) => _username = value,
              onFieldSubmitted: (term) {
                _usernameNode!.unfocus();
                FocusScope.of(context).requestFocus(_passwordNode);
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "Username Masih Kosong!";
                }
                return null;
              },
            ),
            SizedBox(height: ScreenUtil().setHeight(30)),
            Text(
              "Password",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
            Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                TextFormField(
                  focusNode: _passwordNode,
                  obscureText: _isVisible ? false : true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                  onSaved: (String? value) => _password = value,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password Masih Kosong!";
                    }
                    return null;
                  },
                ),
                IconButton(
                  icon: _isVisible ? Icon(
                      // FlutterIcons.ios_eye_ion
                      Iconsax.eye) : Icon(
                      // FlutterIcons.ios_eye_off_ion
                      Iconsax.eye_slash),
                  onPressed: () {
                    setState(() {
                      _isVisible ? _isVisible = false : _isVisible = true;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(50)),
            _loginButton
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     Text(
            //       config.ForgetPassword,
            //       style: TextStyle(
            //         color: Colors.blue,
            //         fontSize: ScreenUtil().setSp(28),
            //         decoration: TextDecoration.underline,
            //       ),
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
