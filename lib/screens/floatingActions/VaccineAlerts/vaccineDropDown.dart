import 'package:flutter/material.dart';

class GenericTypeDropDown extends StatefulWidget {
  final List<String> list;
  final String value;
  final Function onChangeEvent;
  final String hintText;

  const GenericTypeDropDown(
      {@required this.list,
      @required this.value,
      @required this.onChangeEvent,
      @required this.hintText,
      Key key})
      : super(key: key);

  @override
  _GenericTypeDropDownState createState() => _GenericTypeDropDownState();
}

class _GenericTypeDropDownState extends State<GenericTypeDropDown> {
  final String loadingStr = 'Loading';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            widget.hintText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[100]
                    : Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? 1
                          : 0,
                ),
                child: DropdownButtonHideUnderline(
                  child: _dropDownBtnGeneric(
                    value: widget.value,
                    hintText: widget.hintText,
                    function: widget.onChangeEvent,
                    list: widget.list,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropDownBtnGeneric({
    @required String value,
    @required String hintText,
    @required Function function,
    @required List<String> list,
  }) =>
      DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Text(hintText),
        onChanged: (String value) => function(value),
        items: List.generate(
          list.length,
          (index) => DropdownMenuItem<String>(
            value: list.elementAt(index),
            child: Text(
              list.elementAt(index),
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}
