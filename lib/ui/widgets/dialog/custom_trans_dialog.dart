import 'package:provider/provider.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/material.dart';

import '../../../model/produk_model.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/viewmodel/transaksi_provider.dart';
import '../../../services/config/config.dart' as config;
import '../../constant/constant.dart';

class CustomTransDialog extends StatefulWidget {
  final DetailProdukCollection? produkModel;
  final String? title, groupProduk, rekCd, tipeTrans, norek;
  final String? img, produkId;

  const CustomTransDialog({
    Key? key,
    this.title,
    this.groupProduk,
    this.rekCd,
    this.img,
    this.tipeTrans,
    this.norek,
    this.produkId,
    this.produkModel,
  }) : super(key: key);

  @override
  _CustomTransDialogState createState() => _CustomTransDialogState();
}

class _CustomTransDialogState extends State<CustomTransDialog> {
  static const double padding = 20;
  static const double avatarRadius = 45;
  bool btnStatus = false;
  String _rekCd = '0', _groupProduk = '0', _produkId = '0', _tipeTrans = '0';
  String _norek = '0', _jumlah = '0', _remark = '-', _formValue = '0';
  String _bungaParse = '0', _pokokParse = '0', _dendaParse = '0';
  String _totBayarParse = '0', _lateCharge = '0';

  int _bunga = 0, _pokok = 0, _denda = 0, _lateCHarge = 0;
  int _totBayar = 0;

