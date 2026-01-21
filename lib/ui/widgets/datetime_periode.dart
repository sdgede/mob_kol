import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:sevanam_mobkol/ui/constant/constant.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/viewmodel/transaksi_provider.dart';
import '../../services/viewmodel/produk_provider.dart';
import '../../services/viewmodel/global_provider.dart';

GlobalProvider? globalProv;
TransaksiProvider? trxProv;
final format = "dd-MM-yyyy";

Future<void> _showCalendarDialog({required BuildContext context, required DateTime initDate, required void Function(DateTime) onChange}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: SfDateRangePicker(
              todayHighlightColor: accentColor,
              selectionColor: primaryColor,
              selectionShape: DateRangePickerSelectionShape.circle,
              onSelectionChanged: (args) => onChange(args.value),
              initialSelectedDate: initDate,
              initialDisplayDate: initDate,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(accentColor)),
            child: Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget dateTimeField({required BuildContext context, required String title, required DateTime initDate, required void Function(DateTime) onChange}) {
  return TextFormField(
    controller: TextEditingController()..text = DateFormat(format).format(initDate),
    readOnly: true,
    canRequestFocus: false,
    onTap: () => _showCalendarDialog(context: context, initDate: initDate, onChange: onChange),
    decoration: InputDecoration(border: OutlineInputBorder(), labelText: title, prefixIcon: Icon(Iconsax.calendar), contentPadding: EdgeInsets.all(0)),
  );
}

Widget getDatePeriode(
  BuildContext context, {
  bool isKlad = false,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  Color? color,
  Function(DateTime)? fnChangeStart,
  Function(DateTime)? fnChangeEnd,
}) {
  return Consumer<ProdukCollectionProvider>(builder: (contex, produkProv, _) {
    return Container(
      color: color,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 0),
      margin: margin ?? EdgeInsets.only(top: 20),
      child: Consumer<ProdukCollectionProvider>(
        builder: (context, produkProv, _) {
          return Row(
            children: <Widget>[
              Expanded(
                  child: dateTimeField(
                context: contex,
                title: 'Tanggal Awal',
                initDate: produkProv.tglAwal,
                onChange: (currentValue) {
                  if (fnChangeStart != null) fnChangeStart(currentValue);

                  produkProv.setTglAwal(currentValue, true);
                  if (produkProv.tglAwal.difference(produkProv.tglAkhir).inDays < 1) {
                    produkProv.setMutasiLoading(true, true);
                    if (isKlad) produkProv.resetMutasiTransaksi();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Periode harus lebih dari 1 hari'),
                    ));
                  }
                },
              )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                  child: dateTimeField(
                context: contex,
                title: 'Tanggal Akhir',
                initDate: produkProv.tglAkhir,
                onChange: (currentValue) {
                  if (fnChangeEnd != null) fnChangeEnd(currentValue);

                  produkProv.setTglAkhir(currentValue, true);
                  if (produkProv.tglAkhir.difference(produkProv.tglAwal).inDays > 0) {
                    produkProv.setMutasiLoading(true, true);
                    if (isKlad) produkProv.resetMutasiTransaksi();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Periode harus lebih dari 1 hari'),
                    ));
                  }
                },
              )),
            ],
          );
        },
      ),
    );
  });
}

Widget getSingleDatePeriode(BuildContext context, {bool isKlad = false}) {
  return Consumer<ProdukCollectionProvider>(builder: (contex, produkProv, _) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      margin: EdgeInsets.only(top: 10),
      child: Consumer<ProdukCollectionProvider>(
        builder: (context, produkProv, _) {
          return Expanded(
              child: dateTimeField(
            context: contex,
            title: 'Pilih Tanggal',
            initDate: produkProv.tglAwal,
            onChange: (currentValue) {
              produkProv.setTglAwal(currentValue, true);
              if (produkProv.tglAwal.difference(produkProv.tglAkhir).inDays < 1) {
                produkProv.setMutasiLoading(true, true);
                if (isKlad) produkProv.resetMutasiTransaksi();
              }
            },
          ));
        },
      ),
    );
  });
}
