import 'package:flutter/material.dart';

import 'board_page.dart';

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
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          color: Colors.blueAccent, //<-- SEE HERE
        ),
      ),
      home:  BoardPage(),
    );
  }
}

