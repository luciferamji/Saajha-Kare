import "package:flutter/material.dart";
import 'package:nearby_connections/nearby_connections.dart';
import 'package:share_a_hind/widgets/appbar.dart';
import 'package:permission_handler/permission_handler.dart';

class Permission extends StatefulWidget {
  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppbar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                    Text(
                      "Permissions",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                    FlatButton(
                        onPressed: () async {
                          Nearby().enableLocationServices();
                        },
                        child: Text(
                          "Enable Location Services",
                          style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                    FlatButton(
                        onPressed: () async {
                          openAppSettings();
                        },
                        child: Text(
                          "Setup Permissions Manually",
                          style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('home');
              },
              child: const Text('Back To Homepage',
                  style: TextStyle(fontSize: 20)),
              color: Colors.orange[900],
              textColor: Colors.white,
              elevation: 5,
            )
          ],
        ),
      ),
    );
  }
}
