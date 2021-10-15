import 'authentication.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';


class _SignInWithPhoneState extends State<SignInWithPhone> {
  final SmsAutoFill _autoFill = SmsAutoFill();
  late TextEditingController _phoneController, _smsController;

  void initState(){
    super.initState();
    _phoneController = TextEditingController();
    _smsController = TextEditingController();
  }

  void dispose(){
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  String _phoneNumber = '';
  String _sms = '';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In Using Phone Number"),
      ),
      backgroundColor: Colors.blue,
      body: Padding(padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Enter Phone Number'),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text("Verify Phone Number"),
                  onPressed: () async {
                    Authentication().phoneNumberSignIn(_phoneController.text, context);
                  },
                ),
              ),
              TextFormField(
                controller: _smsController,
                decoration: const InputDecoration(labelText: 'Enter Verification Code'),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () async {
                      Authentication().signInWithPhone(_smsController.text, context);
                    },
                    child: Text("Sign In")),
              ),
            ],
          ),
      ),
    );
  }
}

class SignInWithPhone extends StatefulWidget {
  const SignInWithPhone({Key? key}) : super(key: key);

  @override
  _SignInWithPhoneState createState() => _SignInWithPhoneState();
}