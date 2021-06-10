import 'package:flutter/material.dart';

class SelectedOptionProvider extends ChangeNotifier {
  String stateName;
  String districtName;
  int stateID;
  int districtID;

  void update() {
    notifyListeners();
  }
}
