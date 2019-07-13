import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventLocationPage extends StatefulWidget {
  EventLocationPage(this.lat, this.lng, this.name);
  final lat, lng, name;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventLocationPageState();
  }
}

class _EventLocationPageState extends State<EventLocationPage> {

  var currentLocation = <String, double>{};
  double posisiLatUser, posisiLongUser;
  bool isFirstTimeClick = true;
  var location = Location();
  Completer<GoogleMapController> _controller = Completer();
  final Firestore _database = Firestore.instance;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();
    getLocationAndMarker();
  }

  calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
    c(lat1 * p) * c(lat2 * p) *
    (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a) * 1000);
  }

  void initMarker() {
    var markerIdVal = "posisi";
    double totalDistance = 0;
    final MarkerId markerId = MarkerId(markerIdVal);
    if(posisiLatUser != null && posisiLongUser != null) {
     totalDistance = calculateDistance(posisiLatUser, posisiLongUser,double.parse(widget.lat), double.parse(widget.lng));
    }
    String a = int.parse(totalDistance.toString().substring(0,totalDistance.toString().indexOf('.'))).toString();
    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(double.parse(widget.lat)??'', double.parse(widget.lng)??''),
      infoWindow: InfoWindow(title: widget.name??'',snippet:  "$a M dari posisi anda"),
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  _getLocation() async {
    try {
      currentLocation = await location.getLocation();

      setState(
          () {}); 
    } on Exception {
      currentLocation = null;
    }
  }

  getLocationAndMarker() async {
    await _getLocation();
    location.onLocationChanged().listen((currentLocation) {
      posisiLatUser   = currentLocation['latitude'] != null ? currentLocation['latitude'] : 21.41919383;
      posisiLongUser  = currentLocation['longitude'] != null ? currentLocation['longitude'] : 39.82646942;
      initMarker();
    });
    

    
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1.0)
          ),
        ),
        padding: EdgeInsets.only(top: 10),
        height:MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
              target: LatLng(posisiLatUser != null ? currentLocation['latitude']: double.parse(widget.lat) , posisiLongUser != null ? currentLocation['longitude']: double.parse(widget.lng)), zoom: 10.0),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(markers.values),
        ),
      ),
    );
  }
}
