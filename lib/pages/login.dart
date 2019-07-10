import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/utils/sharedPreferences.dart';

PreferenceUtil appData = new PreferenceUtil();

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode _passwordFocus = new FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _saveDataToSharedprefs(data) {
    appData.saveBoolVariable("login", true);
    appData.saveVariable("userId", data.documentID);
    appData.saveVariable("name", data['name']);
    appData.saveVariable("email", data['email']);
    appData.saveVariable("phone", data['phone']);
    appData.saveVariable("address", data['address']);
    appData.saveVariable("password", data['password']);
    appData.saveVariable("image", data['image']);
    Navigator.pushReplacementNamed(context, '/home');
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

  void valdateAndSubmit() async {
    String email = emailController.text.toString();
    String password = passwordController.text.toString();
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(email.isEmpty) {
      _showDialogMessage("Please input a valid email address");
    } else if(!emailValid) {
      _showDialogMessage("Please input a valid email format");
    }
    else if(password.isEmpty) {
      _showDialogMessage("Please fill in your password");
    } else {
      if(this.mounted) {
        setState(() {
          isLoading = true;
        });
        dialogloading();
      }
      QuerySnapshot user = await Firestore.instance.collection("users")
                            .where("email", isEqualTo: email)
                            .getDocuments();
      var documents = user.documents;
      if(documents.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
        _showDialogMessage("Login failed. Check your email and make sure you have a good internet connections then Try Again");
      } else {
        if(this.mounted) {
          setState(() {
            isLoading = false;
          });
        }
        //user ada
        for (var doc in documents) {
          password = doc['password'];
          if (password !=null && password == passwordController.text) {
            Navigator.of(context, rootNavigator: true).pop();
            _saveDataToSharedprefs(doc);
            
          }else {
            Navigator.of(context, rootNavigator: true).pop();
            _showDialogMessage("Please enter a correct password");
          }
        }
        
      }
    }
  }
  void dialogloading() {
    
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Processing"),
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
    
  }

  Widget buildPage() {
    return ListView(
      children: <Widget>[
        Hero(
          tag: 'icon_splash',
          child: Align(
          alignment: Alignment.center,
          child: Padding(
              padding: EdgeInsets.only(top: 70),
              child: Icon(Icons.verified_user, color: Colors.white, size:70,),
            )
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("JOIN BELLE",
                style: TextStyle(
                  color: Colors.white,
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
            padding: EdgeInsets.only(top: 20),
            child: Text("Join Belle And Enjoy Your Digital \n     GuestBook And SignIn App",
                style: TextStyle(
                  color: Colors.white,
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
                  style: new TextStyle(color: Colors.white),
                  controller: emailController,
                  cursorColor: Colors.white,
                  
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Colors.white),   
                    ),
                    fillColor: Colors.deepOrange,
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.white
                    )
                  ),
              )
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(25, 15, 25, 10),
              child: TextField(
                  style: new TextStyle(color: Colors.white),
                  controller: passwordController,
                  focusNode: _passwordFocus,
                  cursorColor: Colors.white,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Colors.white),   
                    ),
                    fillColor: Colors.deepOrange,
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Colors.white
                    )
                  ),
              )
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Container(
            height: 45,
            width: MediaQuery.of(context).size.width,
            child: RaisedButton(
                elevation: 3.0,
                color: Colors.deepOrangeAccent,
                textColor: Colors.white,
                child: Text("LOGIN",
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () {
                  valdateAndSubmit();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0))),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: (){Navigator.pushNamed(context, '/register');},
            child: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child:Text("Register a new account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                    fontFamily: "Roboto"
                    ),
                  ),
            ),
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: buildPage(),
    );
  }
}