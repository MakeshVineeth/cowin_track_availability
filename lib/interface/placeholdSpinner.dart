import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PlaceholdSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
          pathBackgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
