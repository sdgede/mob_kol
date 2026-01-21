import 'package:sevanam_mobkol/services/utils/text_utils.dart';

class ModelDatatable {
  int total;
  int limit;
  int page;
  int totalPage;
  List<dynamic> data;

  ModelDatatable({
    required this.total,
    required this.limit,
    required this.page,
    required this.totalPage,
    required this.data,
  });

  bool isEmpty() {
    return total <= 0;
  }

  ModelDatatable addReplaceData(ModelDatatable newDatatable, {bool isReset = false}) {
    total = newDatatable.total;
    limit = newDatatable.limit;
    page = newDatatable.data.isEmpty ? page : newDatatable.page;
    totalPage = newDatatable.totalPage;

    if (isReset) {
      data = newDatatable.data;
    } else {
      data.addAll(newDatatable.data);
    }

    return ModelDatatable(total: total, limit: limit, page: page, totalPage: totalPage, data: data);
  }

  factory ModelDatatable.fromJson(Map<String, dynamic> json, dynamic Function(Map<String, dynamic>)? callback) {
    List<dynamic> data = [];

    if (json['data'] is List && callback != null) {
      for (var row in json['data']) {
        var rowModel = callback(row);
        data.add(rowModel);
      }
    }

    return ModelDatatable(
      total: int.parse(TextUtils().allToStringStrict(json['total'])),
      limit: int.parse(TextUtils().allToStringStrict(json['limit'])),
      page: int.parse(TextUtils().allToStringStrict(json['page'])),
      totalPage: int.parse(TextUtils().allToStringStrict(json['total_pages'])),
      data: data,
    );
  }
}
