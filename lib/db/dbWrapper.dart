import 'dart:async';

import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/db/selectedOptionProvider.dart';
import 'package:cowin_track_availability/interface/placeholderScaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataBaseWrapper extends StatefulWidget {
  final Widget child;

  const DataBaseWrapper({@required this.child});

  @override
  _DataBaseWrapperState createState() => _DataBaseWrapperState();
}

class _DataBaseWrapperState extends State<DataBaseWrapper> {
  DataFunctions _dataFunctions = DataFunctions();
  DatabaseProvider _databaseProvider;

  @override
  void initState() {
    super.initState();

    // periodically runs the database update function to refresh the UI for latest data.
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (_databaseProvider != null) _databaseProvider.update();
    });
  }

  Future<void> getDatabaseProvider() async =>
      _databaseProvider = await _dataFunctions.loadDatabase();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDatabaseProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<SelectedOptionProvider>(
                  create: (_) => SelectedOptionProvider()),
              ChangeNotifierProvider<DatabaseProvider>(
                  create: (_) => _databaseProvider),
            ],
            builder: (context, child) => widget.child,
          );
        } else
          return PlaceHolderScaffold();
      },
    );
  }
}
