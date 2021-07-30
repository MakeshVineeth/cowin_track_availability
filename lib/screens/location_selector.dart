import 'package:animations/animations.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/db/selectedOptionProvider.dart';
import 'package:cowin_track_availability/global_functions.dart';
import 'package:cowin_track_availability/interface/locationsDropDown.dart';
import 'package:cowin_track_availability/screens/district_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _textEditingController = TextEditingController();

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
    _animationController.forward();
    _databaseProvider = ReadContext(context).read<DatabaseProvider>();
    _selectedOptionProvider =
        ReadContext(context).read<SelectedOptionProvider>();

    return FadeScaleTransition(
      animation: _animationController,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CommonData.radius),
        ),
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
            SizedBox(height: 10),
            Text('(or)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(height: 10),
            SizedBox(
              width: 30,
              child: TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                scrollPhysics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[700]),
                  hintText: "Enter Pin Code",
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white70
                      : Colors.black45,
                ),
              ),
            ),
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
    String text = _textEditingController.text.trim();
    // For Pin Code
    if (text.isNotEmpty) {
      int check = int.tryParse(text);

      if (check != null) {
        _selectedOptionProvider.stateName = 'Pin Code';
        _selectedOptionProvider.stateID = 0;
        _selectedOptionProvider.districtID = 0;
        _selectedOptionProvider.districtName = text;
        _selectedOptionProvider.update();
      }
    }

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
    } catch (_) {}
  }

  Future<void> loadData() async {
    try {
      final Database db = _databaseProvider.database;
      await _dataFunctions.getStatesData(db);
      var data = await db.rawQuery('SELECT * FROM ${CommonData.stateTable}');

      data.forEach((Map<String, dynamic> element) {
        final String name = element['stateName'];
        final int id = element['stateID'];

        _locations.addAll({name: id});
      });
    } catch (_) {
      return;
    }
  }
}
