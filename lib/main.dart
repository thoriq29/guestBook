import 'package:flutter/material.dart';
import 'package:guestbook/pages/events.dart';
import 'package:guestbook/pages/addEvent.dart';
import 'package:guestbook/pages/qrscanner.dart';
import 'package:guestbook/pages/deactived_events.dart';
import 'package:guestbook/pages/login.dart';
import 'package:guestbook/pages/register.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:guestbook/pages/splashScreen.dart';
import 'package:guestbook/pages/profile.dart';
import 'package:guestbook/pages/editProfile.dart';
import 'package:guestbook/pages/changePassword.dart';
import 'package:guestbook/pages/visitedEvents.dart';
import 'package:guestbook/pages/eventNearMe.dart';

PreferenceUtil appData = new PreferenceUtil();

void main() => runApp(GuestBookApp());

class GuestBookApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuestBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.deepOrange,
        primaryColorLight: Colors.grey[350],
        primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
            color: Colors.deepOrange
        ),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.accent),
        primaryTextTheme: TextTheme(
            title: TextStyle(color: Colors.black)
        ),
      ),
      // home: EditorPhotoPage(),
      home: SplashscreenPage(),
        routes: <String, WidgetBuilder> {
          '/home': (BuildContext context) => EventsPage(),
          '/addevent': (BuildContext context) => AddEventPage(),
          '/scanner': (BuildContext context) => ScanScreen(),
          '/deactived_events': (BuildContext context) => DeactivedEventsPage(),
          '/loginpage': (BuildContext context) => LoginPage(),
          '/register': (BuildContext context) => RegisterPage(),
          '/profile': (BuildContext context) => ProfilePage(),
          '/editprofile': (BuildContext context) => EditProfilePage(),
          '/changePassword': (BuildContext context) => ChangePasswordPage(),
          '/visitedEvents': (BuildContext context) => VisitedEventsPage(),
          '/nearMe': (BuildContext context) => EventNearMePage(),
        }
    );
  }
}