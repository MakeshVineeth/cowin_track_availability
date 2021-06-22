import 'package:battery_optimization/battery_optimization.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void showPlayStorePage() {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing();
  }

  Future<void> askForReview({bool action = false}) async {
    try {
      const String reviewCountPrefs = 'review_count';
      const String dateStrPrefs = 'review_date';

      final prefs = await SharedPreferences.getInstance();
      int reviewAskedCount = prefs.getInt(reviewCountPrefs) ?? 0;

      if (reviewAskedCount > 2) return;

      String dateStr = prefs.getString(dateStrPrefs);
      DateTime now = DateTime.now();

      DateTime dateCheck;
      // If dateStr is null, it means there is no shared preference yet which should mean first time.
      if (dateStr == null) {
        await prefs.setString(dateStrPrefs, now.toString());
        dateCheck = now;
      } else
        dateCheck = DateTime.tryParse(dateStr);

      Duration difference = dateCheck.difference(now);

      if ((action && reviewAskedCount == 0) || difference.inDays >= 1) {
        final InAppReview inAppReview = InAppReview.instance;
        final bool isAvailable = await inAppReview.isAvailable();

        if (isAvailable)
          Future.delayed(const Duration(seconds: 3), () async {
            await inAppReview.requestReview();
            await prefs.setInt(reviewCountPrefs, reviewAskedCount++);
          });
      }
    } catch (_) {}
  }

  void displayAbout(BuildContext context) => showAboutDialog(
        context: context,
        applicationName: CommonData.appTitle,
        applicationVersion: CommonData.appVer,
        applicationLegalese: CommonData.appDesc,
        children: <Widget>[
          SizedBox(height: 12),
          Text(
            'If you\'ve liked our app, please do give us a 5 star rating. It helps us a lot 😄',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
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
      double version = double.tryParse(CommonData.appVer);

      if (version == null) return false;

      final pref = await SharedPreferences.getInstance();
      double current = pref.getDouble(CommonData.versionPref);

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
