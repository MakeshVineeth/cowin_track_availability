import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider extends ChangeNotifier {
  final Database database;
  final List<String> vaccinesList;
  final List<String> ageList;

  DatabaseProvider(
      {@required this.database,
      @required this.vaccinesList,
      @required this.ageList});

  void update() {
    notifyListeners();
  }
}
