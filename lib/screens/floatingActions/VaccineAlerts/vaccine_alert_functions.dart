import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/alert_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cowin_track_availability/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class VaccineAlertClass {
  final DataFunctions _dataFunctions = DataFunctions();

  Future<void> getAlert({Database database}) async {
    try {
      // Assumes that null will happen only in background headless method.
      if (database == null) {
        DatabaseProvider databaseProvider = await _dataFunctions.loadDatabase();
        database = databaseProvider.database;
      }

      final prefs = await SharedPreferences.getInstance();
      final String vaccineSelected =
          prefs.getString(AlertScreen.vaccinePrefs) ??
              CommonData.defaultVaccineType;

      List<String> _available = [];

      List<Map> userLocations = await _dataFunctions.getUserTable(database);

      for (Map district in userLocations) {
        String districtID = district['districtID'].toString();
        List map = await _dataFunctions.getCalendarData(
          districtID: districtID,
          database: database,
        );

        // map contains all the centres and their details in a district.
        map.forEach((eachCenter) {
          List sessions = eachCenter['sessions'];
          List filterZeroCapacity = [];

          sessions.forEach((eachSession) {
            if (eachSession['available_capacity'].toString() != '0') {
              if (eachSession['vaccine'].toString().contains(vaccineSelected) ||
                  vaccineSelected.contains(CommonData.defaultVaccineType))
                filterZeroCapacity.add(eachSession);
            }
          });

          if (filterZeroCapacity.isNotEmpty)
            _available.add(eachCenter['name'].toString());
        });
      }

      if (_available.isNotEmpty) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'vaccine_alert_1',
          'makesh_tech_vaccine_tracker',
          'Displays Vaccine Alerts!',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          'Vaccine Available!',
          'Centres: ' + _available.join(", "),
          platformChannelSpecifics,
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
