import 'package:battery_optimization/battery_optimization.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_apps/device_apps.dart';

class GlobalFunctions {
  final Duration _timeOutDur = const Duration(minutes: 1);

  Future<http.Response> getWebResponse(String url) async {
    try {
      Uri _fullUrl = Uri.tryParse(url);
      if (_fullUrl == null) return null;

      return http.get(_fullUrl).timeout(_timeOutDur);
    } catch (_) {
      return null;
    }
  }

  String getTodayDate() =>
      DateFormat(CommonData.dateFormat).format(DateTime.now());

  String getTomorrowDate() {
    DateTime now = DateTime.now();
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    return DateFormat(CommonData.dateFormat).format(tomorrow);
  }

  void launchURL(String url) async {
    try {
      url = Uri.encodeFull(url);
      launch(url);
    } catch (_) {}
  }

  void displayAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: CommonData.appTitle,
      applicationVersion: CommonData.appVer,
      applicationLegalese: CommonData.appDesc,
      children: <Widget>[
        SizedBox(height: 12),
        Text(
          'If you\'ve liked our app, please do give us a 5 star rating. It helps us a lot :)',
          textAlign: TextAlign.center,
          softWrap: true,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
      applicationIcon: Image(
        width: 30,
        image: AssetImage(
          CommonData.logoAsset,
        ),
      ),
    );
  }

  void launchApp(String packageName) async {
    try {
      bool isInstalled = await DeviceApps.isAppInstalled(packageName);
      if (isInstalled)
        DeviceApps.openApp(packageName);
      else
        launchURL(
            'https://play.google.com/store/apps/details?id=' + packageName);
    } catch (_) {}
  }

  Future<bool> isAppNewVersion() async {
    try {
      String verStr = await rootBundle.loadString(CommonData.versionAsset);
      double version = double.tryParse(verStr);

      if (version == null) return false;

      final pref = await SharedPreferences.getInstance();
      double current = pref.getDouble(CommonData.versionPref) ?? null;

      if (current == null || current > version)
        return true;
      else
        return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> batteryOptimizationCheck() async {
    try {
      bool ignored = await BatteryOptimization.isIgnoringBatteryOptimizations();
      return ignored;
    } catch (_) {
      return false;
    }
  }

  Future<bool> getBatteryPref() async {
    try {
      final pref = await SharedPreferences.getInstance();
      bool isFirst = pref.getBool(CommonData.batteryOptimizationPref) ?? true;
      return isFirst;
    } catch (_) {
      return true;
    }
  }

  Color getColorFromAvailability({@required String availabilityStr}) {
    Color error = Colors.deepOrange[600];
    Color okay = Colors.green[800];
    try {
      if (availabilityStr == '0') return error;
      int count = int.tryParse(availabilityStr);

      return count < 10 ? error : okay;
    } catch (_) {
      return error;
    }
  }
}
