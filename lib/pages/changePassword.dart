import 'package:flutter/material.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

PreferenceUtil appData = new PreferenceUtil();
class ChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChangePasswordPageState();
  }
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  FocusNode _newPasswordFocus = new FocusNode();
  FocusNode _confirmFocus = new FocusNode();
  String userId, phone, name, password, address;
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
          appData.getVariable("phone").then((result) {
            setState(() {
              phone = result;
            });
          });
          appData.getVariable("userId").then((result) {
            setState(() {
              userId = result;
            });
          });
          appData.getVariable("password").then((result) {
            setState(() {
              password = result;
            });
          });
          appData.getVariable("address").then((result) {
            setState(() {
              address = result;
            });
          });
        }
      } 
    });
  }

  void validate() {
    String old = oldPasswordController.text.toString();
    String newpass = newPasswordController.text.toString();
    String confirm = confirmPasswordController.text.toString();

    if(old.isEmpty) {
      _showDialogMessage("Please input old Password");
    } else if(newpass.isEmpty) {
      _showDialogMessage("Please input new Password");
    } else if(newpass != confirm) {
      _showDialogMessage("The Passwords you entered do not match");
    } else {
      update();
    }
  }

  void _showDialogMessage(message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Confirmation"),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void update() async {
    DocumentSnapshot result = await Firestore.instance.collection("users").document(userId).get();
    if(result.data.isNotEmpty && result.data['password'] != oldPasswordController.text.toString()) {
      _showDialogMessage("Your old password was entered incorrectly. Please enter it again");
    } else if(result.data['password'] == newPasswordController.text.toString()) {
      _showDialogMessage("Your new password was entered same with old password");
    } else {
      Firestore.instance.collection("users")
      .document(userId)
      .updateData({
        'password': newPasswordController.text.toString(),
        'updated_at': DateTime.now()
      }).then((result){
        appData.saveVariable("password", newPasswordController.text.toString());
        Navigator.of(context).pop();
        _showDialogMessage("Your password has been updated");
      }).catchError((e) {
        _showDialogMessage(e.toString());
      });
    }
  }

  Widget buildBody() {
    return ListView(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
            child: TextField(
              obscureText: true,
              style: new TextStyle(color: Colors.black),
              controller: oldPasswordController,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_newPasswordFocus);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Old Password",
                labelStyle: TextStyle(
                  color: Colors.black38
                )
              ),
            )
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
            child: TextField(
              obscureText: true,
              focusNode: _newPasswordFocus,
              style: new TextStyle(color: Colors.black),
              controller: newPasswordController,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_confirmFocus);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "New Password",
                labelStyle: TextStyle(
                  color: Colors.black38
                )
              ),
            )
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 0, 10),
            child: TextField(
              obscureText: true,
              focusNode: _confirmFocus,
              style: new TextStyle(color: Colors.black),
              controller: confirmPasswordController,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                update();
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Confirm New Password",
                labelStyle: TextStyle(
                  color: Colors.black38
                )
              ),
            )
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password", style: TextStyle(fontWeight: FontWeight.w100),),
        actions: <Widget>[
          IconButton(
            onPressed: (){validate();},
            icon: Icon(Icons.check, color: Colors.deepOrange)
          )
        ],
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
      ),
      body: buildBody(),
    );
  }
}