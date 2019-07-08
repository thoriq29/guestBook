import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/utils/sharedPreferences.dart';

PreferenceUtil appData = new PreferenceUtil();

class AddEventPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddEventPageState();
  }
}

class _AddEventPageState extends State<AddEventPage> {

  FocusNode _addressFocus = new FocusNode();
  TextEditingController eventNameController = TextEditingController();
  TextEditingController eventAddressController = TextEditingController();

  String category;
  bool isLoading = false, isLogin;
  int selectedCategory;
  String userId, email, name;
  DateTime _date = new DateTime.now();

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

  Future<DateTime> selectDate (BuildContext context) async{
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          child: child,
          data: Theme.of(context).copyWith(
          accentColor: Colors.deepOrange, //color of circle indicating the selected date
          buttonColor: Colors.deepOrange,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.deepOrange,
            textTheme: ButtonTextTheme.accent //color of the text in the button "OK/CANCEL"
          ), 
        ));
      },
    );
    if(picked != null) {
      if(picked.isBefore(_date) ) {
        _showDialog("Event is less than date now, Please select it again");
      } else {
        setState(() {
          _date = picked;
        });
      }
    }
  } 

  setSelectedCaegory(int val) {
    setState(() {
      selectedCategory = val;
      if (val == 1) {
        category = "Party";
      } else if (val == 2){
        category = "Other";
      } else {
        category = "Wedding";
      }
    });

  }

  Widget eventForm() {
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
                  padding: EdgeInsets.fromLTRB(20, 25, 0, 10),
                  child: Text(
                    "Event Name",
                    style: TextStyle(
                      color: Color(0xffc4c4c4),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Comfortaa',
                    ),
                  ),
                )
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                    child: TextField(
                      textInputAction: TextInputAction.next,
                      controller: eventNameController,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_addressFocus);
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.deepOrange,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1,color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1,color: Colors.black)
                        ),
                      )
                    )
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                    child: Text(
                      "Event Address",
                      style: TextStyle(
                        color: Color(0xffc4c4c4),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  )
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                    child: TextField(
                      focusNode: _addressFocus,
                      controller: eventAddressController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        fillColor: Colors.deepOrange,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1,color: Colors.black)
                        ),
                      )
                    )
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 5, 0, 10),
                    child: Text(
                      "Date",
                      style: TextStyle(
                        color: Color(0xffc4c4c4),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  )
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: GestureDetector(
                    onTap: (){
                      selectDate(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius:  BorderRadius.all(
                            Radius.circular(5.0) 
                        ),
                      ),
                      child: Text(new DateFormat('EEE, dd MMMM y')
                                  .format(_date)
                                  .toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Roboto"
                        ),
                      ),
                    )
                  )
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 3),
                    child: Text(
                      "Category",
                      style: TextStyle(
                        color: Color(0xffc4c4c4),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  )
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              new Radio(
                                value: 0,
                                activeColor: Colors.deepOrange,
                                groupValue: selectedCategory,
                                onChanged: (val) {
                                  setSelectedCaegory(val);
                                },
                              ),
                              new Text(
                                'Wedding',
                                style: new TextStyle(fontSize: 16.0),
                              ),
                              new Radio(
                                value: 1,
                                activeColor: Colors.deepOrange,
                                groupValue: selectedCategory,
                                onChanged: (val) {
                                  setSelectedCaegory(val);
                                },
                              ),
                              new Text(
                                'Party',
                                style: new TextStyle(fontSize: 16.0),
                              ),
                              new Radio(
                                value: 2,
                                activeColor: Colors.deepOrange,
                                groupValue: selectedCategory,
                                onChanged: (val) {
                                  setSelectedCaegory(val);
                                },
                              ),
                              new Text(
                                'Other',
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[

                            ],
                          ),
                        ],
                      )
                  )
              ),
            ],
          )
        ],
      )
    ));
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
            child: Text(isLoading?'Saving...':'Save',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              isLoading?_showDialog("Mohon Tunggu Sebentar"): validation();
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0))),
      ),
    );
  }

  void _showDialog(message) {
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
    if(eventNameController.text.isEmpty) {
      _showDialog("Name is required!");
    } else if (eventAddressController.text.isEmpty) {
      _showDialog("Address is Required!");
    } else if(category == null || category.isEmpty) {
      _showDialog("Category is Required!");
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Confirmation"),
            content: new Text("Are you sure want to create event?"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Cancel", style: TextStyle(color: Colors.grey),),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  "Yes, Create",
                  style: TextStyle(color: Colors.deepOrange),
                ),
                onPressed: () {
                  _createEvent();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _createEvent() async {
    setState(() {
      isLoading = true;
    });

    Firestore.instance.collection("events").add({
      'address': eventAddressController.text.toString(),
      'category': category.toString(),
      'created_at': DateTime.now(),
      'is_active': true,
      'name': eventNameController.text.toString(),
      'owner': userId,
      'start_time': _date
    }).then((result){
      if(this.mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }).catchError((error) => print(error));
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
        title: Text("Create Event",
          style: TextStyle(
            color: Colors.black
          ),
        ),
      ),
      body: eventForm(),
      bottomNavigationBar: BottomAppBar(
        child: _showButton(),
      ),
    );
  }
}