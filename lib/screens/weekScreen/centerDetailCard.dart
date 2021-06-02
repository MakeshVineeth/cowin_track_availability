import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:cowin_track_availability/interface/displayResult.dart';

class CenterDetailCard extends StatelessWidget {
  final Map center;
  final List session;

  const CenterDetailCard(
      {@required this.center, Key key, @required this.session})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              center['name'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            DisplayResult(
              header: 'Address: ',
              text: center['address'],
            ),
            DisplayResult(
              header: 'District: ',
              text: '${center['district_name']}, ${center['pincode']}',
            ),
            DisplayResult(
              header: 'State: ',
              text: center['state_name'],
            ),
            DisplayResult(
              header: 'Fee Type: ',
              text: center['fee_type'],
            ),
            ExpandChild(
              child: Column(
                children: _sessions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sessions() {
    return List.generate(session.length, (index) {
      return Column(
        children: [
          if (index == 0) Divider(),
          DisplayResult(
            header: 'Date: ',
            text: session.elementAt(index)['date'].toString(),
          ),
          DisplayResult(
            header: 'Available Doses: ',
            text: session.elementAt(index)['available_capacity'].toString(),
            color: int.tryParse(session
                        .elementAt(index)['available_capacity']
                        .toString()) <
                    10
                ? Colors.deepOrange[600]
                : Colors.green[800],
          ),
          DisplayResult(
            header: 'Min Age Limit: ',
            text: session.elementAt(index)['min_age_limit'].toString(),
          ),
          DisplayResult(
            header: 'Vaccine: ',
            text: session.elementAt(index)['vaccine'].toString(),
            color: Colors.blue[800],
          ),
          Divider(),
        ],
      );
    });
  }
}
