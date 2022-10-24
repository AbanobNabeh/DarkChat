import 'dart:async';

import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/view/screen/auth/phonenumber.dart';
import 'package:darkchat/view/screen/homepage.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      if (id == null) {
        navof(context: context, screen: PhoneNumberScreen());
      } else {
        navof(context: context, screen: HomePage());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xfff4a135),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0, -1.0),
                end: Alignment(1.0, 1.026),
                colors: [const Color(0xfff4a135), const Color(0xfff15223)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
          Center(
              child: Image(
            image: AssetImage('asset/image/logo.png'),
            width: 180,
          ))
        ],
      ),
    );
  }
}
