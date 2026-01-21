import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/produk_provider.dart';
// import '../../../ui/screens/nasabah/SearchController.dart';
import '../../../ui/screens/nasabah/SearchController.dart' as sc;
import '../../../ui/widgets/floating_action_button.dart';
import '../../../ui/widgets/loader/lottie_loader.dart';
import '../../../ui/widgets/slide/slide_list_produk.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';

class PencarianNasabah extends StatefulWidget {
  @override
  _PencarianNasabah createState() => _PencarianNasabah();
}

class _PencarianNasabah extends State<PencarianNasabah> {
  ProdukCollectionProvider? produkProvider;
  var searchController = TextEditingController();
  double? _width;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? produkScrollCOntroller;

  @override
  void initState() {
    super.initState();
    produkProvider = Provider.of<ProdukCollectionProvider>(context, listen: false);
    produkProvider!.setAllDatafirstSelectedProduct(context: context, isListen: false);
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Consumer<ProdukCollectionProvider>(
      builder: (contex, produkProv, _) {
        if (produkProv.produkCollection == null) {
          produkProv.dataProduk(context);
          return LottiePrimaryLoader();
        }
        return Scaffold(
          floatingActionButton: floatingActionSwitchMode(context),
          appBar: DefaultAppBar(
            context,
            "Pencarian nasabah " + (produkProv.getSelectedProdukName ?? ' - ').toLowerCase(),
            isCenter: true,
            isRefresh: true,
            onRefresh: () => produkProvider!.refreshAllMenuKlad(),
          ),
          key: scaffoldKey,
          body: Container(
            margin: EdgeInsets.only(top: 15),
            width: _width,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  scrollTag(context),
                  SizedBox(height: 10),
                  _descPage(),
                  Divider(),
                  SizedBox(height: 10),
                  _searchForm(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _descPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        children: [
          Icon(
            // FlutterIcons.account_search_outline_mco,
            Iconsax.user_search,
            color: accentColor,
            size: 20,
          ),
          Text('Pencarian produk nasabah berdasarkan nama'),
        ],
      ),
    );
  }

  Widget _searchForm() {
    return Builder(
      builder: (context) {
        return Consumer<ProdukCollectionProvider>(
          builder: (context, produkProv, _) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: sc.SearchController(
                controller: searchController,
                onClick: () => produkProv.goToSearchNasbah(context),
                readOnly: true,
                placeHolder: 'Cari nasabah',
              ),
            );
          },
        );
      },
    );
  }

  Widget scrollTag(BuildContext context) {
    return Consumer<ProdukCollectionProvider>(
      builder: (context, produkProvider, _) {
        if (produkProvider.produkCollection == null) {
          produkProvider.dataProduk(context);
          return LinearProgressIndicator();
        }
        return Container(
          height: 90,
          margin: EdgeInsets.only(left: 10),
          child: ListView.builder(
            itemCount: produkProvider.produkCollection!.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            controller: produkScrollCOntroller,
            itemBuilder: (BuildContext context, int i) {
              var dataProduk = produkProvider.produkCollection![i];
              return SlideListProduk(dataProduk: dataProduk, isKlad: false);
            },
          ),
        );
      },
    );
  }
}
