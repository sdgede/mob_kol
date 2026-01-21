import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String? title;
  final String text;
  final String? clickOKText;
  final String? clickCancelText;
  final Function? onClickOK;
  final Function? onClickCancel;
  final bool? isCancel;

  InfoDialog({
    required this.text,
    this.onClickOK,
    this.title,
    this.clickOKText,
    this.clickCancelText,
    this.onClickCancel,
    this.isCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(title ?? "Peringatan!"),
      content: Text(text),
      actions: <Widget>[
        isCancel == null || isCancel == true
            ? TextButton(
                // color: Colors.red,
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                child: Text(
                  clickCancelText ?? "TIDAK",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  onClickCancel == null ? Navigator.of(context).pop(false) : onClickCancel!();
                },
              )
            : Container(),
        TextButton(
          // color: Colors.green,
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
          child: Text(
            clickOKText ?? "YAKIN",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            onClickOK == null ? Navigator.of(context).pop(true) : onClickOK!();
          },
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String? text;
  ErrorDialog({this.text});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text("Opps...!"),
      content: Text((text != null && text != '') ? text! : "Terjadi kesalahan saat terhubung ke server. CODE:500"),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
          child: Text(
            "TUTUP",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
