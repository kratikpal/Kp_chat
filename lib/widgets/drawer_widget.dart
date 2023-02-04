import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAppDrawer extends StatelessWidget {
  const MyAppDrawer({super.key});

  Future<void> _launchUrl(int value) async {
    if (value == 1) {
      await launchUrl(Uri.parse("https://github.com/kratikpal/Kp_chat"));
    } else {
      await launchUrl(Uri.parse(
          "https://github.com/kratikpal/Privacy-Policy/blob/main/privacy%20_policy.md"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(60),
        bottomRight: Radius.circular(60),
      ),
      child: Drawer(
        backgroundColor: Colors.white60,
        child: ListView(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          "assets/images/photo-1520250497591-112f2f40a3f4.avif"),
                      fit: BoxFit.cover),
                ),
                child: Column(
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: CircleAvatar(
                        backgroundImage: AssetImage("assets/1024.png"),
                        radius: 30,
                      ),
                    ),
                    Text(
                      "Kratikpal",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "kratikpal@gmail.com",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  "assets/images/Github_logo_PNG1.png",
                  fit: BoxFit.fill,
                ),
              ),
              title: const Text("GitHub"),
              onTap: () {
                Navigator.pop(context);
                _launchUrl(1);
              },
            ),
            const Divider(),
            ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                  color: Colors.black,
                ),
                title: const Text("Privacy Policy"),
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(2);
                })
          ],
        ),
      ),
    );
  }
}
