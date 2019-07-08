import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';

class EditorPhotoPage extends StatefulWidget {
  EditorPhotoPage(this.eventId, this.userId);
  final eventId, userId;
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<EditorPhotoPage> {
  String fileName;
  String caption = "";
  List<Filter> filters = presetFiltersList;
  File imageFile;
  bool isLoading = false, isDone = false, titleDiisi = false;
  double progress;

  Future getImage(context) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.askUser);
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
        'foto': url,
        'userId': widget.userId,
        'at_event': widget.eventId,
        'caption': caption,
        'tanggal_upload': Timestamp.now()
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text("Share Moment"),
      ),
      body: Center(
        child: new Container(
          child: imageFile == null
              ? Center(
                  child: new Text('No image selected.'),
                )
              : Image.file(imageFile),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => getImage(context),
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
