import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../services/config/config.dart';
import '../../../ui/widgets/app_bar.dart';
import '../../../ui/widgets/datetime_periode.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../ui/widgets/nasabah/vertical_list_nasabah.dart';
import '../../constant/constant.dart';
import '../../widgets/not_found.dart';

class DaftarPenagihanPinjaman extends StatefulWidget {
  @override
  _DaftarPenagihanPinjaman createState() => _DaftarPenagihanPinjaman();
}

class _DaftarPenagihanPinjaman extends State<DaftarPenagihanPinjaman> {
  var searchController = TextEditingController();
  ProdukCollectionProvider? produkProvider;
  DateTime _tglAwal = DateTime.now();
  DateTime _tglAkhir = DateTime.now();

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    produkProvider!.clearSearchNasabah(isListen: false);
    produkProvider!.setTglAwal(_tglAwal);
    produkProvider!.setTglAkhir(_tglAkhir);
    produkProvider!.setSelectedProdukName(clientType == ClientType.koperasi ? "Pinjaman" : "Kredit", listen: false);
    produkProvider!.setSelectedgroupProdukProduk("KREDIT", listen: false);
    produkProvider!.setSelectedRekCdProduk("KREDIT", listen: false);
    produkProvider!.setSelectedProdukIcon("kredit.png", listen: false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(
        context,
        "Daftar penagihan pinjaman ",
        isCenter: true,
        isRefresh: true,
        onRefresh: () => produkProvider!.clearSearchNasabah(),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getSingleDatePeriode(context),
              SizedBox(height: 30),
              _nasabahCount(),
              _nasabahList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nasabahCount() {
    return Builder(
      builder: (context) {
        return Consumer<ProdukCollectionProvider>(
          builder: (context, produkProv, _) {
            if (produkProv.getNasabahList == null) {
              return SizedBox();
            }

            if (produkProv.getNasabahList![0].status == 'Gagal') {
              return SizedBox();
            }

            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      // FlutterIcons.account_search_outline_mco,
                      Iconsax.user_search,
                      color: primaryColor,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${produkProv.getNasabahList!.length.toString()} Data penagihan ditemukan",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.black12),
              ],
            );
          },
        );
      },
    );
  }

  Widget _nasabahList() {
    return Builder(
      builder: (context) {
        return Consumer<ProdukCollectionProvider>(
          builder: (context, produkProv, _) {
            if (produkProv.getNasabahList == null) {
              produkProv.getDataPenagihanPinajaman(context);
              return Center(
                child: LottieBuilder.asset("assets/lottie/shimmer_list_user.json"),
              );
            }

            if (produkProv.getNasabahList![0].status == 'Gagal') {
              return Center(
                child: Column(
                  children: [
                    DataNotFound(
                      pesan: "Tidak ada data penagihan hari ini",
                    ),
                    _refreshData(),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: produkProv.getNasabahList!.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var dataNasabah = produkProv.getNasabahList![index];
                return VerticalListNasabah(dataNasabah: dataNasabah);
              },
            );
          },
        );
      },
    );
  }

  Widget _refreshData() {
    return Container(
      width: 200,
      height: 40,
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => produkProvider!.clearSearchNasabah(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Refresh",
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                  // FlutterIcons.refresh_faw,
                  Iconsax.refresh,
                  color: accentColor)
            ],
          ),
        ),
      ),
    );
  }
}
