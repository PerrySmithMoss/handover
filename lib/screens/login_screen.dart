import 'package:flutter/material.dart';
import 'package:handover_app/screens/signup_screen.dart';
import 'package:handover_app/services/auth_services.dart';

class LoginScreen extends StatefulWidget {

  static final String id = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  String _email, _password;


  // Logging the user in with Firebase
  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      AuthService.login(_email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Handover",
              style: TextStyle(fontSize: 50),
              ),
            Form(key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (input) => ! input.contains("@") ? "Please enter a valid email address" : null,
                    onSaved: (input) => _email = input,
                    ),
                ),
                 Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Password"),
                    validator: (input) => input.length < 6
                    ? "Password must contain at least 6 characters" : null,
                    onSaved: (input) => _password = input,
                    obscureText: true,
                    ),
                ),
                SizedBox(height: 20),
                  Container(width: 250,
                    child: FlatButton(
                      onPressed: _submit,
                       color: Colors.blue,
                       padding: EdgeInsets.all(10),
                       child: Text("Login", 
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 18
                       ),
                       ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(width: 250,
                    child: FlatButton(
                      onPressed: () => Navigator.pushNamed(context, SignupScreen.id),
                       color: Colors.blue,
                       padding: EdgeInsets.all(10),
                       child: Text("Sign up here", 
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 18
                       ),
                       ),
                    ),
                  )
              ],
            ),)
        ],
      ),
    )
    )
    )
    );
  }
}