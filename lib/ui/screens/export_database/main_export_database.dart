import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/constant/constant.dart';
import 'package:provider/provider.dart';

class ExportDatabase extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExportDatabaseState();
}

class _ExportDatabaseState extends State<ExportDatabase> {
  GlobalProvider? globalProv;
  String _savePath = "storage/emulated/0";

  @override
  void initState() {
    super.initState();

    globalProv = Provider.of<GlobalProvider>(context, listen: false);
  }

  selectFolder() async {
    String? path = await FilesystemPicker.open(
      title: 'Simpan ke folder...',
      context: context,
      rootDirectory: Directory(_savePath),
      fsType: FilesystemType.folder,
      pickText: 'Pilih Folder',
      folderIconColor: accentColor,
    );

    setState(() {
      _savePath = path ?? _savePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(
        context,
        "Ekspor Database",
        isCenter: true,
        isRefresh: false,
      ),
      body: exportDatabase(),
    );
  }

  Widget exportDatabase() => Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Consumer<GlobalProvider>(
                    builder: (contex, globalProv, _) {
                      return Column(
                        children: <Widget>[SizedBox(height: 20), _headerInfo(globalProv), SizedBox(height: 10), _selectFolderBtn(), _exportBtn(context)],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _headerInfo(GlobalProvider globalProv) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 30),
          Image.asset(
            "assets/images/export_db.png",
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Simpan database dari aplikasi ke perangkat anda",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Pastikan memilih tempat menyimpan terlebih dahulu!",
              style: TextStyle(fontSize: 13, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Simpan di Folder : ",
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _savePath,
              style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _selectFolderBtn() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              selectFolder();
            },
            child: Center(
              child: Text(
                'Pilih Folder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _exportBtn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              globalProv!.exportDB(context, _savePath);
            },
            child: Center(
              child: Text(
                'Ekspor Database',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
