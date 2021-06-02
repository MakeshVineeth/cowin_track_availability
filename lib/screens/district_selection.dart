import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/db/selectedOptionProvider.dart';
import 'package:cowin_track_availability/interface/locationsDropDown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DistrictSelection extends StatefulWidget {
  const DistrictSelection({Key key}) : super(key: key);

  @override
  _DistrictSelectionState createState() => _DistrictSelectionState();
}

class _DistrictSelectionState extends State<DistrictSelection> {
  DatabaseProvider _databaseProvider;
  SelectedOptionProvider _selectedOptionProvider;

  Map<String, int> districts = {};
  String dropDownValState;
  final DataFunctions _dataFunctions = DataFunctions();

  @override
  Widget build(BuildContext context) {
    _databaseProvider = Provider.of<DatabaseProvider>(context);
    _selectedOptionProvider =
        Provider.of<SelectedOptionProvider>(context, listen: true);

    return LocationsDropDown(
      futureMethod: loadData(),
      value: dropDownValState,
      list: districts,
      onChangeEvent: onSelectedEvent,
      hintText: 'Select District',
    );
  }

  void onSelectedEvent(String value) {
    try {
      _selectedOptionProvider.districtID = districts[value];
      _selectedOptionProvider.districtName = value;

      if (mounted) setState(() => dropDownValState = value);

      _selectedOptionProvider.update();
    } catch (e) {}
  }

  Future<void> loadData() async {
    try {
      districts.clear();
      if (_selectedOptionProvider.stateName == null) return;

      districts.clear();
      final Database db = _databaseProvider.database;
      final String tableName =
          _selectedOptionProvider.stateName.trim().replaceAll(' ', '_');

      if (await _dataFunctions.isTableNotExists(tableName, db))
        await _dataFunctions.getDistricts(db, _selectedOptionProvider.stateID,
            _selectedOptionProvider.stateName);

      var data = await db.rawQuery('SELECT * FROM $tableName');

      data.forEach((Map<String, dynamic> element) {
        String name = element['districtName'];
        int id = element['districtID'];
        districts.addAll({name: id});
      });
    } catch (e) {
      print(e);
      return;
    }
  }
}
