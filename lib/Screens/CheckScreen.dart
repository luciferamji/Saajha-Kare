import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import "package:auto_size_text/auto_size_text.dart";

class Cond extends StatefulWidget {
  @override
  _CondState createState() => _CondState();
}

class _CondState extends State<Cond> {
  SharedPreferences prefs;
  @override
  void initState() {
    checkAndForward();
    super.initState();
  }

  void checkAndForward() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("first")) {
      if (!prefs.getBool("first")) {
        Navigator.of(context).pushReplacementNamed('home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PageViewModel(
          pageColor: Colors.yellow[50],
          bubbleBackgroundColor: Colors.deepOrange[400],
          bubble: Image.asset('assets/images/iconAppBar.png'),
          body: Column(
            children: [
              AutoSizeText(
                "SAAJHA KARE",
                maxLines: 1,
                style: TextStyle(color: Colors.indigo[900]),
              ),
              SizedBox(
                height: 20,
              ),
              AutoSizeText(
                "A Truly Indian File Sharing App",
                maxLines: 1,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          title: Column(
            children: [
              AutoSizeText(
                'WELCOME',
                maxLines: 1,
                style: TextStyle(color: Colors.indigo[900]),
              ),
              SizedBox(
                height: 5,
              ),
              AutoSizeText(
                "Thank You For Downloading",
                maxLines: 1,
                style: TextStyle(fontSize: 15, color: Colors.indigo),
              )
            ],
          ),
          bodyTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          mainImage: Image.asset(
            'assets/images/intro1.png',
            height: 285.0,
            width: 285.0,
            alignment: Alignment.center,
          )),
      PageViewModel(
        pageColor: Colors.white,
        bubbleBackgroundColor: Colors.blue[900],
        bubble: Image.asset('assets/images/iconAppBar.png'),
        body: Column(
          children: [
            AutoSizeText(
              'Its a long journey, which will come to a halt without you. Lets do it together.',
              maxLines: 3,
            ),
            SizedBox(
              height: 10,
            ),
            AutoSizeText(
              'Keep Supporting us.',
              maxLines: 1,
            ),
          ],
        ),
        title: AutoSizeText(
          'WE NEED SUPPORT',
          maxLines: 1,
        ),
        mainImage: Image.asset(
          'assets/images/ashok_chakra.png',
          height: MediaQuery.of(context).size.width,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        titleTextStyle:
            TextStyle(fontFamily: 'MyFont', fontSize: 35, color: Colors.indigo),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.indigo),
      ),
      PageViewModel(
        pageColor: Colors.green[400],
        bubbleBackgroundColor: Colors.green[900],
        bubble: Image.asset('assets/images/iconAppBar.png'),
        body: Column(
          children: [
            AutoSizeText(
              "We need your location and storage permission (Forced by android 😔).",
              maxLines: 2,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            AutoSizeText(
              "Please allow.",
              maxLines: 1,
            ),
          ],
        ),
        title: AutoSizeText(
          'Just One More Thing!!!',
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        mainImage: Image.asset(
          'assets/images/Icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
    ];
    return IntroViewsFlutter(
      pages,
      showBackButton: true,
      onTapDoneButton: () async {
        prefs.setBool("first", false);
        prefs.setString("name", (Random().nextInt(500) + 10000).toString());
        Navigator.of(context).pushReplacementNamed('home');
      },
      pageButtonTextStyles: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      ),
    );
  }
}
