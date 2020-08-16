import "package:flutter/material.dart";

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.white, Color(0xFFB4F6C1)],
          ),
        ),
        height: preferredSize.height,
        child: Row(
          children: [
            SizedBox(width: 20),
            Image.asset(
              "assets/images/iconAppBar.png",
              scale: 2,
            ),
            SizedBox(width: 20),
            Text("SAAJHA KARE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            SizedBox(
              width: 20,
            ),
          ],
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}
