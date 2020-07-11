import 'package:flutter/material.dart';
import 'package:share_a_hind/Screens/MakeReceiverConnectionScreen.dart';
import 'Screens/HomeScreen.dart';
import 'package:nearby_connections/nearby_connections.dart';
import './Screens/MakeSenderConnectionScreen.dart';
import "./Screens/SendReceiveFileScreen.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    handlePermission();
  }

  void handlePermission() async {
    while (!await Nearby().checkLocationPermission())
      Nearby().askLocationPermission();
    while (!await Nearby().checkExternalStoragePermission())
      Nearby().askExternalStoragePermission();
    while (!await Nearby().checkLocationEnabled())
      Nearby().enableLocationServices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Share India',
      home: HomeScreen(),
      routes: {
        'send': (_) => MakeSenderConnectionScreen(),
        'receive': (_) => MakeReceiverConnectionScreen(),
        'Select File Screen': (context) =>
            SendReceiveFileScreen(ModalRoute.of(context).settings.arguments)
      },
    );
  }
}
