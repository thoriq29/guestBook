import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:guestbook/pages/sharedImageDetail.dart';

class EditorPhotoPage extends StatefulWidget {
  EditorPhotoPage(this.eventId, this.userId);
  final eventId, userId;
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<EditorPhotoPage>  with SingleTickerProviderStateMixin {
  String fileName, title="Your shared moments :";
  String caption = "";
  List<Filter> filters = presetFiltersList;
  File imageFile;
  bool isLoading = false, isDone = false, titleDiisi = false;
  double progress;

  bool isOpened = false, isLogin = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  void initState() {
    super.initState();

    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.deepOrange,
      end: Colors.orangeAccent,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
  }

  Future getImage(context) async {
    
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    fileName = basename(imageFile.path);
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
        fileName = basename(imageFile.path);
        uploadImageToStorage(context, imageFile);
      });
      print("bbb $caption");
      print("aaaa ${imageFile.path}");
    }
  }

  Future getImageCamera(context) async {
    
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    fileName = basename(imageFile.path);
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
        fileName = basename(imageFile.path);
        uploadImageToStorage(context, imageFile);
      });
      print("bbb $caption");
      print("aaaa ${imageFile.path}");
    }
  }

  animasi() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animasi,
        tooltip: 'Option',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  Widget uploadViaGaleri(BuildContext context) {
    return Container(
      child: FloatingActionButton(
        onPressed: () => getImage(context),
        heroTag: null,
        tooltip: 'Upload from Gallery',
        child: Icon(Icons.image),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Widget uploadViaKamera(BuildContext context) {
    return Container(
      child: FloatingActionButton(
        onPressed: () => getImageCamera(context),
        heroTag: null,
        tooltip: 'Upload dari Camera',
        child: Icon(Icons.camera),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Future<String> uploadImageToStorage(BuildContext context, image) async {
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
      _showDialogMessage(context, "Moment has been uploaded, Thank You 😊");
      // Navigator.of(context).pushReplacementNamed('/galeri_regu');
    });

    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();

    print("Download URL : $url");

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(Firestore.instance.collection("gallery").document(), {
        'image': url,
        'loved': false,
        'is_active': true,
        'userId': widget.userId,
        'at_event': widget.eventId,
        'caption': caption,
        'uploaded_at': Timestamp.now()
      });
    });
    return url;
  }

  
  void _showDialogMessage(BuildContext context, message) {
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

  void setDelete(BuildContext context ,id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Confirmation"),
          content: new Text("Are You sure want to delete this pict?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "No, Thanks",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Yes, Please",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Firestore.instance.collection("gallery").document(id).updateData({
                  'is_active': false,
                });
                _showDialogMessage(context, "Pict deleted successfully");
              },
            ),
          ],
        );
      },
    );
  }

  Widget getData() {
    return StreamBuilder(
      stream: Firestore.instance.collection("gallery")
              .where('at_event', isEqualTo: widget.eventId)
              .where('userId', isEqualTo: widget.userId)
              .where('is_active', isEqualTo: true)
              .snapshots(),
      builder: (context, snapshot) {
          if (!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.deepOrange)
              )
            );
          
          }else if(snapshot.hasData && snapshot.data.documents.length == 0) {            
            Timer(Duration(microseconds: 3), () {
              setState(() {
                title= "";
              });
            });
            return Center(
              child: Text("You dont have shared moment"
              )
            );
          }
          else{
            Timer(Duration(microseconds: 3), () {
                setState(() {
                  title= "Your shared moments :";
                });
              });
            return OrientationBuilder(builder: (context, orientation) {
              return GridView.builder(
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                    orientation == Orientation.portrait ? 3 : 5),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => GaleriImageView(
                                selectedPicID: snapshot
                                    .data.documents[index].documentID))),
                    child: Card(
                      child: GridTile(
                        child: Stack(
                          children: <Widget>[
                            FadeInImage(
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              placeholder:
                              AssetImage('assets/images/placeholder-image.png'),
                              image: NetworkImage(
                                snapshot.data.documents[index]['image'],
                              ),
                            ),
                            Positioned(
                              top: -8.0,
                              right: 0.0,
                              left: 64.0,
                              child: Padding(
                                padding: EdgeInsets.all(0),
                                child: IconButton(
                                  icon: Icon(Icons.delete, size: 25, color: Colors.deepOrange,),
                                  onPressed: (){
                                    setDelete(context,snapshot.data.documents[index].documentID);
                                  },
                                ),
                              )
                          ),
                          ],
                        )
                      ),
                    ),
                  );
                },
              );
            });
          }
        }

    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        leading: IconButton(
          color: Colors.deepOrange,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
        title: new Text("Share Moment"),
      ),
      body: imageFile == null? Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, left: 15),
            child: Text(title,
            style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto"
                  ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.only(top: 30, left: 20, right: 10),
              child: getData(),
            ),
          )
        ],
      ): Image.file(imageFile),
      floatingActionButton: isOpened? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * 2.0,
                0.0,
              ),
              child: uploadViaGaleri(context),
            ),
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value,
                0.0,
              ),
              child: uploadViaKamera(context),
            ),
            toggle()
          ],
        ): toggle()
    );
  }
}
