import "package:flutter/material.dart";
import "package:animator/animator.dart";
import 'package:nearby_connections/nearby_connections.dart';
import "dart:math";
import "package:circle_list/circle_list.dart";
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
  @override
  void initState() {
    startAdvertising();
    super.initState();
  }

  void onConnectionInit(String id, ConnectionInfo info) {
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
        },
        onDisconnected: (id) {
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
                  FittedBox(
                    fit: BoxFit.cover,
                    child: Animator<double>(
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
