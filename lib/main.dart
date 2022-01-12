import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comic_bin/routes/home.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comic Bin',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 36, color: Colors.black54, fontWeight: FontWeight.bold),
          headline2: TextStyle(fontSize: 26, color: Colors.black54, fontWeight: FontWeight.bold),
          bodyText1: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.black.withOpacity(0.05),
        ),
      ),
      darkTheme: ThemeData(
        dividerColor: Colors.black12,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
          headline2: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
          bodyText1: TextStyle(fontSize: 16, color: Colors.white54),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.white.withOpacity(0.1),
        ),
        //colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.white),
      ),
      themeMode: ThemeMode.system,
      home: MyHomePage(),
    );
  }
}
