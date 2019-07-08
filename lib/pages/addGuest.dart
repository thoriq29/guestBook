import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddGuestPage extends StatefulWidget{
  AddGuestPage(this.eventId, this.method, this.userId, this.owner);
  final eventId,method, userId, owner;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddGuestPageState();
  }
}

class _AddGuestPageState extends State<AddGuestPage> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controller;
  ByteData _img = ByteData(0);
  var color = Colors.red;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();

  FocusNode _phoneFocus = new FocusNode();
  FocusNode _emailFocus = new FocusNode();
  FocusNode _addressFocus = new FocusNode();
  FocusNode _questionFocus = new FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  

  bool isLoading = false;

  @override 
  void initState() {
    super.initState();
    if(widget.userId != "")  {
      Firestore.instance.collection("users").document(widget.userId).get().then((result){
        if(this.mounted) {
          setState(() {
            nameController.text = result['name'].toString();
            emailController.text = result['email'].toString();
            phoneController.text = result['phone'].toString();
            addressController.text = result['address'].toString();
          });
        }
      }).catchError((onError) {
        Navigator.of(context).pop();
      });
    }
  }

  Widget guestForm() {
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: TextField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_phoneFocus);
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.deepOrange,
                            hintText: "Name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(width: 0.5,color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(width: 1,color: Colors.black)
                            ),
                          ),
                          
                      )
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: TextField(
                        focusNode: _phoneFocus,
                        keyboardType: TextInputType.number,
                        controller: phoneController,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_emailFocus);
                          },
                        decoration: InputDecoration(
                          hintText: "Phone",
                          fillColor: Colors.deepOrange,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(width: 0.5,color: Colors.grey)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(width: 1,color: Colors.black)
                          ),
                        )
                      )
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: TextField(
                          focusNode: _emailFocus,
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_addressFocus);
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                            fillColor: Colors.deepOrange,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(width: 0.5,color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(width: 1,color: Colors.black)
                            ),
                          )
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: new Container(
                    padding: EdgeInsets.all(10),
                    height: 120.0,
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.black),
                        borderRadius: new BorderRadius.all(const Radius.circular(8.0),
                      ),
                    ),
                    child: new TextField(
                        focusNode: _addressFocus,
                        controller: addressController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(_questionFocus);
                        },
                        decoration: InputDecoration(
                          hintText: "Full Address",
                          fillColor: Colors.deepOrange,
                          border: InputBorder.none
                        )
                    )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 10, right: 15),
                  child: new Container(
                    padding: EdgeInsets.all(10),
                    height: 120.0,
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.black),
                        borderRadius: new BorderRadius.all(const Radius.circular(8.0),
                      ),
                    ),
                    child: new TextField(
                        focusNode: _questionFocus,
                        controller: noteController,
                        decoration: InputDecoration(
                          hintText: "Note (Optional)",
                          fillColor: Colors.deepOrange,
                          border: InputBorder.none
                        )
                    )
                  ),
                )
              ],
            )
          ],
        )
      )
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Guest Signature"),
          content: Padding(
            padding: EdgeInsets.only(bottom:  0),
            child: Container(
              width: 330,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Signature(
                  color: color,
                  key: _sign,
                  onSign: () {
                    final sign = _sign.currentState;
                    debugPrint('${sign.points.length} points in the signature');
                  },
                  backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                  strokeWidth: strokeWidth,
                ),
              ),
              color: Colors.black12,
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: (){
                final sign = _sign.currentState;
                sign.clear();
                setState(() {
                  _img = ByteData(0);
                });
                debugPrint("cleared");
              },
              child: new Text(
                "Clear",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            new FlatButton(
              onPressed: (){
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: new Text(
                "Cancel",
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),

            new FlatButton(
              child: new Text(
                "Save",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                final sign = _sign.currentState;
                if(sign.points.length > 0) {
                  createGuest();
                  Navigator.of(context, rootNavigator: true).pop();
                  
                } else {
                  _showDialogMessage("Mohon Tanda tangan dulu ya");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
            elevation: 10.0,
            color: isLoading?Colors.grey[300]:Colors.deepOrange,
            textColor: Colors.white,
            child: Text(isLoading?'Saving...':'Next',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
             isLoading?_showDialogMessage("Mohon Tunggu Sebentar"): validation();
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0))),
      ),
    );
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

  void validation() {
    if(nameController.text.isEmpty) {
      _showDialogMessage("Name is required!");
    } else if (phoneController.text.isEmpty) {
      _showDialogMessage("Handphone is Required!");
    } else if(emailController.text.isEmpty) {
      _showDialogMessage("Email is Required!");
    } else if(addressController.text.isEmpty) {
      _showDialogMessage("Address is Required!");
    } else {
      _showDialog();    
    }
  }

  void createGuest() async {
    QuerySnapshot result = await Firestore.instance.collection("guests")
                          .where("userId", isEqualTo: widget.userId)
                          .where("at_event", isEqualTo: widget.eventId)
                          .getDocuments();
    var doc = result.documents;
    
    if(doc.isEmpty) {
      if(widget.owner != widget.userId) {
        Firestore.instance.collection("guests").add({
          'address': addressController.text.toString(),
          'at_event': widget.eventId.toString(),
          'created_at': DateTime.now(),
          'email': emailController.text.toString(),
          'full_name': nameController.text.toString(),
          'notes': noteController.text.toString()??"",
          'phone': phoneController.text.toString(),
          'userId': widget.userId!=""?widget.userId:"Guest",
          'verified': true,
          'register_method': widget.method.toString()
          
          }).then((result){
            Navigator.of(context).pop();
            _showDialogMessage("Selamat Datang "+ nameController.text.toString());
          }).catchError((error){
            _showDialogMessage(error);
          });
      } else {
        Navigator.of(context).pop();
        _showDialogMessage("You are the owner for this event");
      }
      
    } else {
      Navigator.of(context).pop();
      _showDialogMessage("Guest has been visited at event");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Add Guest"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: (){Navigator.of(context).pop();}),
      ),
      body: guestForm(),
      bottomNavigationBar: BottomAppBar(
        child: _showButton(),
      ),
    );
  }
}


class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
//    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _WatermarkPaint && runtimeType == other.runtimeType && price == other.price && watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

