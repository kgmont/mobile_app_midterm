import 'main.dart';
import 'package:flutter/material.dart';
import 'driver.dart';
import 'authentication.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';


class _EmailOnlySignInState extends State<EmailOnly> with WidgetsBindingObserver{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  bool _succesful = false;

  void initState(){
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _emailController = TextEditingController();
  }

  void dispose(){
    _emailController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  String _emailInput = '';

  @override
  void appLifecycleStateChanged(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final PendingDynamicLinkData? data =
      await FirebaseDynamicLinks.instance.getInitialLink();
      if( data?.link != null ) {
        Authentication().linkHandler(data!.link, _emailInput, context);
      }
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData? dynamicLink) async {
            final Uri? deepLink = dynamicLink?.link;
            _succesful = Authentication().linkHandler(deepLink!, _emailInput, context);
          }, onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      });
      setState(() {
        _succesful;
        if(_succesful){
          Navigator.push(context,MaterialPageRoute(builder: (context) => AppDriver()));
        }else{
          Waiting();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: Text("Use a valid email to sign in"),
        ),
        backgroundColor: Colors.blue,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
              width: 400,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Value is empty';
                  }
                  return null;
                },
              )),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Authentication().emailOnlySignIn(_emailController.text);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        )
    );
  }
}

class EmailOnly extends StatefulWidget {
  EmailOnly({Key? key}) : super(key: key);

  @override
  _EmailOnlySignInState createState() => _EmailOnlySignInState();
}