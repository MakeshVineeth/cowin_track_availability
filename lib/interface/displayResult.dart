import 'package:flutter/material.dart';

class DisplayResult extends StatelessWidget {
  final String text;
  final String header;
  final Color color;

  const DisplayResult({@required this.text, @required this.header, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            header,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color ?? Theme.of(context).textTheme.bodyText1.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
