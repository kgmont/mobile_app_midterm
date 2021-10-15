import 'package:flutter/material.dart';
import 'authentication.dart';
import 'home.dart';
import 'login.dart';

class AppDriver extends StatelessWidget {
  AppDriver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Authentication().userAuthorized() == null ? const Login() : Home();
  }
}