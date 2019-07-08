import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:guestbook/pages/addGuest.dart';
import 'package:guestbook/pages/readCsvPage.dart';
import 'package:guestbook/models/guests.dart';


class EventDetailPage extends StatefulWidget {
  EventDetailPage(this.eventId, this.assets, this.name, this.category, this.is_active,this.owner);
  final eventId, assets, name, category, is_active, owner;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventDetailPageState();
  }
}

class _EventDetailPageState extends State<EventDetailPage> {


  ScrollController _scrollController;
  bool lastStatus = true;
  int total = 0;
  var color = Colors.white;
  String _localPath;
  String barcode = "";

  _scrollListener() {
    if (_scrollController.offset >= 180) {
      if(this.mounted) {
        setState(() {
          color = Colors.black;
        });
      }
    }
    if (_scrollController.offset <= 180) {
      if(this.mounted) {
        setState(() {
          color = Colors.white;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    makeDownloadDirectory();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  Future _scanQR() async {
    bool success = false;
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this.barcode = barcode;
        success = true;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
    if(barcode != "" && success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddGuestPage(widget.eventId, "Barcode", barcode, widget.owner)),
      );
    }
    
  }

  void makeDownloadDirectory() async {
    await prepareDownloadDirectory();
    bool checkDirectory = await Directory(_localPath).exists();
    if (checkDirectory != true) {
      Directory(_localPath).create(recursive: true);
    }
  }

  Future prepareDownloadDirectory() async {
    _localPath = (await _findLocalPath()) + '/Download/GuestBookApp';
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Widget _buildImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Hero(
          tag: widget.eventId,
          child: Image.asset(
            widget.assets,
            fit: BoxFit.cover,
            height: 236.0,
            colorBlendMode: BlendMode.srcOver,
            color: new Color.fromARGB(120, 20, 10, 40),
          )
      ),
    );
  }

  Widget _buildTopHeader() {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
      child: new Row(
        children: <Widget>[
          new Icon(Icons.arrow_back_ios, size: 25.0, color: Colors.white),
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: new Text(
                  widget.category,
                style: TextStyle(
                    fontFamily: "Roboto",
                    color: Colors.white70,
                    fontSize: 20
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<DocumentSnapshot> getTotalGuests() async {
    total = 0;
    QuerySnapshot result = await Firestore.instance
        .collection("guests")
        .where('at_event', isEqualTo:widget.eventId)
        .getDocuments();
    var documents = result.documents;
    if(documents.isNotEmpty){
      setState(() {
        total = documents.length;
      });
    }else {
      setState(() {
        total = 0;
      });
    }
    return null;
  }

  Widget _showButton() {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Container(
            height: 45,
            width: 150,
            child: RaisedButton(
              elevation: 10.0,
              color: Colors.deepOrange,
              textColor: Colors.white,
              child: Text('Save',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: () {

              },
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)
              )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: Container(
            height: 45,
            width: 150,
            child: RaisedButton(
                elevation: 10.0,
                color: Colors.deepOrange,
                textColor: Colors.white,

                child: Text('Save',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () {

                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)
                )
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGuestList() {
    return Padding(
      padding: EdgeInsets.only(top:0.0),
      child: StreamBuilder(
        stream: Firestore.instance
            .collection("guests")
            .where('at_event', isEqualTo: widget.eventId)
            .snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData){
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green)));
          }else{
            getTotalGuests();
            return ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshots.data.documents.length,
                  itemBuilder: (context, index) =>
                      _buildItem(index, snapshots.data.documents[index]),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildItem(int index, DocumentSnapshot document) {
    return Stack(
        children: <Widget>[
          SizedBox(width: 1.0),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: GestureDetector(
              onTap: (){
                
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                width: MediaQuery.of(context).size.width,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Material(
                    color: Colors.white,
                    shadowColor: Color(0x802196F3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                            width: 90.0,
                            height: 90.0,
                            child: new Padding(
                              padding: const EdgeInsets.fromLTRB(15,0,5,0),
                              child: Container(
//                            padding: EdgeInsets.only(left: 10),
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: new Border.all(
                                        color: Colors.grey[300],
                                        width: 2,
                                      ),
                                      image: new DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: new NetworkImage(
                                              document['image']??"http://diazworld.com/images/avatar-placeholder.png")
                                      )
                                  )
                              ),
                            )
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 0),
                          width: MediaQuery.of(context).size.width,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              document['full_name'],
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 18.0,
                                                fontFamily: 'Comfortaa',
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          document['address'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Comfortaa',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2.0,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 17.0,
                                        width: 50.0,
                                        child: Text(
                                          new DateFormat('H:mm')
                                              .format(document['created_at'])
                                              .toString(),
                                            style: TextStyle(
                                              color: Color(0xffc4c4c4),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                            )
                                        )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(0),
                                        child: Text("-",
                                          style: TextStyle(
                                            color: Color(0xffc4c4c4),
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          )
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                            new DateFormat('d MMMM y')
                                                .format(document['created_at'])
                                                .toString(),
                                            style: TextStyle(
                                              color: Color(0xffc4c4c4),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                            )
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
//          Positioned(
//              right: 18,
//              top: 5,
//              child:Row(
//                children: <Widget>[
//                  IconButton(
//                    icon: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
//                    highlightColor: Colors.white,
//                    splashColor: Colors.white,
//                    onPressed: (){},
//                  ),
//                ],
//              )
//          ),
        ]
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
  Future<void> _generateCSV(context) async {
    var query = await Firestore.instance.collection("guests")
                .where('at_event', isEqualTo: widget.eventId)
                .getDocuments();
    var  guests = query.documents;
    Guests guest = Guests();
    List<Guests> list_of_guest = new List<Guests>();
    if(guests.length > 0) {
      for(var doc in guests) {
        guest = Guests.fromData(doc.data);
        list_of_guest.add(guest);
      }  
    }
    if(list_of_guest.length != 0) {
      List<List<String>> csvData = [
      // headers
      <String>['Name', 'Phone', 'Email', 'Address'],
      ...list_of_guest.map((item) => [
        item.name, item.phone.toString(), item.email.toString(), 
        item.address.toString()??""
      ])
      
      ];
      String csv = const ListToCsvConverter().convert(csvData);

      final String path = '$_localPath/guestbook_' +widget.name.toString() +'.csv';

      // create file
      final File file = File(path);
      // Save csv string using default configuration
      // , as field separator
      // " as text delimiter and
      // \r\n as eol.
      await file.writeAsString(csv).then((result){
        showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Information"),
            content: new Text("Data has been exported successfully, at folder $path!"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close",
                style: TextStyle(color: Colors.deepOrange),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  "Show",
                  style: TextStyle(color: Colors.deepOrange),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoadAndViewCsvPage(path: path),
                    ),
                  );
                  
                },
              ),
            ],
          );
        },
      );
      }).catchError((error){
        if(error.toString() == "FileSystemException: Cannot open file, path = '/storage/emulated/0/Download/GuestBookApp/guestbook_Test.csv' (OS Error: No such file or directory, errno = 2)") 
        {
          _showDialogMessage("Permission Denied, Please go to your settings menu and enable permission");
        } else {
          _showDialogMessage(error.toString());
        }
        
      });

    } else {
      _showDialogMessage("Guest is empty!");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.is_active?Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              actions: <Widget>[
                IconButton( 
                  color: color,
                  tooltip: "Image Gallery",
                  icon: Icon(Icons.image),
                  onPressed: (){
                    // Navigator.of(context).pop();
                  }
                )
              ],
              leading: IconButton(
                color: color,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  Navigator.of(context).pop();
                }),
              pinned: true,
              textTheme: Theme.of(context).primaryTextTheme,
              title: Text(widget.category,
                  style: TextStyle(
                    color: color,
                  )),
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 260.0,
                      width: double.infinity,
                      color: Colors.white,
                      child: new Stack(
                        children: <Widget>[
                          _buildImage(),
                          Padding(
                            padding: EdgeInsets.only(top: 100, left: 40),
                            child: Text(widget.name.toString().length > 27? widget.name.toString().substring(0,24)+"...":widget.name.toString(),
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 190, left: 40),
                            child: Text(total.toString() + " Guest's",
                              style: TextStyle(
                                fontFamily: "Roboto",
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              expandedHeight: 245.0,
            )
          ];
        },
        body: _buildGuestList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.person_add),
        label: const Text('Add guest'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AddGuestPage(
                    widget.eventId, "Manual", "", widget.owner
                )
            )
          );
        },
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 10, top: 5),
                child: GestureDetector(
                  onTap: (){
                    _scanQR();
                  },
                  child: Image.asset("assets/images/scan.png", height: 35, width: 35,),
                )
            ),
             Padding(
              padding: EdgeInsets.only(right: 20, top: 0,),
              child: GestureDetector(
                onTap: (){
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("Confirmation"),
                        content: new Text("Are you sure want to Download the Guest Data to CSV?"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("No, Thanks",
                            style: TextStyle(color: Colors.deepOrange),
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          ),
                          new FlatButton(
                            child: new Text(
                              "Yes, Please",
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _generateCSV(context);
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
                child: Image.asset("assets/images/export.png", height: 30, width: 30,),
              )
            ),
          ],
        ),
      ),
    ):Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              leading: IconButton(
                color: color,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  Navigator.of(context).pop();
                }),
              pinned: true,
              textTheme: Theme.of(context).primaryTextTheme,
              title: Text(widget.category,
                  style: TextStyle(
                    color: color,
                  )),
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 260.0,
                      width: double.infinity,
                      color: Colors.white,
                      child: new Stack(
                        children: <Widget>[
                          _buildImage(),
                          Padding(
                            padding: EdgeInsets.only(top: 80, left: 40,),
                            child: Text(widget.name.toString().length > 27? widget.name.toString().substring(0,24)+"...":widget.name.toString(),
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 190, left: 40),
                            child: Text(total.toString() + " Guest's",
                              style: TextStyle(
                                fontFamily: "Roboto",
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              expandedHeight: 245.0,
              backgroundColor: Colors.white,
            )
          ];
        },
        body: _buildGuestList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.file_download),
        label: const Text('Export Guests'),
        onPressed: () {
          _generateCSV(context);
        },
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      
    );
  }
}
