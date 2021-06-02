import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';

class NotAvailableWidget extends StatelessWidget {
  final String place;

  const NotAvailableWidget(this.place);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: CommonData.outerPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            softWrap: true,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: 'Not available in ',
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: place,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: CommonData.smallFont,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
