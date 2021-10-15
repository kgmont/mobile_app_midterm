import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'driver.dart';
import 'package:firebase_auth/firebase_auth.dart';


class _RegistrationState extends State<Register> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  File? _picture;

  late TextEditingController _emailController,
      _reemailController,
      _passwordController,
      _repasswordController,
      _firstnameController,
      _lastnameController,
      _phonenumberController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _reemailController = TextEditingController();
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _phonenumberController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _reemailController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phonenumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Form(
            key: _formKey,
            child: Column(children: [
              const SizedBox(height: 3),
              TextFormField(
                autocorrect: false,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Email Address';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter email'),
              ),
              const SizedBox(height: 7),
              TextFormField(
                autocorrect: false,
                controller: _reemailController,
                validator: (value) {
                  if (value == null || value != _reemailController.text) {
                    return 'Email addresses don\'t match!';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Please Re-Enter Email Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter email address again'),
              ),
              const SizedBox(height: 7),
              TextFormField(
                autocorrect: false,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password must have a value';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter password'),
              ),
              const SizedBox(height: 7),
              TextFormField(
                autocorrect: false,
                controller: _repasswordController,
                validator: (value) {
                  if (value == null || value != _passwordController.text) {
                    return 'Passwords don\'t match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Please Verify Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter password again'),
              ),
              const SizedBox(height: 7),
              TextFormField(
                autocorrect: false,
                controller: _firstnameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Passwords don\'t match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter your first name'),
              ),
              const SizedBox(height: 7),
              TextFormField(
                autocorrect: false,
                controller: _lastnameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Last name must have a value';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter last name'),
              ),
              const SizedBox(height: 7),
              TextFormField(
                autocorrect: false,
                controller: _phonenumberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number must have a value';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter phone number'),
              ),
              OutlinedButton(
                  onPressed:(){
                    image(true);
                  },
                  child:const Text("Upload Photo")),
              const SizedBox(height: 3),
              OutlinedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Loading...')));
                    setState(() {
                      register();
                    });
                  }
                },
                child: const Text('Submit'),
              )
            ])));
  }

  Future<void> register() async {
    try {
      var authenticate = Authentication().authorize();
      UserCredential userCredential =
      await authenticate.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      _db
          .collection("user")
          .doc(userCredential.user!.uid)
          .set({
        "first_name": _firstnameController.text,
        "last_name": _lastnameController.text,
        "phone": _phonenumberController.text,
        "role": "customer",
        "uid" : userCredential.user!.uid,
        "register_date": DateTime.now()
      })
          .then((value) => null)
          .onError((error, stackTrace) => null);
      Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
      // });

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error")));
    } catch (e) {
      print(e);
    }

    setState(() {});
  }

  Future image(bool gallery) async {
    ImagePicker imagePicker = ImagePicker();
    XFile image;
    if(gallery) {
      image = (await imagePicker.pickImage(
          source: ImageSource.gallery,imageQuality: 40))!;
    }
    else{
      image = (await imagePicker.pickImage(
          source: ImageSource.camera,imageQuality: 40))!;
    }
    setState(() {
      _picture = File(image.path);
    });
  }

  Future<void> uploadPicture() async {
    String id = Authentication().user();

    var storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child(id)
        .putFile(_picture!);
    if (snapshot.state == TaskState.success) {
      final String downloadUrl =
      await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("user")
          .doc(id)
          .update({"url": downloadUrl});
    }
    Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}