import 'dart:async';

import "package:flutter/material.dart";
import "package:animator/animator.dart";
import 'package:nearby_connections/nearby_connections.dart';
import "dart:math";
import 'package:share_a_hind/Models/connectedInfo.dart';
import 'package:share_a_hind/Provider/disconnectStatus.dart';
import "package:provider/provider.dart";
import 'package:share_a_hind/widgets/timer.dart';
import "../widgets/appbar.dart";

class MakeReceiverConnectionScreen extends StatefulWidget {
  final name;

  const MakeReceiverConnectionScreen(this.name);

  @override
  _MakeReceiverConnectionScreenState createState() =>
      _MakeReceiverConnectionScreenState();
}

class _MakeReceiverConnectionScreenState
    extends State<MakeReceiverConnectionScreen> {
  CheckConnectionStatus checkConnectionStatus;
  var timer;
  @override
  void initState() {
    startAdvertising();
    super.initState();
  }

  void bodyShowDialog(Widget data, bool canBeDismissed) {
    showDialog(
        context: context,
        barrierDismissible: canBeDismissed,
        builder: (_) => AlertDialog(content: data));
  }

  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    timer = Timer(Duration(seconds: 5), () {
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
          content: Text(
            "${info.endpointName} wants to connect with you from Token ${info.authenticationToken} ",
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),
          actions: [
            FlatButton(
                onPressed: () async {
                  await Nearby().rejectConnection(id);
                  Navigator.pop(context);
                },
                child: Row(
                  children: [Text("Reject"), TImer5sec()],
                ))
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

  void startAdvertising() async {
    await Nearby().stopAdvertising();

    final Strategy strategy = Strategy.P2P_POINT_TO_POINT;

    try {
      bool a = await Nearby().startAdvertising(
        widget.name,
        strategy,
        onConnectionInitiated: onConnectionInit,
        onConnectionResult: (id, status) {
          print(status.toString() + "    " + id);
          if (status == Status.CONNECTED) {
          } else if (status == Status.REJECTED) {
            //Navigator.pop(context);
            Navigator.pop(context);
            timer.cancel();
            bodyShowDialog(Text("Connection Rejected "), true);
          } else {
            Navigator.pop(context);
            bodyShowDialog(Text("Fatal Error"), true);
          }
          print(status);
        },
        onDisconnected: (id) {
          checkConnectionStatus.notifyDisconnect();
          print("Disconnected: " + id);
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
    return Container(
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
              width: MediaQuery.of(context).size.width,
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
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
