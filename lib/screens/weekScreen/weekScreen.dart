import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:cowin_track_availability/interface/notAvailableWidget.dart';
import 'package:cowin_track_availability/interface/placeholdSpinner.dart';
import 'package:cowin_track_availability/screens/floatingActions/VaccineAlerts/vaccineDropDown.dart';
import 'package:cowin_track_availability/screens/weekScreen/centerDetailCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:provider/provider.dart';

class WeekScreen extends StatefulWidget {
  @override
  _WeekScreenState createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  final DataFunctions _dataFunctions = DataFunctions();
  DatabaseProvider _databaseProvider;
  List<Widget> centres = [];
  String selectedVaccine = CommonData.defaultVaccineType;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _databaseProvider = Provider.of<DatabaseProvider>(context);

    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
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
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    controller: _scrollController,
                    itemCount: centres.length,
                    itemBuilder: (context, index) => centres.elementAt(index),
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

  Future<void> getData() async {
    try {
      centres.clear();
      List<Map> userLocations =
          await _dataFunctions.getUserTable(_databaseProvider.database);

      // Gets all user selected locations and looping through each.
      for (Map district in userLocations) {
        String districtID = district['districtID'].toString();
        List<dynamic> map = await _dataFunctions.getCalendarData(
          districtID: districtID,
          database: _databaseProvider.database,
        );

        if (map.isEmpty) {
          String districtName = district['districtName'];
          centres.add(NotAvailableWidget(districtName));
        }

        // map contains all the centres in a district.
        map.forEach((eachCenter) {
          List sessions = eachCenter['sessions'];
          List filterZeroCapacity = [];

          sessions.forEach((eachSession) {
            if (eachSession['available_capacity'].toString() != '0') {
              String vaccineInSession = eachSession['vaccine']
                  .toString()
                  .replaceAll(' ', '_')
                  .toLowerCase();

              String selectedVaccineFormatted =
                  selectedVaccine.replaceAll(' ', '_').toLowerCase();

              if (vaccineInSession.contains(selectedVaccineFormatted) ||
                  selectedVaccineFormatted
                      .contains(CommonData.defaultVaccineType))
                filterZeroCapacity.add(eachSession);
            }
          });

          if (filterZeroCapacity.isNotEmpty)
            centres.add(CenterDetailCard(
              center: eachCenter,
              session: filterZeroCapacity,
            ));
        });
      }
    } catch (_) {}
  }

  void setVaccineType(String value) => setState(() => selectedVaccine = value);
}
