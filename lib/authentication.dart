import 'driver.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app_midterm/home.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class Authentication {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _authorize = FirebaseAuth.instance;
  
  String _verifyId = '';

  authorize(){
    return _authorize;
  }

  userAuthorized(){
    return _authorize.currentUser;
  }

  user(){
    User? user =_authorize.currentUser;
    String id = user!.uid;
    return id;
  }

  void emailWithPasswordSignIn(_userEmail, _userPassword, context) async{
    await Firebase.initializeApp();
    try{
      UserCredential uid = await _authorize.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword);
      Navigator.push(context,MaterialPageRoute(builder:  (context) => AppDriver()));
    }on FirebaseAuthException catch(e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Password is incorrect")));
      }else if(e.code =='user-not-found')    {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("User was not found")));
      }
    }catch (e){
      print(e);
    }
  }

  void emailOnlySignIn(_userEmail) async{
    await _authorize.sendSignInLinkToEmail(
      email: _userEmail,
      actionCodeSettings: ActionCodeSettings(
        androidPackageName: "com.example.mobile_app_midterm",
        androidMinimumVersion: "16",
        androidInstallApp: true,
        handleCodeInApp: true,
        iOSBundleId: "com.example.mobile_app_midterm",
        url: "https://mobile_app_midterm-2af60.firebaseapp.com",
      ),
    );
  }

  linkHandler(Uri link, _userEmail, context) async {
    if (link != null) {
      final user = (await _authorize.signInWithEmailLink(
        emailLink: link.toString(),
        email: _userEmail,
      )).user;
      if (user != null) {
        return true;
      } else {
        return false;
      }
    }else {
      return false;
    }
  }

  Future<void> phoneNumberSignIn(_phoneNum, context) async{
    PhoneVerificationCompleted verificationSuccessful =
        (PhoneAuthCredential phoneAuthorizationCred) async {
      await _authorize.signInWithCredential(phoneAuthorizationCred); };

    PhoneVerificationFailed failedVerification =
        (FirebaseAuthException authException) {
      print("Failed: $authException");
    };

    PhoneCodeSent phoneCodeSent =
        (String verifyId, [int? resendToken]) async {
      _verifyId = verifyId;
    };

    await _authorize.verifyPhoneNumber(
      phoneNumber: _phoneNum,
      verificationCompleted: verificationSuccessful,
      timeout: const Duration(seconds: 30),
      verificationFailed: failedVerification,
      codeSent: phoneCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void signInWithPhone(_smsCode, context) async{
    try {
      final AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: _verifyId,
        smsCode: _smsCode,
      );
      print(authCredential);
      final User? user = (await _authorize.signInWithCredential(authCredential)).user;
      Navigator.push(context,MaterialPageRoute(builder:  (context) => Home()));
    } catch (e) {
      print(e);
    }
    Navigator.push(context,MaterialPageRoute(builder:  (context) => Home()));
  }

  void signInWithGoogle(context) async{
    final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuthorize = await googleAccount!.authentication;

    final googleCredential = GoogleAuthProvider.credential(
      idToken: googleAuthorize.idToken,
      accessToken: googleAuthorize.accessToken,
    );

    await FirebaseAuth.instance.signInWithCredential(googleCredential);
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('user')
        .where('first_name', isEqualTo: googleAccount.displayName)
        .limit(1)
        .get();
    final List <DocumentSnapshot> docs = result.docs;
    if (docs.isEmpty) {
      try {
        _db
            .collection("user")
            .doc()
            .set({
          "first_name": googleAccount.displayName,
          "last_name": '',
          "role": 'customer',
          "url": '',
          "uid" : googleCredential,
          "registration_deadline": DateTime.now(),
        })
            .then((value) => null)
            .onError((error, stackTrace) => null);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (con) => AppDriver()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error")));
      } catch (e) {
        print(e);
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (con) => AppDriver()));
    }
  }

  void signInWithFacebook(context) async{
    final LoginResult facebookUser = await FacebookAuth.instance.login();
    final AuthCredential facebookCred =
    FacebookAuthProvider.credential(facebookUser.accessToken!.token);

    final userCredential =
    await _authorize.signInWithCredential(facebookCred);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }

  void anonSignIn(context) async{
    _authorize.signInAnonymously().then((result) {
      final User? user = result.user;
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }

  void signOutofAccount(BuildContext context) async {
    return showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Log Out"),
            content: Text("Confirm Logout?"),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await _authorize.signOut();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      const SnackBar(content: Text('Logged Out')));
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (con) => AppDriver()));
                  ScaffoldMessenger.of(context).clearSnackBars();
                },
                child: Text("Yes"),
              ),
            ],
          );
        });
  }
}