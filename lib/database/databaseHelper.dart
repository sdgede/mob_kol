import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';
import 'package:sevanam_mobkol/services/utils/log_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../database/table_config.dart';
import '../services/config/config.dart';
import '../services/utils/mcrypt_utils.dart';

class DatabaseHelper {
  static final _databaseName = "sqlite_koperasi.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database!;
    // _database = await _initDatabase(); // only initialize if not created already
    // return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    if (!(await databaseExists(path))) {
      ByteData data =
          await rootBundle.load(join("assets/database", _databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new io.File(path).writeAsBytes(bytes);
    }
    return await openDatabase(path, version: _databaseVersion);
  }

  void getTestingData({String debugTitle = "", String sqlQuery = ""}) async {
    if (sqlQuery.trim() == "") return;
    Database db = await instance.database;
    var results = await db.rawQuery(sqlQuery);
    debugPrint("SQLITE TESTING DATA" +
        (debugTitle.trim() == "" ? "" : " ($debugTitle)") +
        " : " +
        (new JsonEncoder.withIndent('  ')).convert(results));
  }

  //QUERY

  String _decrypt(String? val) {
    return McryptUtils.instance.decrypt(val ?? '');
  }

  Future getLasIdTbTarns() async {
    Database db = await instance.database;
    Map<String, dynamic> result;

    String query =
        "SELECT trans_id FROM t_trans_simpanan order by trans_id desc LIMIT 1";
    var row = await db.rawQuery(query);
    if (row.length == 0) {
      result = {"trans_id": 0, "pesan": "No data transaction"};
    } else {
      result = row.first;
    }

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m ${json.encode(result)}\x1B[0m');

    return result;
  }

  Future<int> queryRowCount(String tbName) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tbName'),
    )!;
  }

  Future<int> queryRowCountWithClause(
    String tbName,
    String whereClause,
    String whereParam,
  ) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery(
          'SELECT COUNT(*) FROM $tbName WHERE $whereClause = $whereParam'),
    )!;
  }

  Future<bool> deleteDataGlobal(String table) async {
    Database db = await instance.database;
    bool isSukses = false;
    try {
      await db.delete(table);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> deleteDataGlobalWithCLause(
      String table, String columnId, int id) async {
    Database db = await instance.database;
    // Map<String, dynamic> result;
    bool isSukses = false;
    //return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
    try {
      await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> updateDataGlobal(
    String table,
    Map<String, dynamic> dataUpdate,
    String whereColumn,
    int wahereParam,
  ) async {
    Database db = await instance.database;

    bool isSukses = false;
    try {
      await db.update(
        table,
        dataUpdate,
        where: '$whereColumn = ?',
        whereArgs: [wahereParam],
      );
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> insertDataGlobal(
    String table,
    Map<String, dynamic> insertVal,
  ) async {
    Database db = await instance.database;
    bool isSukses = false;
    try {
      await db.insert(table, insertVal);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> passwordVerify(
      String password, Map<String, Object?> user) async {
    debugPrint(jsonEncode(password));

    String passwordToVerify = _decrypt(password) +
        (user['create_date'] == null ? "" : user['create_date'] as String) +
        saltHashKey;

    bool validatePassword = BCrypt.checkpw(
      passwordToVerify,
      user['password'] as String,
    );

    return validatePassword;
  }

  Future getLoginOffline(Map<String, dynamic> dataParse) async {
    Database db = await instance.database;
    Map<String, dynamic> result, resultFinal;

    String query =
        "SELECT 'Y' as status,username,password,IFNULL(imei,'0') as imei,IFNULL(sn_number,'0') as sn_number,username as nama,kolektor_id as id_user,apk_version, create_date FROM s_user_kolektor WHERE username ='" +
            _decrypt(dataParse['username']) +
            "'";
    var row = await db.rawQuery(query);
    if (row.length == 0) {
      result = {"status": "Gagal", "pesan": "Username tidak ditemukan"};
    } else {
      bool isValidPassword = await passwordVerify(dataParse['pwd'], row.first);

      if (isValidPassword) {
        result = {
          "status": "Gagal",
          "pesan": "Username atau password tidak valid"
        };
      } else {
        if (_decrypt(row.first['imei'] as String) !=
            _decrypt(dataParse['imei'])) {
          result = {
            "status": "Gagal",
            "pesan":
                "Upaya masuk gagal, perangkat ini telah terdaftar dengan akun lain. silakan login menggunakan akun yang biasa anda gunakan"
          };
        } else {
          result = {"status": "Sukses", "pesan": "Auth sukses"};
        }
      }
    }

    if (result['status'] == 'Gagal') {
      resultFinal = {'responLogin': result};
    } else {
      // bool imeiAlvaible = true;

      resultFinal = {
        "responLogin": row.first,
        'dataSetting': {
          'min_setoran_tabungan': '10000',
          'min_setoran_wajib': '20000',
          'min_saldo_pengendapan': '30000'
        },
        'dataUser': {
          'username': row.first['username'],
          'nama': row.first['nama'],
          'tipe_akun': 'KOLEKTOR',
        },
        'mode': 'KOLEKTOR'
      };
    }

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m ${json.encode(resultFinal)}\x1B[0m');

    return resultFinal;
  }

  Future testGetData() async {
    Database db = await instance.database;
    List<Map<String, Object?>> result;

    var row = await db
        .rawQuery("SELECT * FROM t_trans_simpanan order by trans_id desc");
    if (row.length == 0) {
      result = [
        {"status": "Gagal", "pesan": "Data tidak ditemukan"}
      ];
    } else {
      result = row;
    }
    debugPrint(result.toString());
    return result;
  }

  Future<dynamic> getIconProdukOffline({
    Map<String, dynamic>? dataParse,
    bool isMigration = false,
  }) async {
    Database db = await instance.database;
    List<Map<String, Object?>> result;
    String whereIsMigration = isMigration ? "AND is_migration = 'Y'" : "";

    String query =
        "SELECT nama_menu as nama,remark as slug,rek_cd,icon,min_setoran,min_tarikan,rek_shortcut,urut_menu FROM s_menu_mobkol WHERE active_flag='Y' $whereIsMigration ORDER BY urut_menu ASC";
    var row = await db.rawQuery(query);
    if (row.length == 0) {
      result = [
        {"status": "Gagal", "pesan": "Data tidak ditemukan"}
      ];
    } else {
      result = row;
    }

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m ${json.encode(result)}\x1B[0m');

    return json.encode(result);
  }

  Future getDataGroupProduk(String produkCd, String rekCd) async {
    Database db = await instance.database;
    Map<String, dynamic> result;

    String query = "SELECT * FROM s_menu_mobkol WHERE group_menu='" +
        produkCd +
        "' AND rek_cd='" +
        rekCd +
        "'";
    var row = await db.rawQuery(query);
    if (row.length == 0) {
      result = {"status": "Gagal", "pesan": "Data tidak ditemukan"};
    } else {
      result = row.first;
    }

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m ${json.encode(result)}\x1B[0m');

    return result;
  }

  Future<dynamic> getDataProduk({
    Map<String, dynamic>? dataParse,
  }) async {
    String groupProduk = _decrypt(dataParse!['groupProduk']);
    String rekCd = _decrypt(dataParse['rekCd']);
    String norek = formatNorekProduk(_decrypt(dataParse['norek']));
    String rekDesc = groupProduk == 'ANGGOTA' ? 'anggota' : 'rekening';
    List<Map<String, Object?>> result;

    String returnResult = "";

    /** Produk Koperasi **/
    if (ProdukModel().products.contains(groupProduk.toString().toUpperCase())) {
      var productClass = ProdukModel(stringClass: groupProduk)
          .getProductModel(mode: 'rek_cd', productClass: rekCd);
      if (productClass == null) {
        productClass = ProdukModel(stringClass: groupProduk).getProductModel();
        if (productClass == null) return;
      }

      var rows = (await productClass.searchByNorek(norek, rekCd))
          as List<Map<String, Object?>>?;
      if (rows == null || rows.length == 0) {
        result = [
          {
            "res_status": "Gagal",
            "pesan":
                "Tidak ditemukan data dengan nomor " + rekDesc + " " + norek
          }
        ];
      } else {
        result = rows.toList();
      }
      returnResult = json.encode(result);
    }

    if (returnResult == "")
      returnResult = json.encode([
        {"res_status": "Gagal", "pesan": "Produk tidak valid"}
      ]);

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m $returnResult\x1B[0m');
    return returnResult;
  }

  Future<dynamic> getKladOffline({
    Map<String, dynamic>? dataParse,
  }) async {
    Database db = await instance.database;
    String groupProduk =
        McryptUtils.instance.decrypt(dataParse!['groupProduk']);
    String rekCd = McryptUtils.instance.decrypt(dataParse['rekCd']);
    String trxDate = DateFormat("yyyy-MM-dd").format(new DateTime.now());
    String kolektor = McryptUtils.instance.decrypt(dataParse['user']);
    String tglAwal = McryptUtils.instance.decrypt(dataParse['tglAwal']);
    String tglAkhir = McryptUtils.instance.decrypt(dataParse['tglAkhir']);
    dynamic configProduk =
        await DatabaseHelper.instance.getDataGroupProduk(groupProduk, rekCd);
    List<Map<String, Object?>> result;

    String query = """
SELECT
  a.*,
  '-' AS refId,
  IFNULL(
    (SELECT `description` FROM s_lov_value WHERE code = '${configProduk['code_trans_cd']}' AND code_val = a.trans_cd)
    , '-'
  ) AS kode,
  a.no_rek AS norek,
  a.trans_cd AS trans_cd_asli,
  '0' AS saldo,
  'CR' AS dbcr,
  a.uploaded AS isUpload,
  (strftime('%d-%m-%Y %H:%M:%S', a.create_date)) as tgl,
  IFNULL(a.remark, '-') AS remark,
  IFNULL(
    (
      CASE
        WHEN a.uploaded = 'Y' THEN 'Sudah Terupload'
        ELSE 'Belum Terupload'
      END
    )
    , '-'
  ) AS uploaded,
  (
    SELECT COUNT(trans_id) FROM t_trans_simpanan
    WHERE trx_date = '$trxDate' AND create_who = '$kolektor' AND rek_cd = '$rekCd' AND uploaded = 'Y'
  ) AS total_trans,
  (
    SELECT COUNT(trans_id) FROM t_trans_simpanan
    WHERE trx_date = '$trxDate' AND create_who = '$kolektor' AND rek_cd = '$rekCd' AND uploaded = 'N'
  ) AS total_trans_blm_uploaded,
  ${ProdukModel(stringClass: groupProduk).getQueryNama(groupProduk, dbTable: 'b', dbNasId: 'nasabah_id')} AS nama
FROM
  t_trans_simpanan a
INNER JOIN ${configProduk['tb_nas']} b ON a.no_rek = b.${ProdukModel(stringClass: groupProduk).getNorekField(groupProduk, 'group_menu')}
WHERE
  a.trx_date BETWEEN '$tglAwal' AND '$tglAkhir'
  AND a.create_who = '$kolektor'
  AND a.rek_cd = '$rekCd'
ORDER BY a.trans_id DESC
""";

    var row = await db.rawQuery(query);
    if (row.length == 0) {
      result = [
        {"res_status": "Gagal", "pesan": "Data klad tidak ditemukan"}
      ];
    } else {
      result = row.toList();
    }

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m ${json.encode(result)}\x1B[0m');

    return json.encode(result);
  }

  Future<dynamic> getSaldoKolOffline({
    required Map<String, dynamic> dataParse,
  }) async {
    Database db = await instance.database;
    // String groupProduk = _decrypt(dataParse!['groupProduk']);
    // String rekCd = _decrypt(dataParse['rekCd']);
    String trxDate = DateSystem;
    String kolektor = _decrypt(dataParse['user']);
    List<Map<String, Object?>> result;

    String query = """
SELECT
  tb.*,
  IFNULL(debet_tab, 0) AS tot_debet,
  IFNULL(kredit_tab + kredit_anggota + kredit_sirena, 0) AS tot_kredit,
  IFNULL(
    IFNULL(kredit_tab + kredit_anggota + kredit_sirena, 0)
    -
    IFNULL(debet_tab, 0)
    , 0
  ) AS tot_saldo
FROM (
  SELECT
    0 AS debet_tab,
    0 AS debet_anggota,
    0 AS debet_sirena,

    0 AS kredit_kredit,
    IFNULL(sum(a.jumlah), 0) AS kredit_tab,

    0 AS saldo_kredit,
    IFNULL(sum(a.jumlah), 0) AS saldo_tab,
    (
      SELECT
        IFNULL(sum(a.jumlah), 0)
      FROM t_trans_simpanan a WHERE
        a.uploaded = 'N'
        AND a.rek_cd = 'SIMP_ANGGOTA'
        AND a.create_who LIKE '%$kolektor%'
        AND a.trx_date = '$trxDate'
    ) AS kredit_anggota,
    (
      SELECT
        IFNULL(sum(a.jumlah), 0)
      FROM t_trans_simpanan a WHERE
        a.uploaded = 'N'
        AND a.rek_cd = 'SIRENA'
        AND a.create_who LIKE '%$kolektor%'
        AND a.trx_date = '$trxDate'
    ) AS kredit_sirena,

    0 AS kas_awal,
    0 AS kas_keluar2,
    0 AS kas_keluar1,
    0 AS kas_sisa
  FROM t_trans_simpanan a WHERE
    a.uploaded = 'N'
    AND a.trans_cd IN ('STT', 'TTT')
    AND a.rek_cd = 'TABRELA'
    AND a.create_who LIKE '%$kolektor%'
    AND a.trx_date = '$trxDate'
) tb
""";
    List<Map<String, Object?>> rows = await db.rawQuery(query);

    result = [];
    if (rows.length > 0) {
      var row = rows.first;
      result = [
        {
          "title": "Kas Awal",
          "data": [
            {
              "subtitle": "Kas Awal Kolektor",
              "value": int.parse(row['kas_awal'].toString())
            }
          ]
        },
        {
          "title": "Kas Dari Transaksi",
          "data": [
            {
              "subtitle": "Kas Masuk",
              "value": int.parse(row['tot_kredit'].toString())
            },
            {
              "subtitle": "Kas Keluar",
              "value": int.parse(row['tot_debet'].toString())
            },
            {
              "subtitle": "Selisih Saldo",
              "value": int.parse(row['tot_saldo'].toString())
            }
          ]
        },
        {
          "title": "Transaksi ANGGOTA",
          "data": [
            {
              "subtitle": "Kas Masuk",
              "value": int.parse(row['kredit_anggota'].toString())
            },
            {
              "subtitle": "Kas Keluar",
              "value": int.parse(row['debet_anggota'].toString())
            },
            {
              "subtitle": "Selisih Saldo",
              "value": int.parse(row['kredit_anggota'].toString())
            }
          ]
        },
        {
          "title": "Transaksi TABUNGAN",
          "data": [
            {
              "subtitle": "Kas Masuk",
              "value": int.parse(row['kredit_tab'].toString())
            },
            {
              "subtitle": "Kas Keluar",
              "value": int.parse(row['debet_tab'].toString())
            },
            {
              "subtitle": "Selisih Saldo",
              "value": int.parse(row['kredit_tab'].toString())
            }
          ]
        },
        {
          "title": "Transaksi BERENCANA",
          "data": [
            {
              "subtitle": "Kas Masuk",
              "value": int.parse(row['kredit_sirena'].toString())
            },
            {
              "subtitle": "Kas Keluar",
              "value": int.parse(row['debet_sirena'].toString())
            },
            {
              "subtitle": "Selisih Saldo",
              "value": int.parse(row['kredit_sirena'].toString())
            }
          ]
        },
      ];
    }

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m ${json.encode(result)}\x1B[0m');

    return json.encode(result);
  }

  Future<dynamic> pencarianNasabahTabOffline({
    Map<String, dynamic>? dataParse,
  }) async {
    String returnResult = "";

    String groupProduk = _decrypt(dataParse!['groupProduk']);
    String rekCd = _decrypt(dataParse['rekCd']);
    String keyword = _decrypt(dataParse['keyword']);
    List<Map<String, Object?>> result;

    /** Produk Koperasi **/
    if (ProdukModel().products.contains(groupProduk.toString().toUpperCase())) {
      var productClass = ProdukModel(stringClass: groupProduk)
          .getProductModel(mode: 'rek_cd', productClass: rekCd);
      if (productClass == null) {
        productClass = ProdukModel(stringClass: groupProduk).getProductModel();
        if (productClass == null) return;
      }

      var rows = (await productClass.searchByName(keyword, rekCd))
          as List<Map<String, Object?>>?;
      if (rows == null || rows.length == 0) {
        result = [
          {
            "res_status": "Gagal",
            "pesan": "Tidak ditemukan data nasabah dengan nama " + keyword
          }
        ];
      } else {
        result = rows.toList();
      }

      returnResult = json.encode(result);
    }

    if (returnResult == "")
      returnResult = json.encode([
        {"res_status": "Gagal", "pesan": "Produk tidak valid"}
      ]);

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint(
        '\x1B[33mOFFLINE SQLITE RESULT ($methodName)::\x1B[0m\x1B[37m $returnResult\x1B[0m');

    return returnResult;
  }

  Future insertTransaksiOffline(
    Map<String, dynamic> dataParse,
    String table,
  ) async {
    Database db = await instance.database;
    Map<String, dynamic> insertVal;
    List<Map<String, Object?>> result;
    bool isSukses = false;
    String tipeTrx = _decrypt(dataParse['tipeTrans']);
    String groupProduk = _decrypt(dataParse['groupProduk']);
    String norek = formatNorekProduk(_decrypt(dataParse['norek']));
    String transCd = _getTransCd(groupProduk, tipeTrx);

    var getLasIdTrx = await getLasIdTbTarns();
    dynamic counRow = getLasIdTrx['trans_id'] + 1;

    insertVal = {
      'trans_id': counRow,
      'produk_id': _decrypt(dataParse['produkId']),
      'no_rek': norek,
      'trans_cd': transCd,
      'rek_cd': _decrypt(dataParse['rekCd']),
      'jumlah': _decrypt(dataParse['jumlah']),
      'trx_type': _decrypt(dataParse['tipeTrans']),
      'trx_date': DateSystem,
      'remark': _decrypt(dataParse['trx_remark']),
      'group_cd': groupProduk,
      'create_who': _decrypt(dataParse['kolektor']),
      'create_date': DateTime.now().toString(),
      'uploaded': 'N',
      'latitude': _decrypt(dataParse['lat']),
      'longitude': _decrypt(dataParse['longi']),
    };
    try {
      await db.insert(table, insertVal);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    if (!isSukses) {
      result = [
        {
          "status": "Gagal",
          "pesan": "Terjadi kesalahan saat menginput transaksi [QUERY_ERR]"
        }
      ];
    } else {
      //int lastId = await queryRowCount(table);
      var getLasIdTrx2 = await getLasIdTbTarns();
      result = [
        {
          "status": "Sukses",
          "pesan": "Data transaksi berhasil disimpan",
          "jumlah": insertVal['jumlah'],
          "pokok": "0",
          "bunga": "0",
          "denda": "0",
          "groupProduk": _decrypt(dataParse['groupProduk']),
          "keterangan":
              insertVal['remark'] == '' ? '-' : insertVal['remark'] ?? '-',
          "kode": "-",
          "trx_date": "-",
          "no_referensi": "-",
          "norek": insertVal['no_rek'],
          "nama": "-",
          "no_hp": "-",
          "saldo_awal": "0",
          "saldo_akhir": "0",
          "terbilang": "-",
          "who": insertVal['create_who'],
          'lastId': getLasIdTrx2['trans_id'],
        }
      ];
    }

    return json.encode(result);
  }

  Future manageDataMigrationProduct(
      dynamic dataParse, groupProduk, rekCd) async {
    int rowEffectedAdd = 0, rowEffectedEdit = 0;
    dynamic productJson = json.decode(dataParse);

    /** Produk Koperasi **/
    if (ProdukModel().products.contains(groupProduk.toString().toUpperCase())) {
      // Upsert product
      await Future.forEach(productJson, (dynamic row) async {
        var productClass = ProdukModel(stringClass: groupProduk)
            .getProductModel(mode: 'rek_cd', productClass: rekCd, json: row);
        if (productClass == null) {
          productClass =
              ProdukModel(stringClass: groupProduk).getProductModel();
          if (productClass == null) return;
        }

        Map<String, int>? response = await productClass.upsertMigration();
        if (response == null) return;

        rowEffectedAdd += response['INSERT']!;
        rowEffectedEdit += response['UPDATE']!;
      });
    }

    return {'row_edit': rowEffectedEdit, 'row_add': rowEffectedAdd};
  }

  Future manageDataMigrationAccount(
      dynamic dataParse, groupProduk, rekCd) async {
    int isDataExist = 0, rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false;
    String actionType = '';
    var dataVal = <String, dynamic>{};
    List<dynamic> jsonData = json.decode(dataParse);
    await Future.forEach<Map<String, dynamic>>(
      jsonData.cast<Map<String, dynamic>>(),
      (val) async {
        isDataExist = await queryRowCountWithClause(
          's_user_kolektor',
          'kolektor_id',
          val['user_id'],
        );

        dataVal['kolektor_id'] = val['user_id'];
        dataVal['username'] = val['username'];
        dataVal['password'] = val['pwd'];
        dataVal['imei'] = val['imei'];
        dataVal['sn_number'] = val['sn_number'];
        dataVal['apk_version'] = val['apk_version'];
        dataVal['status'] = val['status'];
        dataVal['create_date'] = val['create_date'];

        if (isDataExist != 0) {
          actionType = 'UPDATE';
          actionQuery = await updateDataGlobal(
            's_user_kolektor',
            dataVal,
            'kolektor_id',
            int.parse(val['user_id']),
          );
        } else {
          actionType = 'INSERT';
          actionQuery = await insertDataGlobal('s_user_kolektor', dataVal);
        }

        if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
        if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
      },
    );
    return {'row_edit': rowEffectedEdit, 'row_add': rowEffectedAdd};
  }

  Future manageSyncAccount(dynamic val) async {
    int isDataExist = 0, rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false;
    String actionType = '';
    var dataVal = Map<String, dynamic>();
    Database db = await instance.database;

    isDataExist = await queryRowCountWithClause(
      's_user_kolektor',
      'username',
      "'" + val["username"] + "'",
    );

    dataVal['kolektor_id'] = val['ID_USER'];
    dataVal['username'] = val['username'];
    dataVal['password'] = val['password'];
    dataVal['imei'] = val['imei'];
    dataVal['sn_number'] = val['sn_number'];
    dataVal['apk_version'] = val['apk_version'];
    dataVal['status'] = val['status'];
    dataVal['create_date'] = val['create_date'];

    if (isDataExist > 1) {
      await db.rawDelete(
          'DELETE FROM s_user_kolektor WHERE username = ?', [val['username']]);
      actionType = 'INSERT';
      actionQuery = await insertDataGlobal('s_user_kolektor', dataVal);
    } else if (isDataExist != 0) {
      actionType = 'UPDATE';
      actionQuery = await updateDataGlobal(
        's_user_kolektor',
        dataVal,
        'kolektor_id',
        int.parse(val['ID_USER']),
      );
    } else {
      actionType = 'INSERT';
      actionQuery = await insertDataGlobal('s_user_kolektor', dataVal);
    }

    if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
    if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
    return {'row_edit': rowEffectedEdit, 'row_add': rowEffectedAdd};
  }

  Future<Map<String, int>> manageDataMigrationNasabah(
      dynamic dataParse, groupProduk, rekCd) async {
    int isDataExist = 0, rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false;
    String actionType = '';
    var dataVal = <String, dynamic>{};
    List<dynamic> jsonData = json.decode(dataParse);

    await Future.forEach<Map<String, dynamic>>(
      jsonData.cast<Map<String, dynamic>>(),
      (val) async {
        isDataExist = await queryRowCountWithClause(
          tb_master_nasabah,
          'nasabah_id',
          val['nasabah_id'],
        );

        dataVal['nasabah_id'] = val['nasabah_id'];
        dataVal['no_master'] = val['no_master'];
        dataVal['nama_depan'] = val['nama_depan'];
        dataVal['nama_belakang'] = val['nama_belakang'];
        dataVal['alamat'] = val['alamat'];
        dataVal['nama_ibu'] = val['nama_ibu'];
        dataVal['tmp_lahir'] = val['tmp_lahir'];
        dataVal['tgl_lahir'] = val['tgl_lahir'];
        dataVal['nik'] = val['nik'];
        dataVal['hp'] = val['hp'];
        dataVal['status'] = val['status'];

        if (isDataExist != 0) {
          actionType = 'UPDATE';
          actionQuery = await updateDataGlobal(
            tb_master_nasabah,
            dataVal,
            'nasabah_id',
            int.parse(val['nasabah_id']),
          );
        } else {
          actionType = 'INSERT';
          actionQuery = await insertDataGlobal(tb_master_nasabah, dataVal);
        }

        if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
        if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
      },
    );

    return {'row_edit': rowEffectedEdit, 'row_add': rowEffectedAdd};
  }

  Future manageDataMigrationConfig(dynamic dataParse) async {
    int rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false, actionDell, actionDellConf;
    String actionType = '';
    var dataVal = Map<String, dynamic>();
    var jsonData = json.decode(dataParse);
    jsonData = jsonData[0];
    actionDell = await deleteDataGlobal(tb_menu_mobkol);
    if (actionDell)
      await Future.forEach(
        jsonData['data_menu_mobkol'],
        (dynamic val) async {
          dataVal['id_menu'] = val['id_menu'];
          dataVal['group_menu'] = val['group_menu'];
          dataVal['rek_cd'] = val['rek_cd'];
          dataVal['kode_produk'] = val['kode_produk'];
          dataVal['code_trans_cd'] = val['code_trans_cd'];
          dataVal['tb_nas'] = val['tb_nas'];
          dataVal['id_tb_nas'] = val['id_tb_nas'];
          dataVal['tb_trans'] = val['id_tb_trans'];
          dataVal['fnSaldo'] = val['fnSaldo'];
          dataVal['nama_menu'] = val['nama_menu'];
          dataVal['icon'] = val['icon'];
          dataVal['rek_shortcut'] = val['rek_shortcut'];
          dataVal['remark'] = val['remark'];
          dataVal['min_setoran'] = val['min_setoran'];
          dataVal['min_tarikan'] = val['min_tarikan'];
          dataVal['urut_menu'] = val['urut_menu'];
          dataVal['active_flag'] = val['active_flag'];
          dataVal['create_who'] = val['create_who'];
          dataVal['create_date'] = val['create_date'];

          actionType = 'INSERT';
          actionQuery = await insertDataGlobal(tb_menu_mobkol, dataVal);

          if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
          if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
        },
      );

    // update data config
    var confVal = Map<String, dynamic>();
    actionDellConf = await deleteDataGlobal(tb_config_mobkol);
    if (actionDellConf)
      await Future.forEach(
        jsonData['data_config_mobkol'],
        (dynamic val) async {
          confVal['id_config'] = val['id_config'];
          confVal['base_url'] = val['base_url'];
          confVal['nama_app'] = val['nama_app'];
          confVal['nama_instansi_full'] = val['nama_instansi_full'];
          confVal['nama_instansi_short'] = val['nama_instansi_short'];
          confVal['no_hp_instansi'] = val['no_hp_instansi'];
          confVal['no_wa_instansi'] = val['no_wa_instansi'];
          confVal['email_instansi'] = val['email_instansi'];
          confVal['client_type'] = val['client_type'];
          confVal['primaryColor'] = val['primaryColor'];
          confVal['accentColor'] = val['accentColor'];
          confVal['primaryBg'] = val['primaryBg'];

          actionType = 'INSERT';
          actionQuery = await insertDataGlobal(tb_config_mobkol, confVal);

          if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
          if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
        },
      );

    return {'row_edit': rowEffectedEdit, 'row_add': rowEffectedAdd};
  }

  Future lastSync() async {
    Database db = await instance.database;
    var data = await db.query('m_versi_db WHERE id_versi = 1 LIMIT 1');
    if (data.length == 0) {
      return null;
    }
    debugPrint('Last db version ${data[0]}');
    return data[0]['tgl_update'];
  }

  Future updateSync(String current) async {
    Database db = await instance.database;
    var lastSync = await db.query('m_versi_db WHERE id_versi = 1 LIMIT 1');

    var dataVal = Map<String, dynamic>();
    dataVal['id_versi'] = 1;
    dataVal['tgl_update'] = current;
    dataVal['versi'] = 1;

    if (lastSync.length == 0) {
      // jika versi db tidak ada: insert
      await insertDataGlobal('m_versi_db', dataVal);
    } else {
      // jika versi db ada: update
      int lastVersi = lastSync[0]['versi'] as int;
      dataVal['versi'] = lastVersi + 1;
      await updateDataGlobal(
        'm_versi_db',
        dataVal,
        'id_versi',
        1,
      );
    }

    debugPrint("Sync successfully updated at $current");
  }

  String formatNorekProduk(String norekParse) {
    //SET FORMAT NOREK LOGIC OR JUST RETURN norekParse

    // String formated = "0";
    // var arrStr = norekParse.split('.');
    // String kodeRek = arrStr[0];
    // String noUrut = arrStr[1];
    // int strLen = 5 - noUrut.length;
    // String zero = "";
    // for (var i = 0; i < strLen; i++) {
    //   zero += "0";
    // }
    // formated = kodeRek + "." + zero + noUrut;

    // return formated;

    return norekParse;
  }

  String _getTransCd(String groupProduk, String tipeTrans) {
    String transCd = '-';

    /** Produk Koperasi **/
    if (['TABUNGAN'].contains(groupProduk)) {
      transCd = tipeTrans == 'SETOR' ? 'STT' : 'TTT';
    } else if (['ANGGOTA'].contains(groupProduk)) {
      transCd = tipeTrans == 'SETOR' ? 'STW' : 'TTW';
    } else if (['BERENCANA'].contains(groupProduk)) {
      transCd = tipeTrans == 'SETOR' ? 'STJ' : 'PTJ';
    } else if (['KREDIT'].contains(groupProduk)) {
      transCd = 'PKT';
    }

    return transCd;
  }

  // Future<int> update(Todo todo) async {
  //   return await db.update(tableTodo, todo.toMap(),
  //       where: '$columnId = ?', whereArgs: [todo.id]);
  // }

  Future getDataGlobal({String? table, String? whereClause, int? id}) async {
    Database db = await instance.database;
    Map<String, dynamic> result;
    //var maps = await db.query(table, where: 'kolektor_id = ?', whereArgs: [id]);
    var maps = await db.query(table!);
    if (maps.length > 0) {
      result = maps.first;
    } else {
      result = {'status': 'Gagal', 'pesan': 'Query ERR'};
    }

    return result;
  }

  Future<io.File> copyDB() async {
    // final db = await instance.database;
    final dbPath = await getDatabasesPath();
    var afile = io.File(dbPath);
    return afile;
  }

  // Future<Todo> getTodo(int id) async {
  //   Database db = await instance.database;
  //   List<Map> maps = db.rawQuery('SELECT COUNT(*) FROM $tb_auth');
  //   if (maps.length > 0) {
  //     return Todo.fromMap(maps.first);
  //   }
  //   return null;
  // }

  Future getLocalConfig() async {
    Database db = await instance.database;
    var data = await db.query('s_data_config LIMIT 1');
    if (data.length == 0) {
      return null;
    }
    debugPrint('Data config ${data[0]}');
    return data[0];
  }
}
