import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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
              Text(
                "SAAJHA KARE",
                style: TextStyle(color: Colors.indigo[900]),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "A Truly Indian File Sharing App",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          title: Column(
            children: [
              Text(
                'WELCOME',
                style: TextStyle(color: Colors.indigo[900]),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Thank You For Downloading",
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
            Text(
              'Its a long journey, which will come to a halt without you. Lets do it together.',
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Keep Supporting us.',
            ),
          ],
        ),
        title: Text('WE NEED SUPPORT'),
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
            Text(
              "We need your location and storage permission (Forced by android 😔).",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text("Please allow."),
          ],
        ),
        title: Text('Just One More Thing!!'),
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
      showBackButton: false,
      onTapDoneButton: () async {
        prefs.setBool("first", false);
        prefs.setString("name", (Random().nextInt(500) + 10000).toString());
        Navigator.of(context).pushReplacementNamed('home');
      },
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    );
  }
}
