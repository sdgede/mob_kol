import 'package:flutter/material.dart';

Widget CustomDbCrBox(BuildContext context, String trxType) {
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: trxType == 'DB' ? Colors.red.shade100 : Colors.green.shade100,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Center(
      child: Text(
        trxType.toUpperCase(),
        style: TextStyle(color: trxType == 'DB' ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
