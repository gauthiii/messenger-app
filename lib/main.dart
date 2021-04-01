import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jc_messenger/pages/sign_in.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SignIn(),
    );
  }
}
