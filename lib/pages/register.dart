import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  FocusNode emailFocus = new FocusNode();
  FocusNode phoneFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();
  FocusNode confirmFocus = new FocusNode();

  bool isLoading = false;
  Widget buildBody() {
    return ListView(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text("REGISTER",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto"
                ),
            )
          )
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text("  Create a Belle Account by\n completing the form below",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w100,
                fontFamily: "Roboto"
              ),
            )
          )
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(25, 15, 25, 10),
            child: TextField(
              style: new TextStyle(color: Colors.black38),
              controller: nameController,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(emailFocus);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Name",
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
            padding: EdgeInsets.fromLTRB(25, 5, 25, 10),
            child: TextField(
              style: new TextStyle(color: Colors.black38),
              controller: emailController,
              cursorColor: Colors.black38,
              focusNode: emailFocus,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(phoneFocus);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Email",
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
            padding: EdgeInsets.fromLTRB(25, 5, 25, 10),
            child: TextField(
              style: new TextStyle(color: Colors.black38),
              controller: phoneController,
              focusNode: phoneFocus,
              keyboardType: TextInputType.number,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Phone",
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
            padding: EdgeInsets.fromLTRB(25, 5, 25, 10),
            child: TextField(
              style: new TextStyle(color: Colors.black38),
              controller: passwordController,
              focusNode: _passwordFocus,
              cursorColor: Colors.black38,
              obscureText: true,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(confirmFocus);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Password",
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
            padding: EdgeInsets.fromLTRB(25, 5, 25, 10),
            child: TextField(
              style: new TextStyle(color: Colors.black38),
              controller: confirmpasswordController,
              cursorColor: Colors.black38,
              obscureText: true,
              focusNode: confirmFocus,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.black38),   
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38)
                ),
                fillColor: Colors.deepOrange,
                labelText: "Confirm Password",
                labelStyle: TextStyle(
                  color: Colors.black38
                )
              ),
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange),
              borderRadius: BorderRadius.circular(5.0)
            ),
            child: RaisedButton(
              elevation: 0.0,
              color: Colors.white,
              textColor: Colors.white,
              child: Text("REGISTER",
                  style: new TextStyle(fontSize: 20.0, color: Colors.deepOrange)),
              onPressed: () {
                validation();
              },
              
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                )
              ),
          ),
        ),
      ],
    );
  }

  void _showDialogMessage(message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
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

  void validation() {
    var email = emailController.text.toString();
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(nameController.text.toString().length < 5) {
      _showDialogMessage("Name is to short");
    } else if(emailController.text.toString().isEmpty) {
      _showDialogMessage("Please fill your email");
    } else if(!emailValid) {
      _showDialogMessage("Please fill your correct email");
    } else if(phoneController.text.toString().isEmpty) {
      _showDialogMessage("Please fill your phone");
    } else if(passwordController.text.toString().isEmpty) {      
      _showDialogMessage("Please fill your password");
    } else if(passwordController.text.toString() != confirmpasswordController.text.toString()) {
      _showDialogMessage("Password is doesn't match");
    } else {
      register();
    }
  }

  void dialogloading() {
    if(isLoading) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: new Row(
            children: <Widget>[
              SizedBox(
                height: 35,
                width: 35,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text("Loading ...", style: TextStyle(fontSize: 17),),
              )
            ],
          ),
          
        ); 
    });
    } else {
        Navigator.of(context, rootNavigator: true).pop();
    }
  }


  void register() async {
    if(this.mounted) {
      setState(() {
        isLoading = true;
      });
      dialogloading();
    }
    QuerySnapshot result =  await Firestore.instance.collection("users")
          .where("email", isEqualTo: emailController.text.toString())
          .getDocuments();
    var documents = result.documents;
    if(documents.isEmpty) {
      await Firestore.instance.collection("users").add({
        'name': nameController.text.toString(),
        'email': emailController.text.toString(),
        'phone': phoneController.text.toString(),
        'password': passwordController.text.toString(),
        'address': "",
        'created_at': DateTime.now(),
      }).then((result){
        if(this.mounted) {
          setState(() {
            isLoading = false;
          });
        }
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Yay"),
              content: new Text("Register successfully"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    "OK",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }).catchError((onError){
        _showDialogMessage(onError);
      }); 
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      _showDialogMessage("Email has been registered");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildBody(),
    );
  }
}