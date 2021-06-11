import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cowin_track_availability/commons.dart';
import 'package:flutter/material.dart';

class ThemeDialog extends StatefulWidget {
  const ThemeDialog({Key key}) : super(key: key);

  @override
  _ThemeDialogState createState() => _ThemeDialogState();
}

enum Themes { Light, Dark, Default }

extension parseThemeValue on Themes {
  String getThemeString() {
    return this.toString().split('.').last;
  }
}

extension getFromAdaptiveTheme on AdaptiveThemeMode {
  Themes getThemeValue() {
    Themes temp;

    switch (this) {
      case AdaptiveThemeMode.system:
        temp = Themes.Default;
        break;
      case AdaptiveThemeMode.light:
        temp = Themes.Light;
        break;
      case AdaptiveThemeMode.dark:
        temp = Themes.Dark;
        break;
      default:
        temp = Themes.Default;
        break;
    }

    return temp;
  }
}

class _ThemeDialogState extends State<ThemeDialog> {
  Themes _currentTheme = Themes.Default;
  final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CommonData.radius));

  @override
  void initState() {
    super.initState();
    initialTasks();
  }

  Future<void> initialTasks() async {
    try {
      AdaptiveThemeMode savedTheme = await AdaptiveTheme.getThemeMode();
      setState(() => _currentTheme = savedTheme.getThemeValue());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: shape,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            shape: shape,
            title: Text('${Themes.Light.getThemeString()}'),
            value: Themes.Light,
            groupValue: _currentTheme,
            onChanged: (Themes theme) => onChangeCallBack(theme),
          ),
          RadioListTile(
            shape: shape,
            title: Text('${Themes.Dark.getThemeString()}'),
            value: Themes.Dark,
            groupValue: _currentTheme,
            onChanged: (Themes theme) => onChangeCallBack(theme),
          ),
          RadioListTile(
            shape: shape,
            title: Text('${Themes.Default.getThemeString()}'),
            value: Themes.Default,
            groupValue: _currentTheme,
            onChanged: (Themes theme) => onChangeCallBack(theme),
          ),
        ],
      ),
    );
  }

  void onChangeCallBack(Themes theme) {
    setState(() => _currentTheme = theme);
    AdaptiveThemeMode adaptiveThemeMode;

    switch (theme) {
      case Themes.Light:
        adaptiveThemeMode = AdaptiveThemeMode.light;
        break;
      case Themes.Dark:
        adaptiveThemeMode = AdaptiveThemeMode.dark;
        break;
      case Themes.Default:
        adaptiveThemeMode = AdaptiveThemeMode.system;
        break;
    }

    AdaptiveTheme.of(context).setThemeMode(adaptiveThemeMode);
  }
}
