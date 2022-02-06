import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:oh_oneshot/models/AirResult.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const Main(),
    );
  }
}

///
///

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  late AirResult _result;

  Future<AirResult> fetchData() async {
    var response = await http.get(Uri.parse(
        'https://api.airvisual.com/v2/nearest_city?key=af726267-43e4-44fb-a7dd-6843d8f212ce'));

    AirResult result = AirResult.fromJson(json.decode(response.body));
    return result;
  }

  @override
  void initState() {
    super.initState();

    fetchData().then((airResult) {
      setState(() {
        _result = airResult;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _result == null
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('현재 위치 mi세먼지', style: TextStyle(fontSize: 30)),
                    SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            color: getColor(_result),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('얼굴사진'),
                                Text(
                                    '${_result.data?.current?.pollution?.aqius}',
                                    style: TextStyle(fontSize: 40)),
                                Text(getString(_result),
                                    style: TextStyle(fontSize: 20))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(children: [
                                  Image.network(
                                      'https://airvisual.com/images/${_result.data?.current?.weather?.ic}.png',
                                      width: 32,
                                      height: 32),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text('${_result.data?.current?.weather?.tp}°',
                                      style: TextStyle(fontSize: 16))
                                ]),
                                Text(
                                    '습도 ${_result.data?.current?.weather?.hu}%'),
                                Text(
                                    '풍속 ${_result.data?.current?.weather?.ws}m/s')
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: RaisedButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 50),
                        color: Colors.orange,
                        child: Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Color getColor(AirResult result) {
    dynamic faqius = result.data?.current?.pollution?.aqius;

    if (faqius < 50) {
      return Colors.greenAccent;
    } else if (faqius < 100) {
      return Colors.yellow;
    } else if (faqius < 150) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String getString(AirResult result) {
    dynamic faqius = result.data?.current?.pollution?.aqius;

    if (faqius < 50) {
      return '조흠';
    } else if (faqius < 100) {
      return '보우통';
    } else if (faqius < 150) {
      return '나쁘음';
    } else {
      return '최악';
    }
  }
}
