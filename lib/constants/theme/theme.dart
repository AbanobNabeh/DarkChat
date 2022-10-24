import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

lightthem() => ThemeData(
      dialogBackgroundColor: HexColor('FFFFFF'),
      scaffoldBackgroundColor: HexColor('FAFAFA'),
      appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.changa(
              textStyle: TextStyle(
                  color: HexColor('F4A135'),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: HexColor('FAFAFA'),
          elevation: 0,
          iconTheme: IconThemeData(color: HexColor('F4A135')),
          actionsIconTheme: IconThemeData(color: HexColor('F4A135')),
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: HexColor('FAFAFA'),
          )),
      primaryColor: HexColor('F4A135'),
      buttonColor: HexColor('F4A135'),
      textTheme: TextTheme(
          bodyText1: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 20,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold)),
          bodyText2: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 15,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold)),
          subtitle1: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 15,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold)),
          subtitle2: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 30,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold))),
    );
darktheme() => ThemeData(
      dialogBackgroundColor: HexColor('404040'),
      scaffoldBackgroundColor: HexColor('404040'),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.changa(
            textStyle: TextStyle(
                color: HexColor('F4A135'),
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: HexColor('404040'),
        elevation: 0,
        iconTheme: IconThemeData(color: HexColor('F4A135')),
        actionsIconTheme: IconThemeData(color: HexColor('F4A135')),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: HexColor('404040'),
        ),
      ),
      primaryColor: HexColor('F4A135'),
      buttonColor: HexColor('F4A135'),
      textTheme: TextTheme(
          bodyText1: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 20,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold)),
          bodyText2: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 15,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold)),
          subtitle1: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 15,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold)),
          subtitle2: GoogleFonts.changa(
              textStyle: TextStyle(
                  fontSize: 30,
                  color: HexColor('F4A135'),
                  fontWeight: FontWeight.bold))),
    );
