import 'package:app/constants.dart';
import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: kWhite,
    colorScheme: const ColorScheme.light(),
    appBarTheme: appBarTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBlackBg,
    colorScheme: const ColorScheme.dark(),
    appBarTheme: appBarTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: textTheme(),
    inputDecorationTheme: darkInputDecorationTheme(),
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder focusInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kBlack),
  );
  OutlineInputBorder defaultInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kGreyInputBorder),
  );
  OutlineInputBorder errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.red),
  );
  return InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    enabledBorder: defaultInputBorder,
    focusedBorder: focusInputBorder,
    errorBorder: errorInputBorder,
    border: defaultInputBorder,
    fillColor: Colors.transparent,
    filled: true,
    suffixIconColor: kGreyInputBorder,
    hintStyle: const TextStyle(color: kGreyFormHint),
    labelStyle: const TextStyle(color: kGreyFormLabel),
  );
}

InputDecorationTheme darkInputDecorationTheme() {
  OutlineInputBorder focusInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kBlack),
  );
  OutlineInputBorder defaultInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kGreyDarkInputBorder),
  );
  OutlineInputBorder errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.red),
  );
  return InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    enabledBorder: defaultInputBorder,
    focusedBorder: focusInputBorder,
    errorBorder: errorInputBorder,
    border: defaultInputBorder,
    fillColor: kGreyInputFillDark,
    filled: true,
    suffixIconColor: kGreyDarkInputBorder,
    hintStyle: const TextStyle(color: kGreyFormHint),
    labelStyle: const TextStyle(color: kGreyFormLabel),
  );
}

TextTheme textTheme() {
  return const TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.4,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.4,
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: -0.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    color: Colors.transparent,
  );
}
