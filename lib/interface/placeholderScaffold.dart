import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/interface/placeholdSpinner.dart';
import 'package:flutter/material.dart';

class PlaceHolderScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(CommonData.appTitle),
      ),
      body: PlaceholdSpinner(),
    );
  }
}
