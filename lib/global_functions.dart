import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
}
