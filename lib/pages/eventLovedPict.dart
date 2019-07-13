import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/pages/sharedImageDetail.dart';

class LovedImagePage extends StatefulWidget {
  LovedImagePage(this.eventId);
  final eventId;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LovedImagePageState();
  }
}

class _LovedImagePageState extends State<LovedImagePage> {
  String title="Your Loved moments :";

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
              .where('loved', isEqualTo: true)
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
              child: Text("You dont have loved moment"
              )
            );
          }
          else{
            Timer(Duration(microseconds: 3), () {
                setState(() {
                  title= "Your loved moments :";
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
      appBar: new AppBar(
        elevation: 0.0,
        leading: IconButton(
          color: Colors.deepOrange,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
        title: new Text("Loved Moments"),
      ),
      body: Stack(
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
        ]
      ),
    );
  }
}