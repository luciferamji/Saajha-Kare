import 'dart:async';
import 'dart:typed_data';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import "package:flutter/material.dart";
import "package:nearby_connections/nearby_connections.dart";
import "dart:io";
import 'package:file_picker/file_picker.dart';

class SendReceiveFileScreen extends StatefulWidget {
  final args;

  const SendReceiveFileScreen(this.args);

  @override
  _SendReceiveFileScreenState createState() => _SendReceiveFileScreenState();
}

class _SendReceiveFileScreenState extends State<SendReceiveFileScreen> {
  Map<String, double> incomingFiles = {};
  Map<String, List<Color>> mapColor = {};

  List<Color> colorSend = [Color(0xFFFE5502), Color(0xFFFCD5A0)];
  List<Color> colorReceived = [Color(0xFF2B7B28), Color(0xFFB2F7C2)];
  File tempFile; //reference to the file currently being transferred
  var transferinSeconds = 0;
  var transferData = 0;
  var currentSpeed = 0.0;
  var currentSpeedData = 0.0;
  var swatch = Stopwatch();
  Map<int, String> map = Map();
  var stopWatchIsRunning = false;

  @override
  void initState() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Timer.periodic(Duration(seconds: 1), updateSpeed);
    super.initState();
    acceptConnection();
  }

  void updateSpeed(timer) {
    this.setState(() {
      currentSpeedData = (currentSpeed / 1000000);
    });
    currentSpeed = 0;
  }

  void acceptConnection() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    Nearby().acceptConnection(
      widget.args,
      onPayLoadRecieved: (endid, payload) async {
        if (payload.type == PayloadType.BYTES) {
          String str = String.fromCharCodes(payload.bytes);

          if (str.contains(':')) {
            int payloadId = int.parse(str.split(':')[0]);
            String fileName = (str.split(':')[1]);
            this.setState(() {
              incomingFiles["$fileName"] = 0;
              mapColor[fileName] = colorSend;
            });
            if (map.containsKey(payloadId)) {
              if (await tempFile.exists()) {
                tempFile.rename(tempFile.parent.path + "/" + fileName);
              } else {
                print("File doesnt exist");
              }
            } else {
              print("hiiiiii");

              map[payloadId] = fileName;
            }
          }
        } else if (payload.type == PayloadType.FILE) {
          print(endid + ": File transfer started");
          tempFile = File(payload.filePath);
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
        String name = map[payloadTransferUpdate.id];

        if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRRESS) {
          transferinSeconds =
              payloadTransferUpdate.bytesTransferred - transferData;
          transferData += transferinSeconds;
          currentSpeed += transferinSeconds;
          print(transferinSeconds.toString() +
              "                               " +
              payloadTransferUpdate.bytesTransferred.toString() +
              "                               " +
              transferData.toString() +
              "                              " +
              currentSpeed.toString());
          this.setState(() {
            incomingFiles[name] = (payloadTransferUpdate.bytesTransferred /
                payloadTransferUpdate.totalBytes);
          });
        } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
          print("failed");
          print(endid + ": FAILED to transfer file");
        } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
          transferinSeconds = 0;
          transferData = 0;
          this.setState(() {
            incomingFiles[name] = 1;
          });

          if (map.containsKey(payloadTransferUpdate.id)) {
            String name = map[payloadTransferUpdate.id];
            tempFile.rename(tempFile.parent.path + "/" + name);
          } else {
            map[payloadTransferUpdate.id] = "";
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: RaisedButton(
        child: Text("Send File Payload"),
        onPressed: () async {
          List<File> files = await FilePicker.getMultiFile();
          int i = 0;
          if (files == null) return;
          while (i != files.length) {
            int payloadId =
                await Nearby().sendFilePayload(widget.args, files[i].path);

            map[payloadId] = files[i].path.split('/').last;
            this.setState(() {
              incomingFiles[files[i].path.split('/').last] = 0;
              mapColor[files[i].path.split('/').last] = colorReceived;
            });

            Nearby().sendBytesPayload(
                widget.args,
                Uint8List.fromList(
                    "$payloadId:${files[i].path.split('/').last}".codeUnits));
            i += 1;
          }
        },
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true, //change si
            automaticallyImplyLeading: false,
            title: Text("My App Bar"),
            flexibleSpace: Container(
              child: FlexibleSpaceBar(
                background: Center(
                  child: Container(
                    child: Text(currentSpeedData.toStringAsFixed(2)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange,
                          Colors.white,
                          Color(0xFFB4F6C1)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 5,
                  colors: [Colors.orange, Colors.white, Color(0xFFB4F6C1)],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              String key = incomingFiles.keys.elementAt(i);
              if (key == null) return Text("");
              double value = incomingFiles.values.elementAt(i);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  margin: EdgeInsets.only(bottom: 5, right: 5, left: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: mapColor[key][0],
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Text(
                            key,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: mapColor[key][0], fontSize: 18),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _AnimatedLiquidLinearProgressIndicator(
                          value, key, mapColor[key]),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: incomingFiles.length),
          ),
          SliverFillRemaining(
            child: Text(""),
          )
          // SliverFillRemaining(
          //   child: SingleChildScrollView(
          //     child: Container(
          //       color: Color(0xFFE8EEFF),
          //       child: Container(
          //         height: MediaQuery.of(context).size.height * 0.9,
          //         color: Colors.white,
          //         child: ListView.builder(
          //           itemBuilder: (_, i) {
          //             String key = incomingFiles.keys.elementAt(i);
          //             if (key == null) return SizedBox.shrink();
          //             double value = incomingFiles.values.elementAt(i);

          //             return Card(
          //               margin: EdgeInsets.only(bottom: 15, right: 5, left: 5),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               shadowColor: mapColor[key][0],
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Padding(
          //                     padding:
          //                         const EdgeInsets.symmetric(horizontal: 8),
          //                     child: Container(
          //                       width: MediaQuery.of(context).size.width * 0.75,
          //                       child: Text(
          //                         key,
          //                         overflow: TextOverflow.ellipsis,
          //                         style: TextStyle(
          //                             color: mapColor[key][0], fontSize: 18),
          //                         textAlign: TextAlign.left,
          //                       ),
          //                     ),
          //                   ),
          //                   SizedBox(
          //                     height: 10,
          //                   ),
          //                   _AnimatedLiquidLinearProgressIndicator(
          //                       value, key, mapColor[key]),
          //                 ],
          //               ),
          //             );
          //           },
          //           itemCount: incomingFiles.length,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _AnimatedLiquidLinearProgressIndicator extends StatefulWidget {
  final data;
  final keyx;
  final color;
  const _AnimatedLiquidLinearProgressIndicator(
      this.data, this.keyx, this.color);

  @override
  State<StatefulWidget> createState() =>
      _AnimatedLiquidLinearProgressIndicatorState();
}

class _AnimatedLiquidLinearProgressIndicatorState
    extends State<_AnimatedLiquidLinearProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    double percent = widget.data * 100;
    return Center(
      child: Container(
        width: double.infinity,
        height: 20.0,
        child: LiquidLinearProgressIndicator(
          value: widget.data,
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(widget.color[1]),
          borderRadius: 3.0,
          center: Text(
            percent.toStringAsFixed(2) + "%",
            style: TextStyle(
              color: widget.color[0],
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
