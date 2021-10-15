import 'phone.dart';
import 'register.dart';
import 'email.dart';
import 'authentication.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _LoginState extends State<Login> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController, _passwordController, _phoneNumberController;

  get model => null;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool _waiting = false;
  String _userEmail = "";
  String _userPassword = "";
  String _userPhoneNum = "";

  @override
  Widget build(BuildContext context) {

    final emailInput = TextFormField(
      controller: _emailController,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter text';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: "Email",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Email'),
    );

    final inputPassword = TextFormField(
      controller: _passwordController,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        hintText: 'Enter Password',
        suffixIcon: Padding(
          padding: EdgeInsets.all(15), // add padding to adjust icon
          child: Icon(Icons.lock),
        ),
      ),
    );

    final submit = OutlinedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Processing')));
          _userEmail = _emailController.text;
          _userPassword = _passwordController.text;

          _emailController.clear();
          _passwordController.clear();

          setState(() {
            _waiting = true;
            Authentication().emailWithPasswordSignIn(_userEmail, _userPassword, context);
          });
        }
      },
      child: const Text('Submit'),
    );

    final registerButton = Container(
        width: 50.0,
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (con) => const Register()));
          },
          child: const Text('Register'),
    ));

    final justEmail = Container(
        width: 50.0,
        child: OutlinedButton(
          onPressed:(){
            Navigator.push(
                context,MaterialPageRoute(builder: (con) => EmailOnly()));
          }, child:Text("Sign In Using Email"),
    ));

    final google = Container(
      width: 50.0,
      child : OutlinedButton.icon(
        icon: Image.asset('assets/googleicon.png', height: 10, width: 10,),
        label: const Text("Sign in Using Google"),
        onPressed: (){
          Authentication().signInWithGoogle(context);
        } ));

    final facebook = Container(
        width: 50.0,
        child: OutlinedButton.icon(
        icon: Image.asset('assets/facebook.png', height: 10, width: 10,),
        label: const Text("Sign in Using Facebook"),
        onPressed: (){
          Authentication().signInWithFacebook(context);
        } ));

    final phone = Container(
        width: 50.0,
        child: OutlinedButton(
        onPressed:(){
          Navigator.push(
              context,MaterialPageRoute(builder: (con) => const SignInWithPhone()));},
        child: Text("Sign in with Phone Number"),
    ));

    final anon = Container(
      width: 50.0,
      child: OutlinedButton(
        onPressed: (){
          Authentication().anonSignIn(context);},
        child:Text("Sign in Anonymously"),
    ));

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  emailInput,
                  inputPassword,
                  submit,
                  justEmail,
                  phone,
                  google,
                  facebook,
                  anon,
                  registerButton,
                ],
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}
