import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:flare_flutter/flare_actor.dart';

PreferenceUtil appData = new PreferenceUtil();

class SplashscreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SplashscreenPageState();
  }
}

class SplashscreenPageState extends State<SplashscreenPage> {

  @override
  void initState() {
    super.initState();
    appData.checkLogin().then((result) {
      if (result) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Timer(Duration(seconds: 3), () {
          Navigator.of(context).pushReplacementNamed('/loginpage');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Container(
        child:Hero(
          tag: "icon_splash",
          child: Center(
            child: Icon(Icons.verified_user, color: Colors.white, size:50,),
          ),
        )
      ),
    );
  }
}