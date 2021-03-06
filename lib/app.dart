import 'package:covid19india/preferences.dart';
import 'package:covid19india/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/subjects.dart' show BehaviorSubject;
import 'package:covid19india/pages/home.dart';

/// The starting point of the widget tree
/// Here the root dependecies such as repositories or bloc providers are provided
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppTheme();
  }
}

/// AppBody is where all widgets that display on the screen starts
/// This can be considered as a starting point of actual front-end interface
/// AppBody always inherits from the AppTheme it's not a standalone widget
class AppBody extends StatelessWidget {
  final ThemeMode mode;
  const AppBody({Key key, this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Repository>(
      create: (_) => Repository(),
      child: ChangeNotifierProvider<Preferences>(
        create: (_) => Preferences(),
        child: MaterialApp(
          themeMode: mode,
          theme: mode == ThemeMode.light
              ? ThemeData.light().copyWith(
                  textTheme: GoogleFonts.robotoTextTheme(
                  ThemeData.light().textTheme,
                ))
              : ThemeData.dark().copyWith(
                  textTheme: GoogleFonts.robotoTextTheme(
                  ThemeData.dark().textTheme,
                )),
          routes: {"/": (context) => HomePage()},
        ),
      ),
    );
  }
}

/// AppTheme widgets keeps the track of current theme of the entire material app
/// AppTheme widget responds the change in current ThemeMode and returns the AppBody with the current ThemeMode
class AppTheme extends StatefulWidget {
  final BehaviorSubject<ThemeMode> _controller =
      BehaviorSubject.seeded(ThemeMode.light);
  AppTheme({Key key}) : super(key: key);

  ThemeMode get activeThemeMode => _controller.value;

  @override
  _AppThemeState createState() => _AppThemeState();

  void terminate() => _controller.close();

  void toggle() {
    if (activeThemeMode == ThemeMode.light) {
      _controller.add(ThemeMode.dark);
    } else {
      _controller.add(ThemeMode.light);
    }
  }

  /// Get the current active theme mode
  static ThemeMode mode(BuildContext context) =>
      context.findAncestorWidgetOfExactType<AppTheme>().activeThemeMode;

  static bool isDark(BuildContext context) =>
      context.findAncestorWidgetOfExactType<AppTheme>().activeThemeMode ==
      ThemeMode.dark;

  static toggleTheme(BuildContext context) {
    context.findAncestorWidgetOfExactType<AppTheme>().toggle();
  }
}

class _AppThemeState extends State<AppTheme> {
  @override
  void dispose() {
    super.dispose();
    widget.terminate();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget._controller.stream,
      initialData: widget._controller.value,
      builder: (context, snap) => AppBody(
        mode: snap.data,
      ),
    );
  }
}
