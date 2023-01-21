import 'package:flutter/material.dart';
import 'package:new_debts_list/storage.dart';

import 'debts.dart';
import 'onboarding.dart';

MaterialColor mainColor = Colors.indigo;
Color darkestColor = mainColor.shade900;
Color lighterColor = mainColor.shade300;
Color lightestColor = mainColor.shade100;

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(secondary: mainColor, onSecondary: Colors.white),
        primaryColor: mainColor,
        accentColor: mainColor,
        buttonColor: mainColor,
        disabledColor: Colors.grey[500],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: mainColor,
          splashColor: lighterColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(mainColor),
            overlayColor: MaterialStateProperty.all(lightestColor),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(mainColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: mainColor,
          ),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: mainColor,
          selectionColor: lightestColor,
          selectionHandleColor: mainColor,
        ),
        indicatorColor: mainColor,
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(mainColor),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(secondary: mainColor, onSecondary: Colors.white),
        primaryColor: mainColor,
        accentColor: lighterColor,
        buttonColor: lighterColor,
        disabledColor: Colors.grey[700],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: mainColor,
          splashColor: lighterColor,
        ),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(lighterColor),
          overlayColor: MaterialStateProperty.all(mainColor),
        )),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(mainColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: lighterColor,
          ),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: lighterColor)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: lighterColor,
          selectionColor: darkestColor,
          selectionHandleColor: lighterColor,
        ),
        indicatorColor: lighterColor,
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(mainColor),
        ),
      ),
      routes: {
        '/': (_) => ProfilesList(ProfilesStorage()),
        '/onboarding': (_) => OnboardingPages(),
      },
      initialRoute: '/',
    ),
  );
}
