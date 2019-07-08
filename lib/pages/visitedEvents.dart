import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/pages/imageEditor.dart';
import 'package:guestbook/utils/sharedPreferences.dart';
import 'package:guestbook/models/events.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';

PreferenceUtil appData = new PreferenceUtil();

class VisitedEventsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VisitedEventsPageState();
  }
}

class _VisitedEventsPageState extends State<VisitedEventsPage> {

  String userId, email, name;
  bool isLogin;
  Events events = Events();
  List<Events> list_of_event = new List<Events>();
  String fileName;
  String caption = "";
  List<Filter> filters = presetFiltersList;
  File imageFile;
  bool isLoading = false, isDone = false, titleDiisi = false;
  double progress;

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
            getEventIds();
          });
        }
      } 
    });
  }

  void getEventIds() async {
    QuerySnapshot result = await Firestore.instance
                  .collection("guests")
                  .where("userId", isEqualTo: userId)
                  .getDocuments();
    var documents = result.documents;
    List<String> eventIds = List<String>();
    for(var doc in documents) {
      eventIds.add(doc["at_event"]);
    }
    
    for(var eventId in eventIds) {
      DocumentSnapshot eventsQuery = await Firestore.instance
                        .collection("events")
                        .document(eventId).get();
      setState(() {
        events = Events.fromData(eventsQuery.data, eventsQuery.documentID);
        list_of_event.add(events);
      });
    }
  }


  Future getImage(context, eventId) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.askUser);
    fileName = path.basename(imageFile.path);
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
     Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
              title: Text("Photo Filter"),
              image: image,
              filters: presetFiltersList,
              filename: fileName,
              loader: Center(child: CircularProgressIndicator()),
              fit: BoxFit.contain,
            ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
        caption = imagefile['caption'];
        fileName = path.basename(imageFile.path);
        uploadImageToStorage(context, imageFile, eventId);
      });
      print("bbb $caption");
      print("aaaa ${imageFile.path}");
    }
  }

  Future<String> uploadImageToStorage(BuildContext context, image, eventId) async {
    StorageReference ref =
    FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = ref.putFile(image);

    uploadTask.events.listen((event) {
      setState(() {
        isLoading = true;
        progress = event.snapshot.bytesTransferred.toDouble();
      });
    }).onError((error) {
      print(error.toString());
    });
    uploadTask.onComplete.then((snapshot) {
      setState(() {
        isLoading = false;
        isDone = true;
        titleDiisi = false;
      });
      _showDialogMessage("Moment has been uploaded, Thank You 😊");
      // Navigator.of(context).pushReplacementNamed('/galeri_regu');
    });

    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();

    print("Download URL : $url");

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(Firestore.instance.collection("gallery").document(), {
        'foto': url,
        'userId': userId,
        'at_event': eventId,
        'caption': caption,
        'tanggal_upload': Timestamp.now()
      });
    });
    return url;
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
        getImage(context, events.id);
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Select your visited Event'),
        leading: IconButton(
          onPressed: ()=> Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.deepOrange),
        ),
      ),
      body: list_of_event.length != 0? GridView.builder(
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
              child: Text("Loading..."),
              // child: Text("You have never visited events"),
            ),
            // Center(
            //   child: Text("Please go back and visit some event now"),
            // ),
          ],
        )
      )
    );
  }
}
