import 'package:flutter/material.dart';
import 'package:twitter_clone_app/themes/dark_mode.dart';
import 'package:twitter_clone_app/themes/light_mode.dart';

/*

THEME PROVIDER

This helps us change the app from dark & light mode.

themeData function is in a form of setter and getter function. How to set with
themeData function is not like regular function ( e.g. themeData(darkMode) ).
Instead you assign it like a variable ( e.g. themeData = darkMode ).

*/

class ThemeProvider with ChangeNotifier {
  // initially, set it as light mode
  ThemeData _themeData = lightMode;

  // get the current theme
  ThemeData get themeData => _themeData;

  // is it dark mode currently?
  bool get isDarkMode => _themeData == darkMode;

  // set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    // update ui
    notifyListeners();
  }

  // toggle between dark & light mode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
