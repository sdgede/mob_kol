import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/utils/url_launcher_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/constant/constant.dart';
import 'package:provider/provider.dart';
import '../../../services/config/config.dart' as config;

class UpdatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  GlobalProvider? globalProv;

  @override
  void initState() {
    super.initState();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments as dynamic;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: updatePageBody(args['route']),
    );
  }

  Widget updatePageBody(String route) => Container(
        child: Container(
          width: deviceWidth(context),
          height: deviceHeight(context),
          margin: EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        ImageNetwork(urlImage: config.ConfigURL().urlImg + globalProv!.updateInfo!.img!),
                        SizedBox(height: 30),
                        Html(
                          data: '<h3>${globalProv!.updateInfo!.title}</h3>${globalProv!.updateInfo!.desc}',
                          style: {"h3": Style(textAlign: TextAlign.center)},
                        ),
                      ],
                    ),
                  ),
                ),
                if (globalProv!.updateInfo!.type != config.MAINTENANCE) _updateButton(globalProv!.updateInfo!.url!),
                if (globalProv!.updateInfo!.type != config.MANDATORY_UPDATE && globalProv!.updateInfo!.type != config.MAINTENANCE) _ignoreButton(route)
              ],
            ),
          ),
        ),
      );

  _ignoreButton(String route) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, route);
        },
        child: Text(
          "Nanti saja",
          style: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  _updateButton(String url) {
    return Container(
      height: ScreenUtil().setHeight(40),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(.3),
            offset: Offset(0.0, 5.0),
            blurRadius: 8.0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            UrlLauncherUtils.instance.launchBrowser(browser: url);
          },
          child: Center(
            child: Text(
              "UPDATE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageNetwork extends StatelessWidget {
  final String urlImage;

  const ImageNetwork({Key? key, required this.urlImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      urlImage,
      fit: BoxFit.fill,
      height: ScreenUtil().setHeight(250),
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: ScreenUtil().setHeight(150),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          ),
        );
      },
    );
  }
}
