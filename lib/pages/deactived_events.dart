import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/pages/eventDetail.dart';

import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:guestbook/models/events.dart';

PreferenceUtil appData = new PreferenceUtil();

class DeactivedEventsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DeactivedEventsPageState();
  }
}

class _DeactivedEventsPageState extends State<DeactivedEventsPage> {

  TextEditingController editingController = TextEditingController();
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String userId, email, name;
  bool isLogin, isSearching=false;
  ScrollController _scrollController;
  double padding = 90.0;
  double b = 50.0;
  bool isNoData = false;

  Events events = Events();
  List<Events> list_of_event = new List<Events>();
  List<Events> duplicate_items = new List<Events>();

  _scrollListener() {
    if (_scrollController.offset >= 10) {
      print(b -=1);
      if(this.mounted) {
        setState(() {
          if(!_scrollController.position.outOfRange) {
//            padding -= 1;
          }
        });
      }
    }
    if (_scrollController.offset <= 5) {
      if(this.mounted) {
        setState(() {
//          padding += 5;
        });
      }
    }
  }


  Future<Null> initConnectivity() async {
    String connectionStatus;

    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = "Internet connectivity failed";
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
    print("InitConnectivity : $_connectionStatus");
    if(_connectionStatus == "ConnectivityResult.mobile" || _connectionStatus == "ConnectivityResult.wifi") {

    } else {
      print("You are not connected to internet");
    }
  }

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
            getEvents();
          });
        }
      } 
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
          String connectionStatus;

          try {
            connectionStatus = (await _connectivity.checkConnectivity()).toString();
          } on PlatformException catch (e) {
            print(e.toString());
            connectionStatus = "Internet connectivity failed";
          }

          if (!mounted) {
            return;
          }

          setState(() {
            _connectionStatus = connectionStatus;
          });
          print("Initstate : $_connectionStatus");

        });


    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
    _connectivitySubscription.cancel();
    _scrollController.removeListener(_scrollListener);
  }

  void getEvents() async {
    QuerySnapshot eventsQuery = await Firestore.instance.collection("events")
        .where('owner', isEqualTo: userId)
        .where('is_active', isEqualTo: false)
        .getDocuments();
    var documents = eventsQuery.documents;
    for(var doc in documents) {
      setState(() {
        events = Events.fromData(doc.data, doc.documentID);
        duplicate_items.clear();
        duplicate_items.add(events);
      });
    }
    list_of_event.clear();
    list_of_event.addAll(duplicate_items);
  }

  void filterSearchResults(String query) {
    
      List<Events> dummySearchList = new List<Events>();
      dummySearchList.addAll(duplicate_items);
      if(query.isNotEmpty) {
        List<Events> dummyListData = List<Events>();
        dummySearchList.forEach((item) {
          if(item.name.toString().toLowerCase().contains(query.toLowerCase())) {
            dummyListData.add(item);
          }
        });
        setState(() {
          isSearching = true;
          list_of_event.clear();
          list_of_event.addAll(dummyListData);
        });
        return;
      } else {
        setState(() {
          isSearching = false;
          list_of_event.addAll(duplicate_items);
        });
      }
  }

  Widget getDataToList() {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: padding, left: 10, right: 10),
      child: Container(
        width: screenSize.width,
        child: Stack(
          children: <Widget>[

            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: GridView.builder(
                controller: _scrollController,
                itemCount: list_of_event.length,
                gridDelegate:
                new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait?2:3,
                  childAspectRatio:MediaQuery.of(context).orientation == Orientation.portrait?0.70:0.90 ,
                ),
                itemBuilder: (context, index) =>
                    buildItemToList(index, list_of_event[index]),
              ),
            ),
          ],
        )
      ),
    );
  }
  Widget buildItemToList(int index, Events event) {
    String image = "assets/images/party.jpg";
    String category = "Party";
    if(event.category== "Wedding") {
      image = "assets/images/wedding_decoration.jpg";
      category = "Wedding";
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
        context,
          MaterialPageRoute(
              builder: (BuildContext context) => EventDetailPage(
                event.id, image, event.name, event.name, true, event.owner
              )
          )
        );
      },
      child: Container(
        height: 200,
//        width: 180,
        padding: EdgeInsets.only(top: 0.0, left: 0, right: 0),
        child: Card(
          semanticContainer: false,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              Hero(
                tag: event.id,
                child: Image.asset(
                    image,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.srcOver,
                    color: new Color.fromARGB(120, 20, 10, 40)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(category.toUpperCase(),
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white70,
                      fontSize: 16
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 45, left: 20),
                child: Text(event.name.toString().length > 27? event.name.toString().substring(0,24)+"...":event.name,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 130, left: 30),
                child: Text(event.address,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white,
                      fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
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

  Widget buildItem(int index, DocumentSnapshot document) {
    String image = "assets/images/party.jpg";
    String category = "Party";
    if(document['category'] == "Wedding") {
      image = "assets/images/wedding_decoration.jpg";
      category = "Wedding";
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
        context,
          MaterialPageRoute(
              builder: (BuildContext context) => EventDetailPage(
                document.documentID, image, document['name'], document['category'], false, document['owner']
              )
          )
        );
      },
      child: Container(
        height: 200,
//        width: 180,
        padding: EdgeInsets.only(top: 0.0, left: 0, right: 0),
        child: Card(
          semanticContainer: false,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              Hero(
                tag: document.documentID,
                child: Image.asset(
                    image,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.srcOver,
                    color: new Color.fromARGB(120, 20, 10, 40)
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(category.toUpperCase(),
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white70,
                      fontSize: 16
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 45, left: 20),
                child: Text(document['name'].toString().length > 27? document['name'].toString().substring(0,24)+"...":document['name'],
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 130, left: 30),
                child: Text(document['address'],
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white,
                      fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget _buildPage() {
    return Stack(
        children: <Widget>[
          _buildContent(),
          Positioned(    // To take AppBar Size only
            top: MediaQuery.of(context).orientation == Orientation.portrait?25.0:0,
            left: 20.0,
            right: 20.0,
            child: AppBar(
              backgroundColor: Colors.white,
              leading: Icon(Icons.event_note, color: Colors.deepOrange,),
              primary: false,
              elevation: 10.0,
              title: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                enabled: isNoData?false:true,
                controller: editingController,
                decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey))),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search, color: Colors.deepOrange), onPressed: () {
                  },
                ),
              ],
            ),
          ),
          isSearching?getDataToList():getData()
        ],
      );
  }


  Widget _buildContent() {
    return CustomPaint(
        child: Container(
          height: 250.0,
        ),
        painter: CurvePainter(),
    );
  }

  Widget _buildGridView(document) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: padding, left: 10, right: 10),
      child: Container(
        width: screenSize.width,
        child: Stack(
          children: <Widget>[

            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: GridView.builder(
                controller: _scrollController,
                itemCount: document.length,
                gridDelegate:
                new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait?2:3,
                  childAspectRatio:MediaQuery.of(context).orientation == Orientation.portrait?0.70:0.90 ,
                ),
                itemBuilder: (context, index) =>
                    buildItem(index, document[index]),
              ),
            ),
          ],
        )
      ),
    );
  }
  Widget _buildListview(document) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).orientation == Orientation.portrait?0:0),
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.portrait?260:280,
        padding: EdgeInsets.only(top: 10.0),
        width: screenSize.width,
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.right,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: document.length,
              itemBuilder: (context, index) =>
                  buildItem(index, document[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget getData() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("events")
          .where('owner', isEqualTo: userId)
          .where('is_active', isEqualTo: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots)   {
        if(_connectionStatus == "ConnectivityResult.none" && snapshots.data.documents.length == 0) {
          return MediaQuery.of(context).orientation==Orientation.portrait? Padding(
            padding: EdgeInsets.only(top: 200),
            child: Container(
                height: 300,
                width: 550,
                padding: EdgeInsets.only(top: 0),
                child:  Stack(
                  children: <Widget>[
                    Center(
                      child: FlareActor("assets/animation/no_internet.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        animation: "Untitled",
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Text("No Internet Connection"),)
                    ),
                  ],
                )
            ),
          ):Container();
        }else if(!snapshots.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green)));


        }else{
          if(snapshots.hasData && (snapshots.data.documents.length == 0)) {
            if(this.mounted) {
              Timer(Duration(microseconds: 3), () {
                setState(() {
                  isNoData = true;
                });
                list_of_event.clear();
              });
            }
            return MediaQuery.of(context).orientation == Orientation.portrait? Padding(
              padding: EdgeInsets.only(top: 200),
              child: Container(
                  height: 300,
                  width: 550,
                  padding: EdgeInsets.only(top: 0),
                  child:  Stack(
                    children: <Widget>[
                      Center(
                        child: Image.asset('assets/images/event-icon.png',
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text("No event data"),)
                      ),
                    ],
                  )
              ),
            ):Container();
          } else {
            if(this.mounted) {
              Timer(Duration(microseconds: 3), () {
                setState(() {
                  isNoData = false;
                  // list_of_event.clear();
                  getEvents();
                });
              });
            }
            return _buildGridView(snapshots.data.documents);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          // color: Colors.black,
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        elevation: 0.0,
        title: Text("My Finished Events",
            style: TextStyle(
              fontFamily: "Roboto",
              color: Colors.white
            )
        ),
      ),
      body: _buildPage(),
    );
  }
}


