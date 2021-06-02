import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/interface/placeholdSpinner.dart';
import 'package:flutter/material.dart';

class PlaceHolderScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CommonData.getTheme(context, Brightness.light),
      darkTheme: CommonData.getTheme(context, Brightness.dark),
      themeMode: ThemeMode.system,
      title: CommonData.appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(CommonData.appTitle),
        ),
        body: PlaceholdSpinner(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
