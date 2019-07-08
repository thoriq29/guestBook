import 'package:flutter/material.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

PreferenceUtil appData = new PreferenceUtil();
class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EditProfilePageState();
  }
}

class _EditProfilePageState extends State<EditProfilePage> {

  FocusNode _phoneFocus = new FocusNode();
  FocusNode _addressFocus = new FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String userId, phone, name, email, address;
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
              nameController.text= result??"";
            });
          });
          appData.getVariable("phone").then((result) {
            setState(() {
              phone = result;
              phoneController.text = result??"";
            });
          });
          appData.getVariable("userId").then((result) {
            setState(() {
              userId = result;
            });
          });
          appData.getVariable("email").then((result) {
            setState(() {
              email = result;
            });
          });
          appData.getVariable("address").then((result) {
            setState(() {
              address = result;
              addressController.text  = result;
            });
          });
        }
      } 
    });
  }

  void validate() {
    if(nameController.text.length < 5) {
      _showDialogMessage("Name is to short");
    } else if(phoneController.text.toString().isEmpty) {
      _showDialogMessage('Please fill your phone');
    } else if(addressController.text.toString().isEmpty) {
        _showDialogMessage('Please fill your address');
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
    if(nameController.text == name && phoneController.text == phone && addressController.text == address) {
      Navigator.of(context).pop();
    } else {
      Firestore.instance.collection("users")
      .document(userId)
      .updateData({
        'name': nameController.text.toString(),
        'phone': phoneController.text.toString(),
        'address': addressController.text.toString(),
        'updated_at': DateTime.now()
      }).then((result){
        appData.saveVariable("name", nameController.text.toString());
        appData.saveVariable("address", addressController.text.toString());
        appData.saveVariable("phone", phoneController.text.toString());
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Confirmation"),
              content: new Text("Your profile has been updated"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    "OK",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            );
          },
        );
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
              style: new TextStyle(color: Colors.black),
              controller: nameController,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_phoneFocus);
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
            padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
            child: TextField(
              style: new TextStyle(color: Colors.black),
              controller: phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.number,
              cursorColor: Colors.black38,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_addressFocus);
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
            padding: EdgeInsets.fromLTRB(20, 5, 0, 10),
            child: TextField(
              focusNode: _addressFocus,
              style: new TextStyle(color: Colors.black),
              controller: addressController,
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
                labelText: "Address",
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
        title: Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w100),),
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