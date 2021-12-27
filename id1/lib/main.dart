import 'package:flutter/material.dart';
import 'package:betterchat/pages/home_page.dart';
import 'package:betterchat/pages/video_page.dart';

void main() => runApp(
      MaterialApp(
        routes: {
          '/': (context) => HomePage(),
          "/video": (context) => VideoPage(),
        },
      ),
    );
