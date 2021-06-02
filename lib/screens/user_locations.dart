import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/db/selectedOptionProvider.dart';
import 'package:cowin_track_availability/interface/locationCard.dart';
import 'package:cowin_track_availability/screens/location_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLocations extends StatefulWidget {
  @override
  _UserLocationsState createState() => _UserLocationsState();
}

class _UserLocationsState extends State<UserLocations> {
  DatabaseProvider _databaseProvider;
  SelectedOptionProvider _selectedOptionProvider;
  DataFunctions _dataFunctions = DataFunctions();
  List<Map> _list = [];

  @override
  Widget build(BuildContext context) {
    _databaseProvider = Provider.of<DatabaseProvider>(context);
    _selectedOptionProvider = Provider.of<SelectedOptionProvider>(context);

    return FutureBuilder(
      future: process(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _list.isNotEmpty) {
          return ListView(
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              Column(
                children: List.generate(
                  _list.length,
                  (index) => LocationCard(
                    districtName: _list.elementAt(index)['districtName'],
                    stateName: _list.elementAt(index)['stateName'],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(child: popUpSelector()),
            ],
          );
        } else {
          return Center(child: popUpSelector());
        }
      },
    );
  }

  Future<void> process() async {
    await _dataFunctions.createUserTable(_databaseProvider.database);
    _list = await _dataFunctions.getUserTable(_databaseProvider.database);
  }

  Widget popUpSelector() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
      ),
      onPressed: () => showDialogLocations(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  void showDialogLocations() => showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
          value: _databaseProvider,
          builder: (context, widget) => ChangeNotifierProvider.value(
            value: _selectedOptionProvider,
            builder: (context, widget) => LocationSelector(),
          ),
        ),
      );
}
