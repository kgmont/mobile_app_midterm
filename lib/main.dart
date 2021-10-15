import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:splashscreen/splashscreen.dart';
import 'driver.dart';


class SomeError extends StatelessWidget {
  const SomeError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
    );
  }
}

class _MainAppState extends State<App> {
  final Future<FirebaseApp> _initialize = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _initialize,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SomeError();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return SecondSplash();
            } else {
              return Container(color: Colors.blue);
            }
          },
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}


class SecondSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: AppDriver(),
      title: new Text('Midterm Application',textScaleFactor: 2,),
      image: new Image.asset('assets/mypicture.jpg',),
      loadingText: Text("Waiting..."),
      photoSize: 150.0,
      loaderColor: Colors.green,
      backgroundColor: Colors.blue,
    );
  }
}

class Waiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}