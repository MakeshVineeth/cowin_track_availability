import 'dart:convert';
import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/global_functions.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataFunctions {
  final GlobalFunctions globalFunctions = GlobalFunctions();

  Future<DatabaseProvider> loadDatabase() async {
    try {
      String path = await getDatabaseFilePath();
      Database db = await openDatabase(
        path,
        version: 1,
      );

      List<String> vaccinesList =
          await getList(url: CommonData.vaccineJsonUrl, key: 'vaccine');
      List<String> ageList =
          await getList(url: CommonData.ageJsonUrl, key: 'age');

      return DatabaseProvider(
        database: db,
        vaccinesList: vaccinesList,
        ageList: ageList,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> isTableNotExists(String tableName, Database database) async {
    try {
      var result = await database
          .query('sqlite_master', where: 'name = ?', whereArgs: ['$tableName']);

      return result.isEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> getDistricts(Database db, int stateID, String stateName) async {
    try {
      String tableName = stateName.trim().replaceAll(' ', '_');

      await db.execute(
          'CREATE TABLE $tableName (districtName TEXT PRIMARY KEY, districtID INTEGER)');

      if (await DataFunctions().isTableNotExists(tableName, db))
        return; // extra check

      Response _response = await globalFunctions.getWebResponse(
          'https://cdn-api.co-vin.in/api/v2/admin/location/districts/$stateID');

      if (_response.statusCode != 200 || _response == null) {
        print('API Limits Breached.');
        return;
      }

      List<dynamic> temp = json.decode(_response.body)['districts'];

      Map<String, int> _districtsList = {};

      temp.forEach((eachMap) {
        int districtID = eachMap['district_id'];
        String districtName = eachMap['district_name'];

        _districtsList.addAll(
            {districtName: districtID}); // Map is in format state name : id
      });

      // Insert some records in a transaction
      await db.transaction((txn) async {
        _districtsList.forEach((key, value) async {
          await txn.rawInsert(
              'INSERT INTO $tableName(districtName, districtID) VALUES("$key", $value)');
        });
      });
    } catch (_) {}
  }

  Future<bool> isTableEmpty(String tableName, Database database) async {
    try {
      List<Map> count =
          await database.rawQuery('SELECT COUNT(*) FROM $tableName');
      int countVal = count.elementAt(0).values.elementAt(0);

      return countVal == 0;
    } catch (_) {
      return true;
    }
  }

  Future<void> getStatesData(Database db) async {
    try {
      if (await isTableNotExists(CommonData.stateTable, db))
        await db.execute(
            'CREATE TABLE ${CommonData.stateTable} (stateName TEXT PRIMARY KEY, stateID INTEGER)');
      else if (!await isTableEmpty(CommonData.stateTable, db)) return;

      Response _response = await globalFunctions.getWebResponse(
          'https://cdn-api.co-vin.in/api/v2/admin/location/states');

      if (_response.statusCode != 200 || _response == null) {
        print('API Limits Breached.');
        return;
      }

      List<dynamic> temp = json.decode(_response.body)[
          'states']; // Here dynamic would actually be a Map but replacing it with Map will throw error.

      Map<String, int> _locations = {};

      temp.forEach((eachMap) {
        int stateID = eachMap['state_id'];
        String stateName = eachMap['state_name'];
        _locations
            .addAll({stateName: stateID}); // Map is in format state name : id
      });

      // Insert some records in a transaction
      await db.transaction((txn) async {
        _locations.forEach((key, value) async {
          await txn.rawInsert(
              'INSERT INTO ${CommonData.stateTable}(stateName, stateID) VALUES("$key", $value)');
        });
      });
    } catch (_) {}
  }

  Future<void> createUserTable(Database database) async {
    try {
      if (await isTableNotExists(CommonData.userTable, database))
        await database.execute(
            'CREATE TABLE ${CommonData.userTable} (districtName TEXT PRIMARY KEY, districtID INTEGER, stateName TEXT, stateID INTEGER)');
    } catch (_) {}
  }

  Future<List<Map>> getUserTable(Database database) async {
    try {
      if (await isTableNotExists(CommonData.userTable, database))
        return const [];

      List<Map> data =
          await database.rawQuery('SELECT * FROM ${CommonData.userTable}');

      return data;
    } catch (_) {
      return const [];
    }
  }

  Future<void> insertUserSelection(
      {@required String stateName,
      @required int stateID,
      @required String districtName,
      @required int districtID,
      @required Database database}) async {
    try {
      if (await isTableNotExists(CommonData.userTable, database)) return;

      await database.transaction((txn) async => await txn.rawInsert(
          'INSERT INTO ${CommonData.userTable}(districtName, districtID, stateName, stateID) VALUES("$districtName", $districtID, "$stateName", $stateID)'));
    } catch (_) {}
  }

  Future<String> getDatabaseFilePath() async {
    try {
      String databasesPath = await getDatabasesPath();
      final String path = join(databasesPath + 'vaccine_tracker_makeshtech.db');
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteRow(
      {@required DatabaseProvider database,
      @required String tableName,
      @required String condition}) async {
    try {
      await database.database.delete(
        tableName,
        where: 'districtName = ?',
        whereArgs: [condition],
      );

      database.update();
    } catch (_) {}
  }

  Future<List> getCalendarData({
    @required String districtID,
    @required Database database,
    @required String districtName,
  }) async {
    try {
      String url;
      final String todayDateStr = globalFunctions.getTodayDate();

      if (int.tryParse(districtName) == null)
        url =
            'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtID&date=$todayDateStr';
      else
        url =
            'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$districtName&date=$todayDateStr';

      Response response = await globalFunctions.getWebResponse(url);

      if (response.statusCode != 200 || response == null) return const [];
      var map = json.decode(response.body)['centers'] as List;

      return map;
    } catch (_) {
      return const [];
    }
  }

  Future<List<String>> getList(
      {@required String url, @required String key}) async {
    try {
      // get vaccines list
      Response _res = await globalFunctions.getWebResponse(url);

      if (_res.statusCode != 200 || _res == null)
        return [CommonData.defaultVaccineType];

      Map<String, String> data =
          Map<String, String>.from(json.decode(_res.body));
      String vaccineCombinedList = data[key];
      return vaccineCombinedList.split(',');
    } catch (_) {
      return [CommonData.defaultVaccineType];
    }
  }
}
