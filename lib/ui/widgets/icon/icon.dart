import 'package:flutter/material.dart';

class IconRoundedWithTextInBottom extends StatelessWidget {
  final String text;
  final Color color;
  final Icon icon;
  IconRoundedWithTextInBottom(this.icon, this.color, this.text);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          height: 50,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: icon,
        ),
        Text(text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Colors.black45,
              fontSize: 7,
            ))
      ],
    ));
  }
}

class SocialIcon extends StatelessWidget {
  final List<Color>? colors;
  final IconData? iconData;
  final Function? onPressed;
  SocialIcon({this.colors, this.iconData, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(left: 14.0),
      child: Container(
        width: 45.0,
        height: 45.0,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: colors!, tileMode: TileMode.clamp)),
        child: RawMaterialButton(
          shape: CircleBorder(),
          onPressed: onPressed != null ? () => onPressed!() : null,
          child: Icon(iconData, color: Colors.white),
        ),
      ),
    );
  }
}
