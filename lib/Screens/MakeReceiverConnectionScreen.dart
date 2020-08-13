import "package:flutter/material.dart";
import "package:animator/animator.dart";
import 'package:nearby_connections/nearby_connections.dart';
import "dart:math";

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
    startDiscovery();

    super.initState();
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("hihihi"),
              Text("id: " + id),
              Text("Token: " + info.authenticationToken),
              Text("Name" + info.endpointName),
              Text("Incoming: " + info.isIncomingConnection.toString()),
              Text("Accept Connection"),
              RaisedButton(onPressed: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .pushNamed("Select File Screen", arguments: id);
              })
            ],
          ),
        );
      },
    );
  }

  void startDiscovery() async {
    await Nearby().stopDiscovery();
    final Strategy strategy = Strategy.P2P_POINT_TO_POINT;

    try {
      bool a = await Nearby().startDiscovery(
        widget.name,
        strategy,
        onEndpointLost: (endpointId) => print("disconnected"),
        onEndpointFound: (endpointId, endpointName, serviceId) =>
            showModalBottomSheet(
          context: context,
          builder: (builder) {
            return Center(
              child: Column(
                children: <Widget>[
                  Text("id: " + endpointId),
                  Text("Name: " + endpointName),
                  Text("ServiceId: " + serviceId),
                  RaisedButton(
                    child: Text("Request Connection"),
                    onPressed: () {
                      Navigator.pop(context);
                      Nearby().requestConnection(
                        widget.name,
                        endpointId,
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
                  ),
                ],
              ),
            );
          },
        ),
      );
      print("ADVERTISING: " + a.toString());
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
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
                          opacity: 0.5,
                          child: Image.asset("assets/images/ashok_chakra.png")),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
