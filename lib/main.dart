import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

String loca = "";
String dist = "";
int delay = 1;
String sent = "";
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

void main() {
  runApp(const MyApp());
  ReadLocation();
}

void ReadLocation() {
  late Position lastStep;
  bool isFistTime = true;

  Timer mytimer = Timer.periodic(Duration(seconds: delay), (timer) async {
    Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10))
        .then((value) {
      if (isFistTime) {
        lastStep = value;
        isFistTime = false;
      }
      double distanceInMeters = Geolocator.distanceBetween(value.latitude,
          value.longitude, lastStep.latitude, lastStep.longitude);
      dist = distanceInMeters.toString();
      print(value);

      if (distanceInMeters > 10) {
        // position passed 10 meters
        isFistTime = true;
        print(value.toJson());

        Future<http.Response> createAlbum(String title) {
          return http.post(
            Uri.parse('https://jsonplaceholder.typicode.com/albums'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: value.toJson(),
          );
        }

        sent = "Json Sent";
        // send
      } else {
        sent = "";
      }

      //print(value.toJson());
      // setState(() {
      loca = value.toString();
      // });
      return value;
    });

    // return value;
    // });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _now;
  late Timer _everySecond;

  @override
  void initState() {
    super.initState();

    // sets first value
    _now = DateTime.now().second.toString();

    // defines a timer
    _everySecond = Timer.periodic(Duration(seconds: delay), (Timer t) {
      setState(() {
        _now = DateTime.now().second.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(loca),
            Text(dist),
            Text(sent),
          ],
        ),
      ),
    );
  }
}
