import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void startApp() async {
    // Check login state
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rollNo = prefs.getString('roll_no');
    final String? userPassword = prefs.getString('user_password');

    // Delay for loading animation, then navigate based on login status
    Future.delayed(const Duration(seconds: 2), () {
      if (rollNo != null && userPassword != null) {
        // Navigate to home if logged in
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Navigate to login page if not logged in
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void initState() {
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo[800],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                "assets/images/anft_dept-removebg-preview.png",
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "ANFT DIARY",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "ISLAMIC UNIVERSITY",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: const Color.fromARGB(255, 18, 150, 221),
              ),
            ),
            const SizedBox(height: 40),
            const SpinKitWave(
              color: Color.fromARGB(255, 18, 150, 221),
              size: 50.0,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
