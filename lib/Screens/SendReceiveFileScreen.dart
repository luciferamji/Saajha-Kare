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
  Map<int, String> map = Map();
  @override
  void initState() {
    super.initState();
    acceptConnection();
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
          this.setState(() {
            incomingFiles[name] = (payloadTransferUpdate.bytesTransferred /
                payloadTransferUpdate.totalBytes);
          });
        } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
          print("failed");
          print(endid + ": FAILED to transfer file");
        } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
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

  Scaffold check2() {
    Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 200,
        title: Text("FILE Tansfer"),
        automaticallyImplyLeading: false,
      ),
    );
  }

  Scaffold check() {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true, //change si
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              child: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.white, Color(0xFFB4F6C1)],
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
          SliverFillRemaining(
            child: Container(
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 2.1,
                colors: [Color(0xFFCD5A0), Colors.white, Color(0xFFB4F6C1)],
              )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 500,
                    child: ListView.builder(
                      itemBuilder: (_, i) {
                        String key = incomingFiles.keys.elementAt(i);
                        if (key == null) return SizedBox.shrink();
                        double value = incomingFiles.values.elementAt(i);
                        print(value);
                        return Card(
                          margin:
                              EdgeInsets.only(bottom: 15, right: 5, left: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadowColor: mapColor[key][0],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
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
                            ],
                          ),
                        );
                      },
                      itemCount: incomingFiles.length,
                    ),
                  ),
                  RaisedButton(
                    child: Text("Send File Payload"),
                    onPressed: () async {
                      List<File> files = await FilePicker.getMultiFile();
                      int i = 0;
                      if (files == null) return;
                      while (i != files.length) {
                        int payloadId = await Nearby()
                            .sendFilePayload(widget.args, files[i].path);

                        map[payloadId] = files[i].path.split('/').last;

                        mapColor[files[i].path.split('/').last] = colorReceived;

                        Nearby().sendBytesPayload(
                            widget.args,
                            Uint8List.fromList(
                                "$payloadId:${files[i].path.split('/').last}"
                                    .codeUnits));
                        i += 1;
                      }
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return check();
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
