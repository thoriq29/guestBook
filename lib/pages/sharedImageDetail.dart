import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

class GaleriImageView extends StatefulWidget {
  final String selectedPicID;

  GaleriImageView({this.selectedPicID});
  @override
  _GaleriImageViewState createState() => _GaleriImageViewState();
}

class _GaleriImageViewState extends State<GaleriImageView> {
  final Firestore _database = Firestore.instance;
  String _localPath;
  TargetPlatform platform;
  var snapshotData, namaFoto;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    makeDownloadDirectory();
  }

  void makeDownloadDirectory() async {
    await prepareDownloadDirectory();
    bool checkDirectory = await Directory(_localPath).exists();
    if (checkDirectory != true) {
      Directory(_localPath).create(recursive: true);
    }
  }

  Future prepareDownloadDirectory() async {
    _localPath = (await _findLocalPath()) + '/Download/Belle';
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  void saveImage(String url, String caption) async {
    File _image;
    setState(() {
      isLoading = true;
    });
    _onLoading();
    var response = await http.get(url);
    print(response.statusCode);
    if(response.statusCode == 200) {
      var filePath = await ImagePickerSaver.saveFile(
        fileData: response.bodyBytes
      );
      setState(() {
        isLoading = false;
      });
      Navigator.of(context, rootNavigator: true).pop();
      dialogMessage(filePath);
      print(filePath);
      print(isLoading);
      String BASE64_IMAGE = filePath;
      
      final ByteData byteData = await rootBundle.load(BASE64_IMAGE);
    } else {
      print(response.statusCode);
    }
  }

  void _onLoading() {
    if(isLoading) {
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
                  child: Text("Downloading ...", style: TextStyle(fontSize: 17),),
                )
              ],
            ),
            
          ); 
      });
    } else {
      Navigator.pop(context);
    }
  }

  void dialogMessage(path) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmation"),
            content: new Text("Image downloaded. Please check your gallery", style: TextStyle(fontSize: 17),),
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
        });
        
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _database
            .collection('gallery')
            .document(widget.selectedPicID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange)));
          }else{
            var snapshotData = snapshot.data;
            return Scaffold(
              body: SingleChildScrollView(
                child: FadeInImage(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 50,
                  placeholder: AssetImage('assets/images/loading_foto_regu.gif'),
                  image: NetworkImage(
                    snapshotData['image'],
                  ),
                ),
              ),
              bottomSheet: Container(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  border: Border(top: BorderSide(color: Colors.grey, width: 1.0)),
                  
                ),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                              child: Text(
                                snapshot.data['caption'],
                                style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    color: Colors.white,
                                    fontSize: 15.0),
                              ))
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: 50.0,
                          width: 50.0,
                          child: FlatButton(
                              child: Icon(Icons.file_download, color:Colors.white,),
                              onPressed: () {
                                saveImage(
                                    snapshotData['image'],
                                    snapshotData['caption'].toString());
                              }),
                        ),
                      ]
                    )
                  ],
                ),
              ),
            );
          }


        });
  }
}