  String _pesanStatusTransaksi = "-";
  ProdukCollectionProvider? produkProvider;
  TransaksiProvider? transaksiPorvider;
  GlobalProvider? globalProv;
  MoneyMaskedTextController nominalController = MoneyMaskedTextController(decimalSeparator: '', thousandSeparator: '.', precision: 0);
  MoneyMaskedTextController bungaController = MoneyMaskedTextController(decimalSeparator: '', thousandSeparator: '.', precision: 0);
  MoneyMaskedTextController dendaController = MoneyMaskedTextController(
    decimalSeparator: '',
    thousandSeparator: '.',
    precision: 0,
    initialValue: 0,
  );
  MoneyMaskedTextController lateChargeController = MoneyMaskedTextController(decimalSeparator: '', thousandSeparator: '.', precision: 0);
  MoneyMaskedTextController pokokController = MoneyMaskedTextController(decimalSeparator: '', thousandSeparator: '.', precision: 0);
  TextEditingController keteranganController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    transaksiPorvider = Provider.of<TransaksiProvider>(context, listen: false);
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    globalProv!.loadLocation(context);
    _formValue = 'FORM_INPUT';
    if (widget.groupProduk == 'KREDIT') _setFormKredit();
    checkButtonLanjut();
    print("$_formValue $_totBayarParse $_lateCharge $_lateCHarge $_pesanStatusTransaksi");
  }

  void _setFormKredit() {
    if (widget.tipeTrans == 'PELUNASAN') {
      _pokok = int.parse(widget.produkModel!.baki_debet);
      _bunga = int.parse(widget.produkModel!.tunggakan_bunga);
      _denda = int.parse(widget.produkModel!.denda);
    } else {
      _pokok = int.parse(widget.produkModel!.pokok_bln_ini);
      _bunga = int.parse(widget.produkModel!.bnga_bln_ini);
      _denda = int.parse(widget.produkModel!.denda);
    }
    _totBayar = _pokok + _bunga + _denda;

    pokokController.text = _pokok.toString();
    bungaController.text = _bunga.toString();
    dendaController.text = _denda.toString();
    nominalController.text = _totBayar.toString();
  }

  void _hitungPembayaranKredit(int jmlhBayar) {
    int _getDenda = int.parse(dendaController.text.replaceAll(".", ""));
    int _getBunga = int.parse(bungaController.text.replaceAll(".", ""));
    int _getPokok = int.parse(pokokController.text.replaceAll(".", ""));

    var _currentMoney = 0;
    var _currentDenda = 0;
    var _currentBunga = 0;
    var _currentPokok = 0;

    if (jmlhBayar >= _getDenda) {
      _currentDenda = _getDenda;
      _currentMoney = jmlhBayar - _getDenda;
      if (_currentMoney >= _getBunga) {
        _currentBunga = _getBunga;
        _currentMoney = _currentMoney - _getBunga;
        if (_currentMoney >= _getPokok) {
          _currentPokok = _currentMoney;
        } else {
          _currentPokok = _currentMoney;
        }
      } else {
        _currentBunga = _currentMoney;
      }
    } else {
      _currentDenda = jmlhBayar;
    }

    setState(() {
      dendaController.text = _currentDenda.toString();
      bungaController.text = _currentBunga.toString();
      pokokController.text = _currentPokok.toString();
    });
  }

  //THIS METHOD INCLUDE LATE CHARGE
  // void _hitungPembayaranKredit(int jmlhBayar) {
  //   var _currentMoney = 0;
  //   var _currentDenda = 0;
  //   var _currentBunga = 0;
  //   var _currentPokok = 0;
  //   var _currentLateCharge = 0;

  //   if (jmlhBayar >= _lateCHarge) {
  //     _currentLateCharge = _lateCHarge;
  //     _currentMoney = jmlhBayar - _lateCHarge;
  //     if (_currentMoney >= _denda) {
  //       _currentDenda = _denda;
  //       _currentMoney = _currentMoney - _denda;
  //       if (_currentMoney >= _bunga) {
  //         _currentBunga = _bunga;
  //         _currentMoney = _currentMoney - _bunga;
  //         if (_currentMoney >= _pokok) {
  //           _currentPokok = _currentMoney;
  //         } else {
  //           _currentPokok = _currentMoney;
  //         }
  //       } else {
  //         _currentBunga = _currentMoney;
  //       }
  //     } else {
  //       _currentDenda = _currentMoney;
  //     }
  //   } else {
  //     _currentLateCharge = jmlhBayar;
  //   }

  //   setState(() {
  //     dendaController.text = _currentDenda.toString();
  //     bungaController.text = _currentBunga.toString();
  //     pokokController.text = _currentPokok.toString();
  //     lateChargeController.text = _currentLateCharge.toString();
  //   });
  // }

  void checkButtonLanjut() {
    if (widget.groupProduk != 'KREDIT') {
      if (nominalController.text == '0' || nominalController.text == '') {
        setState(() {
          btnStatus = false;
        });
      } else {
        setState(() {
          btnStatus = true;
        });
      }
    } else {
      if ((nominalController.text == '0' || nominalController.text == '') && (dendaController.text != '') && (bungaController.text != '') && (pokokController.text != '')) {
        setState(() {
          btnStatus = false;
        });
      } else {
        setState(() {
          btnStatus = true;
        });
      }
    }
  }

  void _prosesTransKolektor() async {
    // String _minSetoran = widget.groupProduk == 'BERENCANA'
    //     ? widget.produkModel.min_setoran
    //     : produkProvider.getSelectedMinSetoran;
    if (widget.groupProduk == 'KREDIT') _hitungPembayaranKredit(int.parse(nominalController.text.replaceAll(".", "")));

    String _minSetoran = produkProvider!.getSelectedMinSetoran;

    if (int.parse(nominalController.text.replaceAll('.', '')) < int.parse(_minSetoran) && widget.groupProduk != 'KREDIT') {
      DialogUtils.instance.showError(
        context: context,
        text: widget.tipeTrans == 'SETOR' ? 'Transaksi gagal, setoran minimal ' + TextUtils.instance.numberFormat(_minSetoran) : 'Transaksi gagal, tarikan minimal ' + TextUtils.instance.numberFormat(_minSetoran),
      );
    } else {
      _rekCd = widget.rekCd!;
      _groupProduk = widget.groupProduk!;
      _produkId = widget.produkId!;
      _tipeTrans = widget.tipeTrans!;
      _norek = widget.norek!;
      _jumlah = nominalController.text;
      _remark = keteranganController.text;
      _pokokParse = pokokController.text;
      _bungaParse = bungaController.text;
      _dendaParse = dendaController.text;
      //_lateCharge = lateChargeController.text;
      await transaksiPorvider!.prosesTransaksiKolektor(
        context: context,
        rekCd: _rekCd,
        groupProduk: _groupProduk,
        tipeTrans: _tipeTrans,
        norek: _norek,
        jumlah: _jumlah,
        pokok: _pokokParse,
        bunga: _bungaParse,
        denda: _dendaParse,
        remark: _remark,
        produkId: _produkId,
        sendNotifTrx: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(builder: (context, transProvider, _) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context, transProvider),
      );
    });
  }

  contentBox(context, TransaksiProvider transProvider) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: padding, top: avatarRadius + padding, right: padding, bottom: padding),
          margin: EdgeInsets.only(top: avatarRadius),
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(padding), boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), offset: Offset(0, 10), blurRadius: 10),
          ]),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                formPengisianData(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Tutup',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: padding,
          right: padding,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: avatarRadius,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(avatarRadius)),
              child: globalProv!.getConnectionMode == config.offlineMode
                  ? Image.asset('assets/icon/' + widget.img!)
                  : Image.network(
                      config.ConfigURL().iconLink + widget.img!,
                      width: 60,
                      height: 60,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget formPengisianData() {
    return Container(
        child: Column(
      children: [
        (widget.groupProduk != 'KREDIT')
            ? Column(
                children: [
                  textFieldNominal(
                    widget.tipeTrans == 'SETOR' ? 'Jumlah Setoran' : 'Jumlah Tarikan',
                    nominalController,
                  ),
                  SizedBox(height: 20),
                  textFieldNominal(
                    'Keterangan',
                    keteranganController,
                    isNumber: false,
                  ),
                ],
              )
            : Column(
                children: [
                  textFieldNominal(
                    'Pokok',
                    pokokController,
                    isEnable: false,
                  ),
                  SizedBox(height: 20),
                  textFieldNominal(
                    'Bunga',
                    bungaController,
                    isEnable: true,
                  ),
                  SizedBox(height: 20),
                  textFieldNominal(
                    'Denda',
                    dendaController,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      _btnHitung(),
                      SizedBox(width: 2),
                      _btnRefresh(),
                    ],
                  ),
                  SizedBox(height: 20),
                  textFieldNominal(
                    'Jumlah Dibayar',
                    nominalController,
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 20),
                  textFieldNominal(
                    'Keterangan',
                    keteranganController,
                    isNumber: false,
                  ),
                ],
              ),
        SizedBox(height: 20),
        buttonKirim(),
        SizedBox(height: 10)
      ],
    ));
  }

  Widget buttonKirim() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      width: deviceWidth(context),
      decoration: BoxDecoration(
        color: (btnStatus) ? accentColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (btnStatus) _prosesTransKolektor();
          },
          child: Center(
            child: Text(
              "KIRIM DATA",
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

  Widget _btnHitung() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _hitungPembayaranKredit(int.parse(nominalController.text.replaceAll(".", "")));
          },
          child: Center(
            child: Text(
              "Hitung",
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

  _btnRefresh() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _setFormKredit();
          },
          child: Center(
            child: Text(
              "Reset",
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

  Widget textFieldNominal(String tittle, TextEditingController controller, {bool isNumber = true, bool isEnable = true}) {
    return Stack(
      children: <Widget>[
        Text(
          tittle,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        TextFormField(
          controller: controller,
          enabled: isEnable,
          keyboardType: (isNumber) ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: "Masukkan $tittle",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: EdgeInsets.only(top: 15),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          style: TextStyle(fontSize: 14),
          onSaved: (String? value) => null,
          onChanged: (value) {
            if (isNumber && value.isEmpty) {
              controller.text = '0';
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }

            checkButtonLanjut();
          },
          validator: (value) {
            if (value!.isEmpty) {
              return "$tittle masih kosong!";
            }
            return null;
          },
        ),
      ],
    );
  }
}
