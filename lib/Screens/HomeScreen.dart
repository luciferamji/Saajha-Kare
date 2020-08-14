// flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
import "package:flutter/material.dart";
import 'package:pimp_my_button/pimp_my_button.dart';
import "../widgets/MyParticle.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "dart:async";
import "package:nearby_connections/nearby_connections.dart";

Color mainBGColor = Color(0xFFff8000);
Color lightOrangeColor = Color(0xFFFFB266);
Color purpleColor = Colors.white;
Color green = Color(0xFF4CA64C);
Color orange = Color(0xFFE97A4D);

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final myController = TextEditingController();
  SharedPreferences prefs;
  String name;
  @override
  void initState() {
    check();

    super.initState();
  }

  void check() async {
    prefs = await SharedPreferences.getInstance();
    name = myController.text = prefs.getString("name");
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double height1 = height - padding.top - padding.bottom;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: MyCustomPainter(),
              child: Container(
                height: height1 * 0.5,
                child: Container(
                  margin: EdgeInsets.all(height1 * 0.01),
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/images/Icon.png",
                    scale: 1.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height1 * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: myController,
                onEditingComplete: () async {
                  name = myController.text;
                  prefs.setString("name", myController.text);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                decoration: InputDecoration(
                  labelText: "Edit Your Name",
                  suffixIcon: Icon(Icons.edit),
                ),
              ),
            ),
            SizedBox(
              height: height1 * 0.15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    PimpedButton(
                      particle: MyParticle(Colors.orange),
                      pimpedWidgetBuilder: (context, controller) {
                        return Container(
                          height: 100,
                          width: 100,
                          child: FittedBox(
                            child: FloatingActionButton(
                              backgroundColor: Colors.orange,
                              heroTag: null,
                              onPressed: () {
                                controller.forward(from: 0.0);
                                Timer(Duration(milliseconds: 500), () {
                                  Navigator.of(context)
                                      .pushNamed("send", arguments: name);
                                });
                              },
                              child: Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    PimpedButton(
                      particle: MyParticle(Colors.green),
                      pimpedWidgetBuilder: (context, controller) {
                        return Container(
                          height: 100,
                          width: 100,
                          child: FittedBox(
                            child: FloatingActionButton(
                              backgroundColor: Colors.green,
                              heroTag: null,
                              onPressed: () {
                                controller.forward(from: 0.0);
                                controller.forward(from: 0.0);
                                Timer(Duration(milliseconds: 500), () {
                                  Navigator.of(context)
                                      .pushNamed("receive", arguments: name);
                                });
                              },
                              child: Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Receive",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    Path mainBGPath = Path();
    mainBGPath.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    paint.color = Colors.green;
    canvas.drawPath(mainBGPath, paint);

    Path purplePath = Path();
    purplePath.lineTo(size.width * .45, 0);
    purplePath.quadraticBezierTo(
        size.width * .25, size.height * .3, 0, size.height * 0.55);
    purplePath.close();
    paint.color = Colors.white;
    canvas.drawPath(purplePath, paint);

    Path redPath = Path();
    redPath.moveTo(size.width * 0.9, 0.0);
    redPath.quadraticBezierTo(
        size.width * .5, size.height * 0.1, 0, size.height * 0.85);
    redPath.lineTo(0, size.height);
    redPath.lineTo(size.width * 0.25, size.height);
    redPath.quadraticBezierTo(
        size.width * .5, size.height, size.width, size.height);
    redPath.lineTo(size.width, 0.0);
    redPath.close();
    paint.color = Colors.white;
    canvas.drawPath(redPath, paint);
    paint.color = Color(0xff99CC99);

    Path trianglePath = Path();
    trianglePath.lineTo(size.width * .25, 0);
    trianglePath.lineTo(0, size.height * .25);
    trianglePath.close();
    paint.color = mainBGColor;
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
