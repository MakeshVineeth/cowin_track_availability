import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkDownView extends StatelessWidget {
  final String changelog;

  const MarkDownView({Key key, @required this.changelog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CommonData.radius)),
      content: Markdown(
        data: changelog,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      ),
    );
  }
}
