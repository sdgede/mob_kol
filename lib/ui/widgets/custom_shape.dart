import 'package:flutter/material.dart';

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height - 80);

    var firstEndPoint = Offset(size.width, 0);
    var firstControlPoint = Offset(size.width * .5, size.height / 1.5);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class CustomShapeClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height - 20);

    var firstEndPoint = Offset(size.width, size.height / 2);
    var firstControlPoint = Offset(size.width * 0.5, size.height + 10);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class CustomShapeClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstEndPoint = Offset(size.width, size.height / 1.25);
    var firstControlPoint = Offset(size.width * 0.5, size.height + 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class CustomClipper4 extends CustomClipper<Path> {
  final bool clipTop;
  final bool clipBottom;

  CustomClipper4([this.clipTop = false, this.clipBottom = false]);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    double x = 0;
    double y = size.height;
    double increment = size.width / 20;

    if (clipBottom) {
      path.lineTo(x + increment / 2, y);
      x += increment / 2;

      while (x < size.width) {
        x += increment;
        path.arcToPoint(Offset(x, y), radius: Radius.circular(1));
        path.lineTo(x + increment / 2, y);
        x += increment / 2;
      }
    } else {
      path.lineTo(size.width, size.height);
      x = size.width;
    }

    path.lineTo(size.width, 0.0);
    y = 0;
    path.lineTo(x - increment / 2, y);
    x -= increment / 2;

    if (clipTop) {
      while (x > 0) {
        x -= increment;
        path.arcToPoint(Offset(x, y), radius: Radius.circular(1));
        path.lineTo(x - increment / 2, y);
        x -= increment / 2;
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper old) {
    return old != this;
  }
}
