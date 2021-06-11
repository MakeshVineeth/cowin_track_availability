import 'package:cowin_track_availability/global_functions.dart';
import 'package:cowin_track_availability/interface/displayResult.dart';
import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final Map map;
  final bool showDivider;
  final GlobalFunctions globalFunctions = GlobalFunctions();

  DetailItem({@required this.map, Key key, this.showDivider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String blockName = map['address'].toString();
    String pinCode = map['pincode'].toString();
    String address = '${map['address']}, $pinCode' ?? '';

    if (address.isEmpty) address = blockName + pinCode;

    return Column(
      children: [
        DisplayResult(
          text: map['name'].toString(),
          header: 'Name: ',
        ),
        DisplayResult(
          text: map['available_capacity'].toString(),
          header: 'Available Doses: ',
          color: globalFunctions.getColorFromAvailability(
              availabilityStr: '${map['available_capacity']}'),
        ),
        Row(
          children: [
            DisplayResult(
              text: map['available_capacity_dose1'].toString() ?? '--',
              header: 'Dose 1: ',
              color: globalFunctions.getColorFromAvailability(
                  availabilityStr: '${map['available_capacity']}'),
            ),
            SizedBox(width: 10),
            DisplayResult(
              text: map['available_capacity_dose2'].toString() ?? '--',
              header: 'Dose 2: ',
              color: globalFunctions.getColorFromAvailability(
                  availabilityStr: '${map['available_capacity']}'),
            ),
          ],
        ),
        DisplayResult(
          text: map['vaccine'].toString(),
          header: 'Vaccine: ',
          color: Colors.blue[800],
        ),
        DisplayResult(
          text: map['min_age_limit'].toString(),
          header: 'Min Age Limit: ',
        ),
        DisplayResult(
          text: address,
          header: 'Address: ',
        ),
        DisplayResult(
          text: map['fee'].toString() == '0'
              ? 'Free'
              : map['fee'].toString() + '₹',
          header: 'Fee Type: ',
        ),
        if (showDivider) Divider(),
      ],
    );
  }
}
