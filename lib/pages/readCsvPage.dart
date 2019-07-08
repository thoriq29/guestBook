import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class _LoadAndViewCsvPageState extends State<LoadAndViewCsvPage> {

  @override
  void initState() {
    super.initState();
    setOrientation();
  }

  @override 
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future setOrientation() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.black,),onPressed: (){Navigator.of(context).pop();},),
        title: Text('Guest List CSV'),
      ),
      body: FutureBuilder(
        future: _loadCsvData(),
        builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: snapshot.data
                    .map(
                      (row) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // Name
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Text(row[0].toString()),
                                ),
                                //Phone
                                Padding(
                                  padding: EdgeInsets.only(left: 50),
                                  child: Text(row[1].toString()),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(row[2].toString()),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(row[3].toString()),
                                ),
                                

                              ],
                            ),
                          ),
                    )
                    .toList(),
              ),
            );
          }

          return Center(
            child: Text('no data found !!!'),
          );
        },
      ),
    );
  }

  Future<List<List<dynamic>>> _loadCsvData() async {
    final file = new File(widget.path).openRead();
    return await file
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();
        
  }
}

class LoadAndViewCsvPage extends StatefulWidget {
  final String path;
  const LoadAndViewCsvPage({Key key, this.path}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoadAndViewCsvPageState();
  }
}