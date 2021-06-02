import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_apps/device_apps.dart';

class GlobalFunctions {
  final Duration _timeOutDur = const Duration(minutes: 1);

  Future<Response> getWebResponse(String url) async {
    try {
      Uri _fullUrl = Uri.tryParse(url);

      if (_fullUrl == null) return null;

      return get(_fullUrl).timeout(_timeOutDur);
    } catch (e) {
      return null;
    }
  }

  String getTodayDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  String getTomorrowDate() {
    DateTime now = DateTime.now();
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    return DateFormat('dd-MM-yyyy').format(tomorrow);
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
