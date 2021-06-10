import 'package:background_fetch/background_fetch.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dbWrapper.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/alert_screen.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/vaccine_alert_functions.dart';
import 'package:cowin_track_availability/screens/home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MaterialRootWidget());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  try {
    String taskId = task.taskId;
    if (taskId == 'flutter_background_fetch') {
      bool isTimeout = task.timeout;

      if (isTimeout) {
        BackgroundFetch.finish(taskId);
        return;
      }

      await VaccineAlertClass().getAlert();
      BackgroundFetch.finish(taskId);
    }
  } catch (_) {}
}

class MaterialRootWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataBaseWrapper(
      child: MaterialApp(
        theme: CommonData.getTheme(context, Brightness.light),
        darkTheme: CommonData.getTheme(context, Brightness.dark),
        themeMode: ThemeMode.system,
        title: CommonData.appTitle,
        initialRoute: '/',
        routes: {
          '/': (context) => Home(),
          '/alert': (context) => AlertScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
