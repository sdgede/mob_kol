import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr;
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCode extends StatelessWidget {
  const QrCode({Key? key, required this.produkData}) : super(key: key);

  final String produkData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: 260,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: QrImage(
          data: produkData,
          version: QrVersions.auto,
          // size: 320,
          imageSize: Size(320, 320),
          // gapless: false,
          embeddedImage: AssetImage('assets/images/logo_qr.png'),
          // embeddedImageStyle: QrEmbeddedImageStyle(
          //   size: Size(50, 50),
          // ),
        ),
      ),
    );
  }
}

class QrImage extends StatelessWidget {
  final String? data;
  final int version;
  final int errorCorrectionLevel;
  final Color color;
  final Color backgroundColor;
  final ImageProvider<dynamic>? embeddedImage;
  final Size? imageSize;

  const QrImage({
    Key? key,
    this.data,
    this.version = 4,
    this.errorCorrectionLevel = qr.QrErrorCorrectLevel.M,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
    this.embeddedImage,
    this.imageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qr.QrPainter _painter = qr.QrPainter(
      data: data!,
      version: qr.QrVersions.auto,
      errorCorrectionLevel: errorCorrectionLevel,
      gapless: true,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        color: color,
      ),
    );

    return FutureBuilder<ByteData>(
      future: _painter.toImageData(300.0) as Future<ByteData>?,
      builder: (BuildContext context, AsyncSnapshot<ByteData> snapshot) {
        return AnimatedCrossFade(
          firstChild: Container(
            color: backgroundColor,
            alignment: Alignment.center,
          ),
          secondChild: Builder(builder: (BuildContext context) {
            if (snapshot.data == null) {
              return Center(
                child: Text('No data provided.'),
              );
            }

            return Image.memory(
              snapshot.data!.buffer.asUint8List(),
              fit: BoxFit.contain,
            );
          }),
          crossFadeState: snapshot.connectionState == ConnectionState.done ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  key: bottomChildKey,
                  left: 0.0,
                  top: 0.0,
                  right: 0.0,
                  child: bottomChild,
                ),
                Positioned.fill(
                  key: topChildKey,
                  child: topChild,
                ),
                Center(
                  child: Container(
                    height: imageSize != null ? imageSize!.height : null,
                    width: imageSize != null ? imageSize!.width : null,
                    child: Image(image: embeddedImage as ImageProvider<Object>),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
