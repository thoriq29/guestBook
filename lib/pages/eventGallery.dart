import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:guestbook/pages/sharedImageDetail.dart';
import 'package:guestbook/pages/eventLovedPict.dart';

final List<String> imgList = [
  'assets/images/wedding_decoration.jpg',
  'assets/images/party.jpg'
];
final List<String> imgListNetwork = [
  'aaaa'
];

// bool hasData = false;
List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class EventGalleryPage extends StatefulWidget {
  EventGalleryPage(this.eventId);
  final eventId;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventGalleryState();
  }
}

class _EventGalleryState extends State<EventGalleryPage> {
  // List<String> imgList = List<String>();
  bool hasData = false;
  String sample = 'https://firebasestorage.googleapis.com/v0/b/writehere-13.appspot.com/o/party.jpeg?alt=media&token=6d663863-0e47-4288-82ee-2a3638a75f32';
  final Widget placeholder = Container(color: Colors.grey);
  int _current = 0;
  String title;
  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  final List childs = map<Widget>(
    imgList,
    (index, i) {
      return Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Stack(children: <Widget>[
            Image.asset(i,fit: BoxFit.cover, width: 1000.0),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  'No. $index image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    },
  ).toList();

  final List childe = map<Widget>(
    imgListNetwork,
    (index, i) {
      return Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Stack(children: <Widget>[
            Image.network(i,fit: BoxFit.cover, width: 1000.0),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  'No. $index image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    },
  ).toList();


  final CarouselSlider autoPlayDemo = CarouselSlider(
    viewportFraction: 0.9,
    aspectRatio: 2.0,
    autoPlay: true,
    enlargeCenterPage: true,
    items:imgList.map(
      (url) {
        return Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Image.asset(url,
              fit: BoxFit.cover,
              width: 1000.0,
            ),
          ),
        );
      },
    ).toList(),
  );

  Widget imagesSlider() {
    return CarouselSlider(
      viewportFraction: 0.9,
      aspectRatio: 2.0,
      autoPlay: true,
      onPageChanged: (index) {
        setState(() {
          _current = index;
        });
      },
      enlargeCenterPage: true,
      items:imgListNetwork.map(
        (url) {
          return Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: FadeInImage(
                placeholder: AssetImage('assets/images/placeholder-image.png'),
                image: NetworkImage(url??sample.toString()),
                
                fit: BoxFit.cover,
                width: 1000.0,
              ),
            ),
          );
        },
      ).toList()
    );
  }
  void getImage() async {
    QuerySnapshot result = await Firestore.instance.collection("gallery")
                  .where('at_event', isEqualTo: widget.eventId)
                  .where('is_active', isEqualTo: true)
                  .limit(5)
                  .getDocuments();
    var documents = result.documents;
    if(documents.length > 0) {
      imgListNetwork.clear();
      for(var doc in documents) {
        setState(() {
          hasData = true;
          imgListNetwork.add(doc['image']);
        });
      }
    }
  }

  void setFavorite(bool hasFav, id)  {
    bool toFav = false;
    if(!hasFav) {
      toFav = true;
    }

    Firestore.instance.collection("gallery").document(id).updateData({
      'loved': toFav,
    });

  }

  Widget getData() {
    return StreamBuilder(
      stream: Firestore.instance.collection("gallery")
              .where('at_event', isEqualTo: widget.eventId)
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
                    onDoubleTap: () {
                      setFavorite(snapshot.data.documents[index]['loved'],snapshot.data.documents[index].documentID);
                    },
                    onTap: () => 
                    Navigator.of(context).push(
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
                                  icon: snapshot.data.documents[index]['loved']?Icon(Icons.favorite, size: 25, color: Colors.red,):Icon(Icons.favorite_border, size: 25, color: Colors.deepOrange,),
                                  onPressed: (){
                                    setFavorite(snapshot.data.documents[index]['loved'],snapshot.data.documents[index].documentID);
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
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          color: Colors.deepOrange,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
        actions: <Widget>[
          IconButton(
            color: Colors.deepOrange,
            tooltip: "Loved Moments",
            icon: Icon(Icons.favorite),
            onPressed: (){
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) => LovedImagePage(widget.eventId))
              );
            }
          )
        ],
        title: Text("Gallery Moments"),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: hasData?imagesSlider():autoPlayDemo
          ),
          Positioned(
            top: 185.0,
            left: 25.0,
            // right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(imgListNetwork, (index, url) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index ? Color.fromRGBO(0, 0, 0,1.0) : Color.fromRGBO(0, 0, 0, 0.6)
                  ),
                );
              }),
            )
          ),
          MediaQuery.of(context).orientation == Orientation.portrait? Padding(
            padding: EdgeInsets.only(top:210, left: 20, right: 10),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: getData(),
            ),
          ):Container()
        ],
      )
    );
  }
}