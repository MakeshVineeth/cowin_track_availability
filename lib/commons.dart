import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';

class CommonData {
  static final String appTitle = 'CoWIN Track Availability';
  static final String appVer = '1.4';
  static final String appDesc =
      'An Open-Source App that can track COVID-19 Vaccines in India. Supports Notifications and Light/Dark Themes. Retrieves data directly from the CoWIN Public APIs. You still have to go through CoWIN website in order to book the vaccine slot.';
  static final String logoAsset = 'assets/vaccine.png';
  static final String vaccineJsonUrl =
      'https://raw.githubusercontent.com/MakeshVineeth/cowin_track_availability/master/assets/jsonWeb.json';
  static final String ageJsonUrl =
      'https://raw.githubusercontent.com/MakeshVineeth/cowin_track_availability/master/assets/jsonAge.json';

  static final String stateTable = 'States';
  static final String userTable = 'UserChoice';

  static final double radius = 20.0;
  static final RoundedRectangleBorder roundedRectangleBorder =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );

  static final double smallFont = 15.0;
  static final double outerPadding = 10.0;
  static final String defaultVaccineType =
      'ANY'; // Also used as Common type for any list.
  static final String aarogyaSetu = 'nic.goi.aarogyasetu';
  static final String coWin = 'com.cowinapp.app';
  static final String vaccineHintText = 'Vaccine Type: ';
  static final String ageSelectionHint = 'Minimum Age: ';
  static final String agePref = 'age_pref';
  static final String dateFormat = 'dd-MM-yyyy';

  static final String versionPref = 'versionPref';
  static final String versionAsset = 'assets/version.txt';
  static final String batteryOptimizationPref = 'first_launch';

  static final Map<String, int> intervals = {
    '15 min': 15,
    '30 min': 30,
    '1 Hr': 60,
    '3 Hrs': 180,
    '6 Hrs': 360,
    '12 Hrs': 720,
    '24 Hrs': 1440,
  };

  static ThemeData getTheme(BuildContext context, Brightness brightness) {
    bool isDarkTheme = brightness == Brightness.dark;
    Color background = isDarkTheme ? Colors.black : Colors.white;
    Color primary = isDarkTheme ? Colors.lightBlue : Colors.indigo;
    Color fg = isDarkTheme ? Colors.white : Colors.black;

    return ThemeData(
      brightness: brightness,
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: fg),
        backgroundColor: background,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: brightness,
          statusBarIconBrightness:
              isDarkTheme ? Brightness.light : Brightness.dark,
        ),
        titleTextStyle:
            Theme.of(context).textTheme.headline6.copyWith(color: fg),
      ),
      primaryColor: primary,
      primarySwatch: primary,
      backgroundColor: background,
      scaffoldBackgroundColor: background,
      cardColor: background,
      applyElevationOverlayColor: isDarkTheme,
      cardTheme: CardTheme(
        shape: roundedRectangleBorder,
        elevation: isDarkTheme ? 10 : 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: roundedRectangleBorder),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: roundedRectangleBorder,
        ),
      ),
    );
  }

  static SystemUiOverlayStyle changeStatusBarColor(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    final SystemUiOverlayStyle flatTheme = SystemUiOverlayStyle(
      systemNavigationBarColor: isLightTheme ? Colors.white : Colors.black,
      systemNavigationBarIconBrightness:
          isLightTheme ? Brightness.dark : Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isLightTheme ? Brightness.dark : Brightness.light,
    );

    SystemChrome.setSystemUIOverlayStyle(flatTheme);
    return flatTheme;
  }

  static PromptButtonTheme scrollUpBtnTheme(BuildContext context) =>
      PromptButtonTheme(
        elevation: 5.0,
        icon: Icon(
          Icons.arrow_drop_up,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
      );
}
