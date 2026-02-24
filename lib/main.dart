import 'package:flutter/material.dart';
import 'package:anft_app/activity/home.dart';
import 'package:anft_app/activity/loading.dart';
import 'package:anft_app/activity/LoginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo, // General theme color
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo, // AppBar background color
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // AppBar title color
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // AppBar icons color
          ),
        ),
      ),
      routes: {
        "/": (context) => const Loading(),
        "/home": (context) => const Home(),
        "/login": (context) => const LoginPage(),
      },
    );
  }
}
