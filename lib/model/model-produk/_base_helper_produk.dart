import 'package:flutter/material.dart';
import 'package:sevanam_mobkol/database/databaseHelper.dart';
import 'package:sevanam_mobkol/model/produk_model.dart';
import 'package:sevanam_mobkol/services/utils/log_utils.dart';
import 'package:sqflite/sqflite.dart';

class BaseHelperProduk {
  String getQuerySelectNamaNasabah(String tbName, String columnAlias) {
    return "(TRIM(TRIM(IFNULL($tbName.nama_depan,'')) ||' '|| TRIM(IFNULL($tbName.nama_belakang,''))))${columnAlias == "" ? "" : " AS $columnAlias"}";
  }

  Future<dynamic>? searchByNameNasabah(String keyword, String? rekCd, String dbTable, String dbPk) async {
    Database db = await DatabaseHelper.instance.database;

    String query = """
SELECT
  'Sukses' AS res_status,
  a.$dbPk AS tab_id,
  a.${ProdukModel().getNorekField(rekCd ?? "", "rek_cd")} AS norek,
  ${getQuerySelectNamaNasabah('b', 'nama')},
  '-' AS alamat_pelayanan,
  b.alamat,
	IFNULL(
		(
			SELECT
				CASE
					WHEN a.`status` = 'A' THEN ('AKTIF')
					WHEN a.`status` = 'D' THEN ('DAFTAR')
					WHEN a.`status` = 'T' THEN ('TUTUP')
				END
		),
		'-'
	) AS `status`,
  'Sukses' AS res_status
FROM $dbTable a
INNER JOIN m_nasabah b ON a.nasabah_id = b.nasabah_id
WHERE
  ${getQuerySelectNamaNasabah('b', '')} LIKE '%$keyword%'
  AND a.`status` IN ('A', 'D')
""";

    var rows = await db.rawQuery(query);

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint('\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');

    return rows;
  }

  Future<Map<String, int>?> upsertMigration(Function prepareRow, Function getPrimaryKeyValue, String dbTable, String dbPk) async {
    Map<String, String> upsert = prepareRow()!;
    Map<String, int> response = {
      "INSERT": 0,
      "UPDATE": 0,
    };
    if (getPrimaryKeyValue().trim() == "") return response;

    int isDataExist = await DatabaseHelper.instance.queryRowCountWithClause(dbTable, dbPk, getPrimaryKeyValue());
    if (isDataExist > 0) {
      bool isSuccess = await DatabaseHelper.instance.updateDataGlobal(
        dbTable,
        upsert,
        dbPk,
        int.parse(getPrimaryKeyValue()),
      );
      if (isSuccess) response["UPDATE"] = response["UPDATE"]! + 1;
    } else {
      bool isSuccess = await DatabaseHelper.instance.insertDataGlobal(dbTable, upsert);
      if (isSuccess) response["INSERT"] = response["INSERT"]! + 1;
    }

    return response;
  }

  Future<dynamic>? searchByNorekNasabahTab(String norek, String? rekCd, String dbTable, String dbPk, {String dbNorekField = 'no_rek'}) async {
    Database db = await DatabaseHelper.instance.database;

    String query = """
SELECT
	tb.*,
	'0' AS remark
FROM
(
		SELECT
			'Sukses' AS res_status,
			IFNULL(a.$dbPk, 0) AS tab_id,
			IFNULL(a.nasabah_id, 0) AS nas_id,
			IFNULL(a.$dbNorekField, '') AS norek,
			'0' AS saldo,
			'0' AS val_blokir,
			'0' AS trx_date,
			${getQuerySelectNamaNasabah('b', 'nama')},
			b.alamat AS alamat,
			IFNULL(
				(
					SELECT
						b.description
					FROM
						s_lov_value b
					WHERE
						a.wilayah_cd = b.code_val
						AND b.code = 'WILAYAH_CD'
						AND b.active_flag = 'Y'
				),
				'-'
			) AS wilayah,
			'' AS alamat_pelayanan,
			IFNULL(a.group_cd, '0') as group_cd,
			IFNULL(a.wilayah_cd, '0') as wilayah_cd,
			IFNULL(a.wilayah_cd, '0') as wilayah_cd_asli,
			IFNULL(a.tgl_daftar, '0') as tgl_daftar,
			IFNULL(a.setoran_awal, '0') as setoran_awal,
			IFNULL(a.status, '0') as sts,
			IFNULL(
				(
					SELECT
						CASE
							WHEN a.status = 'A' THEN ('AKTIF')
							WHEN a.status = 'D' THEN ('DAFTAR')
							WHEN a.status = 'T' THEN ('TUTUP')
							ELSE '-'
						END
				),
				'-'
			) AS `status`,
			IFNULL(a.remark, '-') AS remark1
		FROM
			$dbTable a,
			m_nasabah b
		WHERE
			a.$dbNorekField = '$norek'
			AND a.nasabah_id = b.nasabah_id
		LIMIT
			1
	) tb
""";

    var rows = await db.rawQuery(query);

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint('\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');

    return rows;
  }

