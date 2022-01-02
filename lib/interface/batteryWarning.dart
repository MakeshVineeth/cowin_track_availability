import 'package:optimization_battery/optimization_battery.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BatteryWarning extends StatelessWidget {
  const BatteryWarning({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CommonData.radius),
      ),
      title: Text('Allow App to run in the Background'),
      content: Text(
          'Please whitelist our app from Battery optimization in order to get timely notifications! Proceed to open the Settings and disable the Battery optimization.'),
      actions: [
        TextButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool(CommonData.batteryOptimizationPref, false);
            Navigator.pop(context);
          },
          child: Text('No Need'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            OptimizationBattery.openBatteryOptimizationSettings();
          },
          child: Text('Open Settings'),
        ),
      ],
    );
  }
}
