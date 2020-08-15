import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_a_hind/Provider/disconnectStatus.dart';
import 'package:share_a_hind/Screens/MakeReceiverConnectionScreen.dart';
import 'Screens/HomeScreen.dart';
import 'package:nearby_connections/nearby_connections.dart';
import './Screens/MakeSenderConnectionScreen.dart';
import "./Screens/SendReceiveFileScreen.dart";
import "package:flutter/services.dart";

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
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
    return ChangeNotifierProvider.value(
      value: CheckConnectionStatus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Share India',
        home: HomeScreen(),
        theme: ThemeData(primarySwatch: Colors.orange),
        routes: {
          'send': (context) => MakeSenderConnectionScreen(
              ModalRoute.of(context).settings.arguments),
          'receive': (context) => MakeReceiverConnectionScreen(
              ModalRoute.of(context).settings.arguments),
          'Select File Screen': (context) =>
              SendReceiveFileScreen(ModalRoute.of(context).settings.arguments),
          'home': (context) => HomeScreen()
        },
      ),
    );
  }
}
