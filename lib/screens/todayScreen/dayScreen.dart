import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/global_functions.dart';
import 'package:cowin_track_availability/interface/placeholdSpinner.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/vaccineDropDown.dart';
import 'package:cowin_track_availability/screens/todayScreen/centresList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';

class DayScreen extends StatefulWidget {
  final bool isToday;

  const DayScreen({@required this.isToday, Key key}) : super(key: key);

  @override
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  List<Map> _userLocations = [];
  DataFunctions _dataFunctions = DataFunctions();
  GlobalFunctions _globalFunctions = GlobalFunctions();
  DatabaseProvider _databaseProvider;
  final ScrollController _scrollController = ScrollController();
  String selectedVaccine = CommonData.defaultVaccineType;

  @override
  Widget build(BuildContext context) {
    _databaseProvider = Provider.of<DatabaseProvider>(context);

    return FutureBuilder(
      future: _loadLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              Text(
                'Date: ' +
                    (widget.isToday
                        ? _globalFunctions.getTodayDate()
                        : _globalFunctions.getTomorrowDate()),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 5),
              GenericTypeDropDown(
                list: _databaseProvider.vaccinesList,
                value: selectedVaccine,
                onChangeEvent: setVaccineType,
                hintText: CommonData.vaccineHintText,
              ),
              Divider(
                height: 15,
                thickness: 1,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              Flexible(
                child: ScrollWrapper(
                  scrollController: _scrollController,
                  child: ListView.builder(
                    itemCount: _userLocations.length,
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    controller: _scrollController,
                    cacheExtent: 2000,
                    itemBuilder: (context, index) {
                      final Map item = _userLocations.elementAt(index);

                      return CentresList(
                        districtID: item['districtID'].toString(),
                        stateID: item['stateID'].toString(),
                        stateName: item['stateName'],
                        districtName: item['districtName'],
                        isToday: widget.isToday,
                        vaccineSelected: selectedVaccine,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return PlaceholdSpinner();
        }
      },
    );
  }

  Future<void> _loadLocations() async {
    try {
      _userLocations =
          await _dataFunctions.getUserTable(_databaseProvider.database);
    } catch (_) {}
  }

  void setVaccineType(String value) => setState(() => selectedVaccine = value);
}
