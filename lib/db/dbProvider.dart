import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider extends ChangeNotifier {
  final Database database;
  final List<String> vaccinesList;

  DatabaseProvider({@required this.database, @required this.vaccinesList});

  void update() {
    notifyListeners();
  }
}
