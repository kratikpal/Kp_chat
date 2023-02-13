import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kp_chat/chat_screen.dart';
import 'package:kp_chat/image_screen.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int screenIndex = 0;
  final screens = [
    const MyChat(),
    const MyImageScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: SafeArea(
        child: Scaffold(
          body: screens[screenIndex],
          bottomNavigationBar: CurvedNavigationBar(
            color: Colors.deepOrange,
            backgroundColor: Colors.transparent,
            height: 60,
            onTap: (index) {
              setState(() => screenIndex = index);
            },
            items: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.image, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
