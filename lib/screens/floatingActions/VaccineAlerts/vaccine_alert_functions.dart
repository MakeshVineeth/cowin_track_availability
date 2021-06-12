import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/main.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/alert_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class VaccineAlertClass {
  final DataFunctions _dataFunctions = DataFunctions();
  static const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'vaccine_alert_1',
    'makesh_tech_vaccine_tracker',
    'Displays Vaccine Alerts!',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  static const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  Future<void> getAlert({Database database}) async {
    try {
      // Assumes that null will happen only in background headless method.
      if (database == null) {
        DatabaseProvider databaseProvider = await _dataFunctions.loadDatabase();
        database = databaseProvider.database;
      }

      final prefs = await SharedPreferences.getInstance();
      String vaccineSelected = prefs.getString(AlertScreen.vaccinePrefs) ??
          CommonData.defaultVaccineType;
      String selectedAge = prefs.getString(CommonData.agePref).trim() ??
          CommonData.defaultVaccineType;

      vaccineSelected =
          vaccineSelected.trim().replaceAll(' ', '_').toLowerCase();
      List<String> _available = [];

      final List<Map> userLocations =
          await _dataFunctions.getUserTable(database);

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
            String availableCapacity =
                eachSession['available_capacity'].toString().trim() ?? '0';
            if (availableCapacity != '0') {
              String vaccineInSession = eachSession['vaccine']
                  .toString()
                  .trim()
                  .replaceAll(' ', '_')
                  .toLowerCase();

              String defaultVaccine =
                  CommonData.defaultVaccineType.toLowerCase();

              if (vaccineInSession.contains(vaccineSelected) ||
                  vaccineSelected.contains(defaultVaccine)) {
                // Check Ages based on user selection.
                if (selectedAge.contains(CommonData.defaultVaccineType))
                  filterZeroCapacity.add(eachSession);
                else {
                  String ageInSessionStr =
                      eachSession['min_age_limit'].toString().trim();
                  int minAgeLimit = int.tryParse(ageInSessionStr) ?? 0;
                  int userSelectedAge = int.tryParse(selectedAge) ?? 0;
                  if (userSelectedAge >= minAgeLimit)
                    filterZeroCapacity.add(eachSession);
                }
              }
            }
          });

          if (filterZeroCapacity.isNotEmpty)
            _available.add(eachCenter['name'].toString());
        });
      }

      if (_available.isNotEmpty) {
        await flutterLocalNotificationsPlugin.show(
          0,
          'Vaccine Available!',
          'Centres: ' + _available.join(", "),
          platformChannelSpecifics,
        );
      }
    } catch (_) {}
  }
}
