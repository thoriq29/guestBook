import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQRPage extends StatefulWidget {
  ShowQRPage(this.userId);
  final userId;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShowQRPageState();
  }
}

class _ShowQRPageState extends State<ShowQRPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: 'qrcode',
            child: Container(
              padding: EdgeInsets.all(15),
              height: 200,
              color: Colors.white,
              width: 200,
              child: QrImage(
                data: widget.userId.toString(),
                size: 120.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}