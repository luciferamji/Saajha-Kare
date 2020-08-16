import 'dart:async';

import "package:flutter/material.dart";

class TImer5sec extends StatefulWidget {
  @override
  _TImer5secState createState() => _TImer5secState();
}

class _TImer5secState extends State<TImer5sec> {
  var timer;
  int sec = 3;
  @override
  void initState() {
    timer = new Timer.periodic(new Duration(seconds: 1), (time) {
      this.setState(() {
        if (sec <= 0) sec = 0;
        sec--;
      });
    });
    super.initState();
  }

  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "  " + sec.toString(),
      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
    );
  }
}
