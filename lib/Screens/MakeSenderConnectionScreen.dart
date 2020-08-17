import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import "package:flutter/material.dart";
import "package:animator/animator.dart";
import 'package:nearby_connections/nearby_connections.dart';
import "dart:math";
import "package:circle_list/circle_list.dart";
import 'package:provider/provider.dart';
import 'package:share_a_hind/Provider/disconnectStatus.dart';
import 'package:share_a_hind/widgets/timer.dart';
import "../widgets/appbar.dart";
import "../Models/DiscoverDevices.dart";
import "../widgets/threeBounce.dart";
import "../Models/connectedInfo.dart";

class MakeSenderConnectionScreen extends StatefulWidget {
  final name;

  const MakeSenderConnectionScreen(this.name);
  @override
  _MakeSenderConnectionScreenState createState() =>
      _MakeSenderConnectionScreenState();
}

class _MakeSenderConnectionScreenState
    extends State<MakeSenderConnectionScreen> {
  var timer;
  List<DiscoverDevices> discoveredDevices = [];
  CheckConnectionStatus checkConnectionStatus;
  @override
  void initState() {
    startDiscovery();

    super.initState();
  }

  void bodyShowDialog(Widget data, bool canBeDismissed) {
    showDialog(
        context: context,
        barrierDismissible: canBeDismissed,
        builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: data));
  }

  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    timer = Timer(Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.pop(context);
      checkConnectionStatus.notifyConnect();
      Navigator.of(context).pushReplacementNamed("Select File Screen",
          arguments: ConnectedInfo(info.endpointName, id));
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(
            "Connect ${info.authenticationToken} with token ${info.endpointName}",
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),
          actions: [
            FlatButton(
                onPressed: () async {
                  await Nearby().rejectConnection(id);

                  timer.cancel();
                },
                child: Row(children: [Text("Reject"), TImer5sec()]))
          ],
        );
      },
    );
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
          this.setState(() {
            discoveredDevices
                .removeWhere((element) => element.endpointId == endpointId);
          });
        },
        onEndpointFound: (endpointId, endpointName, serviceId) {
          this.setState(() {
            discoveredDevices.add(DiscoverDevices(endpointId, endpointName));
          });
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
    checkConnectionStatus =
        Provider.of<CheckConnectionStatus>(context, listen: false);
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
                                    AutoSizeText(
                                      "Establishing Connection",
                                      maxLines: 1,
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
                          var infox;
                          // Navigator.pop(context);
                          Nearby().requestConnection(
                            widget.name,
                            i.endpointId,
                            onConnectionInitiated: (id, info) {
                              print("error");
                              infox = info;
                              onConnectionInit(id, info);
                            },
                            onConnectionResult: (id, status) {
                              if (status == Status.CONNECTED) {
                              } else if (status == Status.REJECTED) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                timer.cancel();
                                bodyShowDialog(
                                    Text("Connection Rejected "), true);
                              } else {
                                Navigator.pop(context);
                                bodyShowDialog(Text("Fatal Error"), true);
                              }
                              print(status);
                            },
                            onDisconnected: (id) {
                              checkConnectionStatus.notifyDisconnect();
                              print("disconnected" + id);
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
