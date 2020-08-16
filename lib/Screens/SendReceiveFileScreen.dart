import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import "package:flutter/material.dart";
import "package:nearby_connections/nearby_connections.dart";
import "dart:io";
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_a_hind/Provider/disconnectStatus.dart';
import 'package:open_file/open_file.dart';
import 'package:share_a_hind/Models/sharingFiles.dart';

class SendReceiveFileScreen extends StatefulWidget {
  final args;

  const SendReceiveFileScreen(this.args);

  @override
  _SendReceiveFileScreenState createState() => _SendReceiveFileScreenState();
}

class _SendReceiveFileScreenState extends State<SendReceiveFileScreen> {
  Map<String, double> incomingFiles = {};
  Map<String, List<Color>> mapColor = {};
  List<SharingFiles> sharedFiles = [];

  List<Color> colorSend = [Color(0xFFFE5502), Color(0xFFFCD5A0)];
  List<Color> colorReceived = [Color(0xFF2B7B28), Color(0xFFB2F7C2)];
  Map<int, File> tempFile =
      Map(); //reference to the file currently being transferred
  var transferinSeconds = 0;
  var transferData = 0;
  var currentSpeed = 0.0;
  var currentSpeedData = 0.0;
  var swatch = Stopwatch();
  Map<int, String> map = Map();
  Map<int, bool> tempFileCheck = Map();
  var stopWatchIsRunning = false;
  var timer;

  @override
  void initState() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    timer = Timer.periodic(Duration(seconds: 1), updateSpeed);
    super.initState();
    acceptConnection();
  }

  void updateSpeed(timer) async {
    this.setState(() {
      if (currentSpeed / 1000000 > 33.0 || currentSpeed / 1000000 < 0)
        currentSpeedData = Random().nextDouble() * (20 - 10) + 10;
      currentSpeedData = currentSpeedData = (currentSpeed / 1000000);
    });
    currentSpeed = 0;
    tempFileCheck.keys.toList().forEach((element) {
      sharedFiles.add(SharingFiles(
          map[element],
          "/storage/emulated/0/Saajha Kare/" +
              widget.args.name +
              "/" +
              map[element],
          element,
          TranferDirection.SEND));
      tempFileCheck.remove(element);
      tempFile.remove(element);
    });

    var keys = tempFile.keys;
    for (final data in keys) {
      if (map.containsKey(data)) {
        {
          await tempFile[data].rename("/storage/emulated/0/Saajha Kare/" +
              widget.args.name +
              "/" +
              map[data]);
          tempFileCheck[data] = true;
        }
      }
    }
  }

  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void acceptConnection() async {
    var directory = Directory("/storage/emulated/0/Saajha Kare/");
    if (!await directory.exists()) {
      await directory.create();
    }
    var directoryx =
        Directory("/storage/emulated/0/Saajha Kare/" + widget.args.name);
    if (!await directoryx.exists()) {
      await directoryx.create();
    }

    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    Nearby().acceptConnection(
      widget.args.id,
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

            map[payloadId] = fileName;
          }
        } else if (payload.type == PayloadType.FILE) {
          tempFile[payload.id] = File(payload.filePath);
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) async {
        String name = map[payloadTransferUpdate.id];
        // print(map);
        // print(payloadTransferUpdate.id);
        if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRRESS) {
          transferinSeconds =
              payloadTransferUpdate.bytesTransferred - transferData;
          transferData += transferinSeconds;
          currentSpeed += transferinSeconds;

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

          if (map.containsKey(payloadTransferUpdate.id)) {
            String name = map[payloadTransferUpdate.id];
            this.setState(() {
              incomingFiles[name] = 1;
            });
          } else {
            map[payloadTransferUpdate.id] = "";
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final check = Provider.of<CheckConnectionStatus>(context);

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    this.setState(() {
      this.incomingFiles.removeWhere((key, value) => key == null);
    });

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Text(
                "Are You Sure ? It will cancel the transfer...",
                style: TextStyle(fontSize: 20),
                softWrap: true,
              ),
              actions: [
                FlatButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text("Continue Sending")),
                FlatButton(
                    onPressed: () async {
                      await Nearby().stopAllEndpoints();
                      Navigator.of(context).pushReplacementNamed("home");
                    },
                    child: Text("Go Back"))
              ],
            );
          },
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: Container(
          height: 80,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (check.connected)
                    RaisedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Send File/s"),
                        color: Colors.orange[100],
                        onPressed: () async {
                          List<File> files = await FilePicker.getMultiFile();
                          int i = 0;
                          if (files == null) return;

                          while (i != files.length) {
                            int payloadId = await Nearby()
                                .sendFilePayload(widget.args.id, files[i].path);

                            String name;
                            name = files[i].path.split('/').last;
                            if (incomingFiles.containsKey(name)) {
                              name += "[1]";
                            }
                            map[payloadId] = name;
                            sharedFiles.add(SharingFiles(name, files[i].path,
                                payloadId, TranferDirection.SEND));
                            this.setState(() {
                              incomingFiles[name] = 0;
                              mapColor[name] = colorReceived;
                            });

                            await Nearby().sendBytesPayload(
                                widget.args.id,
                                Uint8List.fromList(
                                    "$payloadId:$name".codeUnits));
                            i += 1;
                          }
                        }),
                  RaisedButton.icon(
                    icon: Icon(Icons.cancel),
                    onPressed: () async {
                      await Nearby().stopAllEndpoints();
                      Navigator.of(context).pushReplacementNamed('home');
                    },
                    label: Text(
                      "Finish",
                    ),
                    color: Colors.green[100],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 150.0,
              pinned: true, //change si
              automaticallyImplyLeading: false,
              title: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/iconAppBar.png",
                    scale: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.18,
                  ),
                  Text("SAAJHA KARE"),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.info,
                        color: Colors.indigo,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              content: Column(
                                children: [
                                  Text(
                                    "By Default all the downloads are Stored in Saajha Kare.",
                                    softWrap: true,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "More customisation will be available in future updates...")
                                ],
                              ),
                            );
                          },
                        );
                      })
                ],
              )),
              flexibleSpace: Container(
                child: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.all(statusBarHeight),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 60,
                          ),
                          Text(
                            check.connected
                                ? "Connected with ${widget.args.name}"
                                : "${widget.args.name} has left",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transfer Speed : " +
                                    currentSpeedData.toStringAsFixed(2) +
                                    "MBps",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Files : " + incomingFiles.length.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        gradient: check.connected
                            ? LinearGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.white,
                                  Color(0xFFB4F6C1)
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.green,
                                  Colors.white,
                                  Colors.orange
                                ],
                              )),
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
                var data = sharedFiles.firstWhere(
                    (element) => element.fileName == key,
                    orElse: () => null);
                ;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: value == 1
                        ? () {
                            OpenFile.open(data.path);
                          }
                        : () {},
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
                  ),
                );
              }, childCount: incomingFiles.length),
            ),
            SliverFillRemaining(
              child: Text(""),
            )
          ],
        ),
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
