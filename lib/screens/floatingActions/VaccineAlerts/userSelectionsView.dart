import 'package:cowin_track_availability/commons.dart';
import 'package:cowin_track_availability/interface/placeholdSpinner.dart';
import 'package:flutter/material.dart';
import 'package:cowin_track_availability/db/dataFunctions.dart';
import 'package:sqflite/sqflite.dart';

class UserSelectionsView extends StatefulWidget {
  final Database database;
  const UserSelectionsView({@required this.database});

  @override
  _UserSelectionsViewState createState() => _UserSelectionsViewState();
}

class _UserSelectionsViewState extends State<UserSelectionsView> {
  final DataFunctions _dataFunctions = DataFunctions();
  Future _future;

  @override
  void initState() {
    super.initState();
    _future = _dataFunctions.getUserTable(widget.database);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError)
              return userSelectedLocations(snapshot.data);
            else
              return PlaceholdSpinner();
          },
        ),
      ),
    );
  }

  Widget userSelectedLocations(List<Map> _list) {
    if (_list.isNotEmpty)
      return ListView.separated(
        itemCount: _list.length,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) => ListTile(
          onTap: () {},
          shape: CommonData.roundedRectangleBorder,
          title: Text(
            _list.elementAt(index)['districtName'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _list.elementAt(index)['stateName'].toString(),
          ),
        ),
      );
    else
      return Center(
        child: Text(
          'Please add any locations!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
  }
}
