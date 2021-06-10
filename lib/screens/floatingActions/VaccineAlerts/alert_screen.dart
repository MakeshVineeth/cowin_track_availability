import 'package:background_fetch/background_fetch.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/userSelectionsView.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/vaccineDropDown.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/vaccine_alert_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertScreen extends StatefulWidget {
  static final String vaccinePrefs = 'vaccine_prefs';

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final String prefKey = 'notify';
  final String intervalPref = '';
  bool _enabledStatus = false;
  DatabaseProvider _databaseProvider;
  String selectedVaccine = CommonData.defaultVaccineType;
  String selectedInterval = CommonData.intervals.keys.elementAt(0);

  @override
  void initState() {
    setPrefsEnabled();
    super.initState();
  }

  void setPrefsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    bool getEnabledStatus = prefs.getBool(prefKey) ?? false;
    String getVaccine = prefs.getString(AlertScreen.vaccinePrefs) ??
        CommonData.defaultVaccineType;
    String interval =
        prefs.getString(intervalPref) ?? CommonData.intervals.keys.elementAt(0);

    if (mounted)
      setState(() {
        _enabledStatus = getEnabledStatus;
        selectedVaccine = getVaccine;
        selectedInterval = interval;
      });
  }

  void setVaccineType(String value) {
    setState(() => selectedVaccine = value);
    changeSwitchStatus(
        false); // When Vaccine has been changed from DropDown, turn off the background service.
  }

  Future<void> initPlatformState() async {
    try {
      if (!_enabledStatus) {
        await BackgroundFetch.configure(
          BackgroundFetchConfig(
            minimumFetchInterval: CommonData.intervals[selectedInterval],
            stopOnTerminate: false,
            enableHeadless: true,
            startOnBoot: true,
            forceAlarmManager: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY,
          ),
          onFetch,
          onTimeOut,
        );
      }
    } catch (_) {}
  }

  Future<void> onFetch(String taskId) async {
    try {
      if (taskId == 'flutter_background_fetch') {
        await VaccineAlertClass()
            .getAlert(database: _databaseProvider?.database);
        BackgroundFetch.finish(taskId);
      }
    } catch (_) {}
  }

  Future<void> onTimeOut(String taskId) async {
    try {
      BackgroundFetch.finish(taskId);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    _databaseProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(CommonData.appTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You\'ll be alerted for availability of Vaccines in these following locations:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
            SizedBox(height: 10),
            if (MediaQuery.of(context).orientation == Orientation.portrait)
              Expanded(
                child: UserSelectionsView(database: _databaseProvider.database),
              ),
            SizedBox(height: 10),
            GenericTypeDropDown(
              list: CommonData.intervals.keys.toList(),
              value: selectedInterval,
              onChangeEvent: setInterval,
              hintText: 'Select Time',
            ),
            SizedBox(height: 5),
            GenericTypeDropDown(
              list: _databaseProvider.vaccinesList,
              value: selectedVaccine,
              onChangeEvent: setVaccineType,
              hintText: CommonData.vaccineHintText,
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text('Enable Notifications'),
              secondary: Icon(Icons.notifications_active_outlined),
              value: _enabledStatus,
              onChanged: (bool status) => changeSwitchStatus(status),
            ),
          ],
        ),
      ),
    );
  }

  void changeSwitchStatus(bool status) async {
    if (status)
      await initPlatformState();
    else
      await BackgroundFetch.stop().then(
          (int status) => print('VaccineAlertService: Stopped.: $status'));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, status);
    await prefs.setString(AlertScreen.vaccinePrefs, selectedVaccine);
    await prefs.setString(intervalPref, selectedInterval);

    if (mounted) setState(() => _enabledStatus = status);
  }

  void setInterval(String value) {
    setState(() => selectedInterval = value);
    changeSwitchStatus(false);
  }
}
