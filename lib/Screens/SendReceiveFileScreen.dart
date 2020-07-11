import "package:flutter/material.dart";
import "package:nearby_connections/nearby_connections.dart";
import "dart:io";

class SendReceiveFileScreen extends StatefulWidget {
  final args;

  const SendReceiveFileScreen(this.args);

  @override
  _SendReceiveFileScreenState createState() => _SendReceiveFileScreenState();
}

class _SendReceiveFileScreenState extends State<SendReceiveFileScreen> {
  Map<String, double> incomingFiles = {};
  File tempFile; //reference to the file currently being transferred
  Map<int, String> map = Map();
  @override
  void initState() {
    super.initState();
    acceptConnection();
  }

  void acceptConnection() async {
    Nearby().acceptConnection(
      widget.args,
      onPayLoadRecieved: (endid, payload) async {
        if (payload.type == PayloadType.BYTES) {
          String str = String.fromCharCodes(payload.bytes);
          print(endid + ": " + str);

          if (str.contains(':')) {
            // used for file payload as file payload is mapped as
            // payloadId:filename

            int payloadId = int.parse(str.split(':')[0]);
            String fileName = (str.split(':')[1]);
            this.setState(() {
              incomingFiles["$fileName"] = 0;
            });
            if (map.containsKey(payloadId)) {
              print("hi" + map.toString());
              if (await tempFile.exists()) {
                tempFile.rename(tempFile.parent.path + "/" + fileName);
              } else {
                print("File doesnt exist");
              }
            } else {
              //add to map if not already
              map[payloadId] = fileName;
            }
          }
        } else if (payload.type == PayloadType.FILE) {
          print(endid + ": File transfer started");
          tempFile = File(payload.filePath);
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
        if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRRESS) {
          String name = map[payloadTransferUpdate.id];

          this.setState(() {
            incomingFiles[name] = (payloadTransferUpdate.bytesTransferred /
                    payloadTransferUpdate.totalBytes) *
                100;
          });
        } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
          print("failed");
          print(endid + ": FAILED to transfer file");
        } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
          print("success, total bytes = ${payloadTransferUpdate.totalBytes}");

          if (map.containsKey(payloadTransferUpdate.id)) {
            //rename the file now
            String name = map[payloadTransferUpdate.id];
            tempFile.rename(tempFile.parent.path + "/" + name);
          } else {
            //bytes not received till yet
            map[payloadTransferUpdate.id] = "";
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 500,
            child: ListView.builder(
              itemBuilder: (_, i) {
                String key = incomingFiles.keys.elementAt(i);
                if (key == null) return Text("no data");
                double value = incomingFiles.values.elementAt(i);
                return Text(key.substring(0, 5) + value.toString());
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
                int payloadId =
                    await Nearby().sendFilePayload(cId, files[i].path);
                showSnackbar("Sending file to $cId");
                Nearby().sendBytesPayload(
                    cId,
                    Uint8List.fromList(
                        "$payloadId:${files[i].path.split('/').last}"
                            .codeUnits));
                i += 1;
              }
            },
          ),
        ],
      ),
    );
  }
}
