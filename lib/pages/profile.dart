import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:guestbook/pages/showQR.dart';

PreferenceUtil appData = new PreferenceUtil();

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage>{

  String userId, email, name;
  bool isLogin;

  @override
  void initState() {
    super.initState();
    appData.checkLogin().then((result) {
      if (result) {
        if(this.mounted) {
          setState(() {
            isLogin = result;
          });
          appData.getVariable("name").then((result) {
            setState(() {
              name = result;
            });
          });
          appData.getVariable("email").then((result) {
            setState(() {
              email = result;
            });
          });
          appData.getVariable("userId").then((result) {
            setState(() {
              userId = result;
            });
          });
        }
      } 
    });
  }

  Widget buildBody() {
    return ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 20, ),
                  child: Text(name == null?"Name":name.length > 13? name.toString().substring(0,11)+"...":name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Roboto"
                      ),
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(email??"",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Roboto"
                    ),
                  ),
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ShowQRPage(userId)
                  )
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top:0, right: 20),
                child: Hero(
                  tag: 'qrcode',
                  child: QrImage(
                    data: userId.toString(),
                    size: 90.0,
                  ),
                )
              )
            )
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/editprofile'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, top: 30),
                child: Text("Edit Profile",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto"
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 27, top: 30),
                child: Icon(Icons.arrow_forward, color: Colors.deepOrange),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: new Divider(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/changePassword'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Text("Change Password",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto"
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 27, top: 18),
                child: Icon(Icons.arrow_forward, color: Colors.deepOrange),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: new Divider(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
            context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ShowQRPage(userId)
              )
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Text("Visit an Event",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto"
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 27, top: 18),
                child: Icon(Icons.arrow_forward, color: Colors.deepOrange),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: new Divider(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/visitedEvents');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Text("Share a Moment's",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto"
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 27, top: 18),
                child: Icon(Icons.arrow_forward, color: Colors.deepOrange),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: new Divider(color: Colors.grey),
        ),
        // GestureDetector(
        //   onTap: () {
        //     Navigator.pushNamed(context, '/nearMe');
        //   },
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       Padding(
        //         padding: EdgeInsets.only(left: 20, top: 10),
        //         child: Text("Events near Me",
        //           style: TextStyle(
        //             color: Colors.black45,
        //             fontSize: 18,
        //             fontWeight: FontWeight.w400,
        //             fontFamily: "Roboto"
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: EdgeInsets.only(right: 27, top: 18),
        //         child: Icon(Icons.arrow_forward, color: Colors.deepOrange),
        //       )
        //     ],
        //   ),
        // ),
        // Container(
        //   width: MediaQuery.of(context).size.width,
        //   padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
        //   child: new Divider(color: Colors.grey),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _showDialogLogout();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 10, bottom: 20),
                child: Text("LOGOUT",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto"
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 27, top: 18, bottom: 20),
              child: Text('Version 1.0.0', 
                style: TextStyle(
                  fontSize: 13
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  void _showDialogLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Are you sure want to log out?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "Cancel",
                style: TextStyle(color: Colors.black38),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "YES, LOGOUT",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                appData.logout();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/loginpage');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.deepOrange,
          ),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      body: buildBody(),
    );
  }
}