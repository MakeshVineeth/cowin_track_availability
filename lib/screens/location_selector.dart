import 'package:animations/animations.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/db/selectedOptionProvider.dart';
import 'package:cowin_track_availability/global_functions.dart';
import 'package:cowin_track_availability/interface/locationsDropDown.dart';
import 'package:cowin_track_availability/screens/district_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class LocationSelector extends StatefulWidget {
  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector>
    with SingleTickerProviderStateMixin {
  Map<String, int> _locations = {};
  final GlobalFunctions globalFunctions = GlobalFunctions();
  final DataFunctions _dataFunctions = DataFunctions();
  DatabaseProvider _databaseProvider;
  SelectedOptionProvider _selectedOptionProvider;
  String dropDownValState;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      value: 0.0,
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 200),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _databaseProvider = Provider.of<DatabaseProvider>(context);
    _selectedOptionProvider = Provider.of<SelectedOptionProvider>(context);
    _animationController.forward();

    return FadeScaleTransition(
      animation: _animationController,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CommonData.radius)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LocationsDropDown(
              futureMethod: loadData(),
              value: dropDownValState,
              list: _locations,
              onChangeEvent: onSelectedEvent,
              hintText: 'Select State',
            ),
            SizedBox(height: 10),
            DistrictSelection(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => cancel(),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => okEvent(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void cancel() {
    try {
      _animationController
          .reverse()
          .whenCompleteOrCancel(() => Navigator.pop(context));
    } catch (_) {}
  }

  void okEvent() async {
    if (_selectedOptionProvider.districtID != null &&
        _selectedOptionProvider.districtName != null &&
        _selectedOptionProvider.stateID != null &&
        _selectedOptionProvider.stateName != null) {
      await _dataFunctions.insertUserSelection(
        stateName: _selectedOptionProvider.stateName,
        stateID: _selectedOptionProvider.stateID,
        districtName: _selectedOptionProvider.districtName,
        districtID: _selectedOptionProvider.districtID,
        database: _databaseProvider.database,
      );

      _databaseProvider.update();
    }

    _animationController
        .reverse()
        .whenCompleteOrCancel(() => Navigator.pop(context));
  }

  void onSelectedEvent(String value) {
    try {
      _selectedOptionProvider.stateID = _locations[value];
      _selectedOptionProvider.stateName = value;

      if (mounted) setState(() => dropDownValState = value);

      _selectedOptionProvider.update();
    } catch (e) {}
  }

  Future<void> loadData() async {
    try {
      final Database db = _databaseProvider.database;
      await _dataFunctions.getStatesData(db);
      var data = await db.rawQuery('SELECT * FROM ${CommonData.stateTable}');

      data.forEach((Map<String, dynamic> element) {
        String name = element['stateName'];
        int id = element['stateID'];
        _locations.addAll({name: id});
      });
    } catch (e) {
      print(e);
      return;
    }
  }
}
