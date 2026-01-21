import 'package:get_it/get_it.dart';
import 'package:sevanam_mobkol/services/collection/firestore_collection.dart';

import 'services/utils/location_utils.dart';
import 'services/collection/global_collection.dart';
import 'services/collection/produk_collection.dart';
import 'services/collection/transaksi_collection.dart';

GetIt setup = GetIt.instance;
void setupApp() async {
  //* Register as singleton
  setup.registerSingleton(LocationUtils());
  setup.registerSingleton(GlobalCollectionServices());
  setup.registerSingleton(ProdukCollectionServices());
  setup.registerSingleton(TransaksiCollectionServices());
  setup.registerSingleton(FirestoreCollectionServices());
}
