import 'package:flutter/material.dart';

Widget btnTxtAndIcon({
  BuildContext? context,
  Color icColor = Colors.black,
  Color txtColor = Colors.black,
  IconData? icon,
  String label = '',
  Function? onTap,
  bool isEnable = true,
}) {
  return TextButton.icon(
    // disabledColor: Colors.grey,
    // padding: EdgeInsets.all(0),
    style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => states.contains(MaterialState.disabled) ? Colors.grey : Colors.transparent,
        ),
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>((Set<MaterialState> states) => EdgeInsets.all(0))),
    onPressed: () => isEnable == true ? onTap!() : null,
    icon: Icon(
      icon,
      color: isEnable ? icColor : Colors.grey,
    ),
    label: Text(
      label,
      style: TextStyle(
        color: isEnable ? txtColor : Colors.grey,
      ),
    ),
  );
}
