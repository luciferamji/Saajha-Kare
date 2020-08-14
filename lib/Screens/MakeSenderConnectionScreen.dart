import "package:flutter/material.dart";
import "package:animator/animator.dart";
import 'package:nearby_connections/nearby_connections.dart';
import "dart:math";
import "package:circle_list/circle_list.dart";
import "../widgets/appbar.dart";
import "../Models/DiscoverDevices.dart";
import "../widgets/threeBounce.dart";

class MakeSenderConnectionScreen extends StatefulWidget {
  final name;

  const MakeSenderConnectionScreen(this.name);
  @override
  _MakeSenderConnectionScreenState createState() =>
      _MakeSenderConnectionScreenState();
}

class _MakeSenderConnectionScreenState
    extends State<MakeSenderConnectionScreen> {
  List<DiscoverDevices> discoveredDevices = [];
  @override
  void initState() {
    startDiscovery();

    super.initState();
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text(
            "Confirm this token ${info.authenticationToken} with ${info.endpointName}",
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed("Select File Screen", arguments: id);
                },
                child: Text("Accept")),
            FlatButton(
                onPressed: () async {
                  await Nearby().rejectConnection(id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Reject"))
          ],
        );
      },
    );
    // showModalBottomSheet(
    //   context: context,
    //   builder: (builder) {
    //     return Center(
    //       child: Column(
    //         children: <Widget>[
    //           Text("hihihi"),
    //           Text("id: " + id),
    //           Text("Token: " + info.authenticationToken),
    //           Text("Name" + info.endpointName),
    //           Text("Incoming: " + info.isIncomingConnection.toString()),
    //           Text("Accept Connection"),
    //           RaisedButton(onPressed: () {
    //             Navigator.pop(context);
    //             Navigator.of(context)
    //                 .pushNamed("Select File Screen", arguments: id);
    //           })
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  void startDiscovery() async {
    await Nearby().stopDiscovery();
    await Nearby().stopAdvertising();
    final Strategy strategy = Strategy.P2P_POINT_TO_POINT;

    try {
      bool a = await Nearby().startDiscovery(
        widget.name,
        strategy,
        onEndpointLost: (endpointId) {
          print("disconnected");
          this.setState(() {
            discoveredDevices
                .removeWhere((element) => element.endpointId == endpointId);
          });
          print(discoveredDevices);
        },
        onEndpointFound: (endpointId, endpointName, serviceId) {
          this.setState(() {
            discoveredDevices.add(DiscoverDevices(endpointId, endpointName));
          });
          print(discoveredDevices);
          // showModalBottomSheet(
          //   context: context,
          //   builder: (builder) {
          //     return Center(
          //       child: Column(
          //         children: <Widget>[
          //           Text("id: " + endpointId),
          //           Text("Name: " + endpointName),
          //           Text("ServiceId: " + serviceId),
          //           RaisedButton(
          //             child: Text("Request Connection"),
          //             onPressed: () {
          //               Navigator.pop(context);
          //               Nearby().requestConnection(
          //                 widget.name,
          //                 endpointId,
          //                 onConnectionInitiated: (id, info) {
          //                   onConnectionInit(id, info);
          //                 },
          //                 onConnectionResult: (id, status) {
          //                   print(status);
          //                 },
          //                 onDisconnected: (id) {
          //                   print(id);
          //                 },
          //               );
          //             },
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // );
        },
      );

      print("ADVERTISING: " + a.toString());
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.white, Color(0xFFB4F6C1)],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: MyAppbar(),
          body: Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              child: Stack(
                children: [
                  Animator<double>(
                      duration: Duration(seconds: 10),
                      repeats: 1000,
                      tween: Tween<double>(begin: 0, end: 2 * pi),
                      builder: (_, anim, __) {
                        return Center(
                          child: Transform.rotate(
                            angle: anim.value,
                            child: Opacity(
                                opacity: 0.26,
                                child: Image.asset(
                                    "assets/images/ashok_chakra.png")),
                          ),
                        );
                      }),
                  CircleList(origin: Offset(0, 0), children: [
                    for (var i in discoveredDevices)
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            isDismissible: false,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (builder) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(25.0),
                                    topRight: const Radius.circular(25.0),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "Establishing Connection",
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.blue[900]),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Image.asset(
                                              "assets/images/sender.png",
                                              scale: 3,
                                            ),
                                            Text(
                                              widget.name,
                                              style: TextStyle(
                                                  color: Colors.orange[900],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )
                                          ],
                                        ),
                                        SpinKitThreeBounce(
                                          color: Colors.white,
                                        ),
                                        Column(
                                          children: [
                                            Image.asset(
                                              "assets/images/reciever.png",
                                              scale: 3,
                                              fit: BoxFit.contain,
                                            ),
                                            Text(
                                              i.endpointName,
                                              style: TextStyle(
                                                  color: Colors.green[900],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          // Navigator.pop(context);
                          Nearby().requestConnection(
                            widget.name,
                            i.endpointId,
                            onConnectionInitiated: (id, info) {
                              onConnectionInit(id, info);
                            },
                            onConnectionResult: (id, status) {
                              print(status);
                            },
                            onDisconnected: (id) {
                              print(id);
                            },
                          );
                        },
                        child: Container(
                          height: 120,
                          child: (Column(
                            children: [
                              Image.asset(
                                "assets/images/phone.png",
                                scale: 5,
                                fit: BoxFit.contain,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 100,
                                child: Text(
                                  i.endpointName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                ),
                              )
                            ],
                          )),
                        ),
                      )
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
