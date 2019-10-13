import 'package:flutter/material.dart';
import 'package:findall/view/Home/Home.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown,DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new Main());
  });
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'findall',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primaryColor: Colors.black,
          primaryIconTheme: IconThemeData(color: Colors.black),
          primaryTextTheme: TextTheme(
              title: TextStyle(
                  color: Colors.black,
                  fontFamily:"Raleway"
              )
          ),
          textTheme: TextTheme(
              title: TextStyle(
                  color: Colors.black
              )
          )
      ),
      home: new Home(),

    );

  }
}