  Future<dynamic>? searchByNorekNasabahAnggota(String norek, String? rekCd, String dbTable, String dbPk) async {
    Database db = await DatabaseHelper.instance.database;
    String query = """
SELECT
    a.$dbPk AS tab_id,
    a.nasabah_id AS nas_id,
    ('ANGGOTA') AS rek_cd,
    a.no_anggota AS norek,
    '0' AS saldo,
    '-' AS trx_date,
    ${getQuerySelectNamaNasabah('b', 'nama')},
    b.alamat AS alamat,
    IFNULL(
        (
            SELECT
                description
            FROM
                s_lov_value
            WHERE
                code = 'WILAYAH_CD'
                AND active_flag = 'Y'
                AND code_val = a.`wilayah_cd`
            limit
                1
        ), '-'
    ) AS wilayah,
    IFNULL(a.group_cd, '0') AS group_cd,
    IFNULL(a.wilayah_cd, '0') as wilayah_cd,
    IFNULL(a.wilayah_cd, '0') as wilayah_cd_asli,
    IFNULL(
        (
            SELECT
                CASE
                    WHEN a.status = 'A' THEN ('AKTIF')
                    WHEN a.status = 'D' THEN ('DAFTAR')
                    WHEN a.status = 'T' THEN ('TUTUP')
                END
        ),
        '-'
    ) AS `status`,
    IFNULL(a.pokok, '-') AS pokok,
    IFNULL(a.status, '-') AS sts,
    IFNULL(a.wajib_awal, '-') AS wajib_awal,
    IFNULL(a.remark, '-') AS remark
FROM
    $dbTable A,
    m_nasabah B
WHERE
    a.no_anggota = '$norek'
    AND a.`nasabah_id` = b.`nasabah_id`
    and a.status = 'A'
""";

    var rows = await db.rawQuery(query);

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint('\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');

    return rows;
  }

  Future<dynamic>? searchByNorekNasabahBerencana(String norek, String? rekCd, String dbTable, String dbPk, {String dbNorekField = 'no_rek'}) async {
    Database db = await DatabaseHelper.instance.database;

    String query = """
SELECT
	tb.*
FROM
(
		SELECT
			'Sukses' AS res_status,
			IFNULL(ROUND(setoran_awal), '0') AS setoranAwal,
			IFNULL(ROUND(jumlah_diterima), '0') as jmlDiterima,
			IFNULL(suku_bunga, '0') as sb,
			IFNULL(a.$dbPk, 0) AS tab_id,
			IFNULL(a.nasabah_id, 0) AS nasabahId,
			(
				SELECT
					${getQuerySelectNamaNasabah('b', 'nama')}
				FROM
					m_nasabah b
				WHERE
					a.nasabah_id = b.nasabah_id
			) AS nama,
			(
				SELECT
					b.alamat
				FROM
					m_nasabah b
				WHERE
					a.nasabah_id = b.nasabah_id
			) AS alamat,
			IFNULL(
				(
					SELECT
						b.description
					FROM
						s_lov_value b
					WHERE
						a.wilayah_cd = b.code_val
						AND b.code = 'KABUPATEN'
						AND b.active_flag = 'Y'
				),
				'-'
			) AS wilayah,
			IFNULL(a.wilayah_cd, '00') AS wilayahCd,
			IFNULL(a.$dbNorekField, '') AS norek,
			IFNULL(a.jangka_waktu, '0') || ' Bulan' AS jw,
			IFNULL(ROUND(a.setoran_per_bulan), '0') as setoranPerBulan,
			IFNULL(
				(
					CASE
						a.start_date
						WHEN '0000-00-00 00:00:00' THEN '1900-01-01 01:00:00'
						ELSE a.start_date
					END
				),
				'1900-01-01 01:00:00'
			) AS tglReal,
			IFNULL(
				(
					CASE
						a.end_date
						WHEN '0000-00-00 00:00:00' THEN '1900-01-01 01:00:00'
						ELSE a.end_date
					END
				),
				'1900-01-01 01:00:00'
			) AS tglJatem,
			IFNULL(
				(
					SELECT
						b.description
					FROM
						s_lov_value b
					WHERE
						a.status = b.code_val
						AND b.code = 'STATUS_PRODUCT_DEPOSITO'
				),
				'-'
			) AS status,
			'0' AS saldo,
			'0' AS tunggakan,
			'0' AS kali_nunggak,
			IFNULL(a.remark, '-') AS remark
		FROM
			$dbTable a
		WHERE
			a.$dbNorekField = '$norek'
		LIMIT
			1
	) tb
""";

    var rows = await db.rawQuery(query);

    String methodName = LogUtils().getCurrentMethodName();
    debugPrint('\x1B[33mOFFLINE SQLITE QUERY ($methodName)::\x1B[0m\x1B[37m $query\x1B[0m');

    return rows;
  }
}
