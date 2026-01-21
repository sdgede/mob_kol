import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/produk_provider.dart';
import '../../../ui/screens/nasabah/SearchController.dart' as sc;
import '../../../ui/widgets/text_list/field_list_histori_transaksi.dart';
import '../../constant/constant.dart';
import '../../widgets/not_found.dart';

class AdapterPencarianKlad extends StatefulWidget {
  @override
  _AdapterPencarianKlad createState() => _AdapterPencarianKlad();
}

class _AdapterPencarianKlad extends State<AdapterPencarianKlad> {
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
              // FlutterIcons.ios_arrow_back_ion,
              Iconsax.arrow_left,
              color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: _appBar(),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: MerchantSearchBody(),
    );
  }

  Widget _appBar() {
    return Builder(
      builder: (context) {
        return Consumer<ProdukCollectionProvider>(
          builder: (context, produkProv, _) {
            return sc.SearchController(
              controller: searchController,
              placeHolder: 'Cari Norek..',
              autoFocus: true,
              onSubmit: (value) => produkProv.getDataSearchMutasi(context: context, keyword: value),
            );
          },
        );
      },
    );
  }
}

class MerchantSearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _nasabahCount(),
            _nasabahList(),
          ],
        ),
      ),
    );
  }

  Widget _nasabahCount() {
    return Builder(
      builder: (context) {
        return Consumer<ProdukCollectionProvider>(
          builder: (context, produkProv, _) {
            if (produkProv.mutasiProdukCollectionSearch == null) {
              return SizedBox();
            }

            if (produkProv.mutasiProdukCollectionSearch![0].status == 'Gagal') {
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
                      "${produkProv.mutasiProdukCollectionSearch!.length.toString()} nasabah ditemukan",
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
            if (produkProv.mutasiProdukCollectionSearch == null && produkProv.onSearch == false) {
              return Center(
                child: Text("Lakukan pencarian berdasarkan nama nasabah"),
              );
            }

            if (produkProv.onSearch) {
              return Center(
                child: LottieBuilder.asset("assets/lottie/shimmer_list_user.json"),
              );
            }

            if (produkProv.mutasiProdukCollectionSearch![0].status == 'Gagal') {
              return Center(
                child: DataNotFound(
                  pesan: produkProv.mutasiProdukCollectionSearch![0].pesan,
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: produkProv.mutasiProdukCollectionSearch!.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var dataTrans = produkProv.muatasiProdukCollection![index];
                return FieldListKlad(dataTrans: dataTrans);
              },
            );
          },
        );
      },
    );
  }
}
