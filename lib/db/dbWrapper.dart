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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFunctions.loadDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          DatabaseProvider _databaseProvider = snapshot.data;

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
