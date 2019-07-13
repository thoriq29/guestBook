import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:guestbook/models/events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/pages/eventMaps.dart';


class EventNearMePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventNearMePageState();
  }
}

class _EventNearMePageState extends State<EventNearMePage> {

  Events events = Events();
  List<Events> list_of_event = new List<Events>();
  List<Events> duplicate_items = new List<Events>();
  String text = "Loading...";
  @override
  void initState() {
    super.initState();
    getEvents();
    Timer(Duration(seconds: 5), () {
        setState(() {
          text = "No event has opened the booth";
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
    c(lat1 * p) * c(lat2 * p) *
    (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a) * 1000);
  }

  void getEvents() async {
    QuerySnapshot eventsQuery = await Firestore.instance.collection("events")
        .where('is_active', isEqualTo: true)
        .where('open_now', isEqualTo: true)
        .getDocuments();
    var documents = eventsQuery.documents;
    for(var doc in documents) {
      if(doc['lat'] != "0.0") {
        double totalDistance = calculateDistance(-6.944876, 107.629545,double.parse(doc['lat']), double.parse(doc['lng']));
        if(int.parse(totalDistance.toString().substring(0,totalDistance.toString().indexOf('.'))) < 500 ) {
          if(this.mounted) {
            setState(() {
              events = Events.fromData(doc.data, doc.documentID);
              duplicate_items.clear();
              duplicate_items.add(events);
            });
          }
        }
      }
      
      
    }
    list_of_event.clear();
    list_of_event.addAll(duplicate_items);
  }

  Widget buildItem(int index, Events events) {
    String image = "assets/images/party.jpg";
    String category = "Party";
    if(events.category == "Wedding") {
      image = "assets/images/wedding_decoration.jpg";
      category = "Wedding";
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
        context,
          MaterialPageRoute(
              builder: (BuildContext context) => EventLocationPage(events.lat, events.lng, events.name)
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
              Image.asset(
                image,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.srcOver,
                color: new Color.fromARGB(120, 20, 10, 40),
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
                child: Text(events.name.toString().length > 27? events.name.toString().substring(0,24)+"...":events.name,
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
                child: Text(events.address,
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Event Near Me"),
        leading: IconButton(
          onPressed: ()=> Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.deepOrange),
        ),
      ),
      body:  list_of_event.length != 0? GridView.builder(
        itemCount: list_of_event.length,
        gridDelegate:
        new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait?2:3,
          childAspectRatio:MediaQuery.of(context).orientation == Orientation.portrait?0.70:0.90 ,
        ),
        itemBuilder: (context, index) =>
            buildItem(index, list_of_event[index]),
      ):Padding(
        padding: EdgeInsets.only(top: 220),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(text),
              // child: Text("You have never visited events"),
            ),
            // Center(
            //   child: Text("Please go back and visit some event now"),
            // ),
          ],
        )
      ),
    );
  }
}