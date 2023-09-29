import 'package:flutter/material.dart';
import 'package:samplevb/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          color: Colors.white, //<-- SEE HERE
        ),
      ),
      home: HomePage(),
    );
  }
}
