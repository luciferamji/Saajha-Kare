enum TranferDirection { SEND, RECIEVED }

class SharingFiles {
  final String fileName, path;
  final int payloadId;
  final TranferDirection data;

  SharingFiles(this.fileName, this.path, this.payloadId, this.data);
}
