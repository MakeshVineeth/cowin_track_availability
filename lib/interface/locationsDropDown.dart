import 'package:flutter/material.dart';

class LocationsDropDown extends StatefulWidget {
  final Future<void> futureMethod;
  final String value;
  final Map<String, int> list;
  final Function onChangeEvent;
  final String hintText;

  const LocationsDropDown(
      {@required this.futureMethod,
      @required this.value,
      @required this.list,
      @required this.onChangeEvent,
      @required this.hintText,
      Key key})
      : super(key: key);

  @override
  _LocationsDropDownState createState() => _LocationsDropDownState();
}

class _LocationsDropDownState extends State<LocationsDropDown> {
  final String loadingStr = 'Loading';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
          child: FutureBuilder(
            future: widget.futureMethod,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return _dropDownBtnGeneric(
                  value: widget.value,
                  hintText: widget.hintText,
                  function: widget.onChangeEvent,
                  list: widget.list,
                );
              else
                return placeHolder();
            },
          ),
        ),
      ),
    );
  }

  Widget _dropDownBtnGeneric({
    @required String value,
    @required String hintText,
    @required Function function,
    @required Map<String, int> list,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      hint: Text(hintText),
      onChanged: (String value) => function(value),
      items: list.keys
          .map<DropdownMenuItem<String>>(
            (String placeTitle) => DropdownMenuItem<String>(
              value: placeTitle,
              child: Text(placeTitle),
            ),
          )
          .toList(),
    );
  }

  Widget placeHolder() {
    return _dropDownBtnGeneric(
      value: loadingStr,
      function: null,
      hintText: loadingStr,
      list: const {},
    );
  }
}
