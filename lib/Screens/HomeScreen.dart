import "package:flutter/material.dart";
import 'package:pimp_my_button/pimp_my_button.dart';
import "../widgets/MyParticle.dart";
import "dart:async";

Color mainBGColor = Color(0xFFff8000);
Color lightOrangeColor = Color(0xFFFFB266);
Color purpleColor = Colors.white;
Color green = Color(0xFF4CA64C);
Color orange = Color(0xFFE97A4D);

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double height1 = height - padding.top - padding.bottom;
    return Scaffold(
        body: Column(
      children: <Widget>[
        CustomPaint(
          painter: MyCustomPainter(),
          child: Container(
            height: height1 * 0.75,
          ),
        ),
        SizedBox(
          height: height1 * 0.05,
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
                              print(
                                  "Yeah, this line is printed after 3 seconds");
                              Navigator.of(context).pushNamed("send");
                            });
                          },
                          child: Icon(
                            Icons.arrow_upward,
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
                              print(
                                  "Yeah, this line is printed after 3 seconds");
                              Navigator.of(context).pushNamed("receive");
                            });
                          },
                          child: Icon(
                            Icons.arrow_downward,
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
                )
              ],
            )
          ],
        ),
      ],
    ));
  }
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    Path mainBGPath = Path();
    mainBGPath.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    paint.color = mainBGColor;
    canvas.drawPath(mainBGPath, paint);

    Path purplePath = Path();
    purplePath.lineTo(size.width * .45, 0);
    purplePath.quadraticBezierTo(
        size.width * .25, size.height * .3, 0, size.height * 0.55);
    purplePath.close();
    paint.color = purpleColor;
    canvas.drawPath(purplePath, paint);

    Path redPath = Path();
    redPath.moveTo(size.width * 0.9, 0.0);
    redPath.quadraticBezierTo(
        size.width * .5, size.height * 0.1, 0, size.height * 0.85);
    redPath.lineTo(0, size.height);
    redPath.lineTo(size.width * 0.25, size.height);
    redPath.quadraticBezierTo(
        size.width * .5, size.height * 0.4, size.width, size.height * 0.4);
    redPath.lineTo(size.width, 0.0);
    redPath.close();
    paint.color = lightOrangeColor;
    canvas.drawPath(redPath, paint);

    Path orangePath = Path();
    orangePath.moveTo(0, size.height * 0.55);
    orangePath.quadraticBezierTo(
        size.width * .8, size.height * 0.85, size.width * .6, size.height);
    orangePath.lineTo(0, size.height);
    orangePath.close();
    paint.color = Color(0xff99CC99);
    canvas.drawPath(orangePath, paint);

    Path trianglePath = Path();
    trianglePath.lineTo(size.width * .25, 0);
    trianglePath.lineTo(0, size.height * .25);
    trianglePath.close();
    paint.color = green;
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
