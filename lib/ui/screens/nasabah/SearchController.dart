import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SearchController extends StatefulWidget {
  final Function? onClick;
  final Function(String)? onSubmit;
  final TextEditingController? controller;
  final bool readOnly;
  final bool autoFocus;
  final String? placeHolder;

  SearchController({
    this.onClick,
    this.onSubmit,
    required this.controller,
    this.readOnly = false,
    this.autoFocus = false,
    this.placeHolder,
  });

  @override
  _SearchCOntrollerState createState() => _SearchCOntrollerState();
}

class _SearchCOntrollerState extends State<SearchController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: <Widget>[
            Icon(
                // FlutterIcons.ios_search_ion,
                Iconsax.search_normal_1,
                size: 20,
                color: Colors.black54),
            SizedBox(width: 5),
            Expanded(
              child: TextField(
                controller: widget.controller,
                textInputAction: TextInputAction.done,
                onTap: () => widget.onClick != null ? widget.onClick!() : {},
                keyboardType: TextInputType.text,
                readOnly: widget.readOnly,
                autofocus: widget.autoFocus,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                ),
                onSubmitted: (value) => widget.onSubmit != null ? widget.onSubmit!(value) : {},
                decoration: InputDecoration(
                  hintText: widget.placeHolder ?? "Cari Nasabah",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
