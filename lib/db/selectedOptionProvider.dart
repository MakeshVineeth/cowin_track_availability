import 'package:flutter/cupertino.dart';

class SelectedOptionProvider extends ChangeNotifier {
  String stateName;
  String districtName;
  int stateID;
  int districtID;

  void update() {
    notifyListeners();
  }
}