class CurvePainter extends CustomPainter{


  Color colorOne = Colors.deepOrange;
  Color colorTwo = Colors.deepOrange[300];
  Color colorThree = Colors.deepOrange[100];

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();


    path.lineTo(0, size.height *0.75);
    path.quadraticBezierTo(size.width* 0.10, size.height*0.70,   size.width*0.17, size.height*0.90);
    path.quadraticBezierTo(size.width*0.20, size.height, size.width*0.25, size.height*0.90);
    path.quadraticBezierTo(size.width*0.40, size.height*0.40, size.width*0.50, size.height*0.70);
    path.quadraticBezierTo(size.width*0.60, size.height*0.85, size.width*0.65, size.height*0.65);
    path.quadraticBezierTo(size.width*0.70, size.height*0.90, size.width, 0);
    path.close();

    paint.color = colorThree;
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, size.height*0.50);
    path.quadraticBezierTo(size.width*0.10, size.height*0.80, size.width*0.15, size.height*0.60);
    path.quadraticBezierTo(size.width*0.20, size.height*0.45, size.width*0.27, size.height*0.60);
    path.quadraticBezierTo(size.width*0.45, size.height, size.width*0.50, size.height*0.80);
    path.quadraticBezierTo(size.width*0.55, size.height*0.45, size.width*0.75, size.height*0.75);
    path.quadraticBezierTo(size.width*0.85, size.height*0.93, size.width, size.height*0.60);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = colorTwo;
    canvas.drawPath(path, paint);

    path =Path();
    path.lineTo(0, size.height*0.75);
    path.quadraticBezierTo(size.width*0.10, size.height*0.55, size.width*0.22, size.height*0.70);
    path.quadraticBezierTo(size.width*0.30, size.height*0.90, size.width*0.40, size.height*0.75);
    path.quadraticBezierTo(size.width*0.52, size.height*0.50, size.width*0.65, size.height*0.70);
    path.quadraticBezierTo(size.width*0.75, size.height*0.85, size.width, size.height*0.60);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = colorOne;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

}