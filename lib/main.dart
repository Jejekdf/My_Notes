import 'package:flutter/material.dart';
import 'screen/Splash_Screen.dart';
import 'screen/LoginPage_Screen.dart';
import 'screen/HomePage_Screen.dart';
import 'screen/add_note_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.black),
      ),

      
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
        '/add': (context) => AddNotePage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
