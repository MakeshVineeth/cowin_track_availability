import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:cowin_track_availability/db/dbProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationCard extends StatelessWidget {
  final String stateName;
  final String districtName;
  final DataFunctions _dataFunctions = DataFunctions();

  LocationCard({@required this.stateName, @required this.districtName, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseProvider _databaseProvider =
        Provider.of<DatabaseProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: CommonData.roundedRectangleBorder,
          onTap: () {},
          title: Text(districtName),
          subtitle: Text(stateName),
          trailing: IconButton(
            onPressed: () => _dataFunctions.deleteRow(
              database: _databaseProvider,
              tableName: CommonData.userTable,
              condition: districtName,
            ),
            icon: Icon(
              Icons.delete_outline_rounded,
            ),
          ),
        ),
      ),
    );
  }
}
