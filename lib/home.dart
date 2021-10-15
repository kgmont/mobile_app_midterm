import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ViewUserState extends State<ViewUser>{
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("User Home"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              child: Text( widget.name,
                  style: const TextStyle(
                      fontSize: 35.0)),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: widget.pic.length > 1 ?
              Image.network(widget.pic, height: 150, width: 150,) :
              Image.asset('assets/defaultUserPicture.png', height: 150, width: 150,),
            ),
            Container(
              child: Text("About: " + widget.about,
                  style: const TextStyle(
                      fontSize: 10.0)),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: Text("Age: " + widget.age,
                  style: const TextStyle(
                      fontSize: 10.0)),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: Text("Town: " + widget.town,
                  style: const TextStyle(
                      fontSize: 10.0)),
              padding: EdgeInsets.all(20),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Authentication().signOutofAccount(context);
        },
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),
    );

  }

}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _pic;
  String id = Authentication().user();
  final FirebaseFirestore fb = FirebaseFirestore.instance;
  String name = '';
  String picture = '';
  String about = '';
  String age = '';
  String town ='';
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Home"),
          actions: <Widget>[
            FlatButton(
                onPressed: (){
                  chooseUserImage(true);
                },
                child: const Icon(Icons.add)
            )
          ]
      ),

      body:
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Container(
                height: 50,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child:
                        document['url'].length > 1 ?
                        Image.network(document['url'], height: 35, width: 35,) :
                        Image.asset('assets/defaultUserPicture.png', height: 35, width: 35,),
                      ),
                      Container(
                        child: Text( document['first_name']),
                        padding: EdgeInsets.all(7),
                      ),
                      Container(
                        child: Text( document['register_date']),
                        padding: EdgeInsets.all(2),
                      ),

                      Container(
                        child: RaisedButton.icon(
                            onPressed: () async {
                              setState(() {
                                name = document['first_name'];
                                age = document['age'];
                                about = document['about'];
                                town = document['town'];
                                picture = document['url'];
                              });
                              Navigator.push(
                                  context,MaterialPageRoute(builder: (context) =>
                                  ViewUser(age, picture, name, about, town,
                                  )));
                            },
                            icon: Icon(Icons.account_circle_outlined ) , label: Text('More Info')),
                      )
                    ]
                ),
                margin:EdgeInsets.all(5),
              );
            }).toList(),
          );
        },
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Authentication().signOutofAccount(context);
        },
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),
    );
  }

  Future chooseUserImage(bool gallery) async {
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
      _pic = File(image.path);
      imageUpload(_pic);
    });
  }

  Future<void> imageUpload(pic) async {
    User user = Authentication().userAuthorized();
    String id = user.uid;
    var store = FirebaseStorage.instance;
    TaskSnapshot snapshot = await store
        .ref()
        .child(id)
        .putFile(pic);
    if (snapshot.state == TaskState.success) {
      final String downloadUrl =
      await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("user")
          .doc(id)
          .update({"url": downloadUrl});
      setState(() {
      });
    }
  }
}

class ViewUser extends StatefulWidget{
  final String age, pic, name, about, town;
  ViewUser(this.age,this.pic,this.name,this.about,this.town);

  @override
  State<StatefulWidget> createState() { return new ViewUserState();}
}

