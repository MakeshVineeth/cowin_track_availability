import 'dart:convert';
import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/global_functions.dart';
import 'package:cowin_track_availability/interface/notAvailableWidget.dart';
import 'package:cowin_track_availability/screens/todayScreen/detailItem.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CentresList extends StatefulWidget {
  final String districtID;
  final String stateID;
  final String stateName;
  final String districtName;
  final bool isToday;
  final String vaccineSelected;

  const CentresList({
    @required this.districtID,
    @required this.stateID,
    @required this.stateName,
    @required this.districtName,
    @required this.isToday,
    @required this.vaccineSelected,
    Key key,
  }) : super(key: key);

  @override
  _CentresListState createState() => _CentresListState();
}

class _CentresListState extends State<CentresList> {
  List<Map> _centresList = [];
  GlobalFunctions _globalFunctions = GlobalFunctions();
  final String requestURL =
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=';
  Future<void> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _centresList.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.all(CommonData.outerPadding),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        widget.districtName + ', ' + widget.stateName,
                        style: TextStyle(
                          fontSize: CommonData.smallFont,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      ExpandChild(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            _centresList.length,
                            (index) => DetailItem(
                              map: _centresList.elementAt(index),
                              showDivider: _centresList.length > 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              _centresList.isEmpty)
            return NotAvailableWidget(widget.districtName);

          // placeholder for initial loading.
          else
            return placeHolderWithText();
        });
  }

  Widget placeHolderWithText() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: CommonData.smallFont,
            height: CommonData.smallFont,
            child: LoadingIndicator(
              indicatorType: Indicator.ballScale,
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          SizedBox(width: 5),
          Text(
            'Checking on ' + widget.districtName,
            style: TextStyle(
              fontSize: CommonData.smallFont,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    try {
      _centresList.clear();
      final String date = widget.isToday
          ? _globalFunctions.getTodayDate()
          : _globalFunctions.getTomorrowDate();
      final url = requestURL + widget.districtID + '&date=' + date;

      Response response = await _globalFunctions.getWebResponse(url);

      if (response.statusCode != 200 || response == null) return;
      var mapTemp = json.decode(response.body)['sessions'] as List<dynamic>;

      mapTemp.forEach((element) {
        Map map = element;
        String vaccine = map['vaccine'].toString();
        String count = map['available_capacity'].toString() ?? '';

        if (count != '0' &&
            (vaccine.contains(widget.vaccineSelected) ||
                widget.vaccineSelected.contains(CommonData.defaultVaccineType)))
          _centresList.add(map);
      });
    } catch (e) {
      print(e);
    }
  }
}
