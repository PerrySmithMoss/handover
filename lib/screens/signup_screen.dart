import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handover_app/screens/login_screen.dart';
import 'package:handover_app/services/auth_services.dart';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';

class SignupScreen extends StatefulWidget {

  static final String id = "signup_screen";

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();
  String _name, _email, _password;
  bool _isSelected = false;

  // Signing up the user with Firebase and generating them a unique key that will be used for encryption
  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      AuthService.signUpUser(context, _name, _email, _password, await _generateDESKey());
      Navigator.pop(context);
    }
  }

  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  // generating the user a key, which will be used for encryption
  _generateDESKey() async {
    var key = await FlutterAesEcbPkcs5.generateDesKey(128);
    String userKey = key;
    return userKey;
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16.0,
        height: 16.0,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2.0, color: Colors.black)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              )
            : Container(),
      );

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );
      
  @override
  Widget build(BuildContext context) {
  ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 56.0),
                child: Image.asset("assets/images/image_01.png"),
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/images/image_02.png")
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 60.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/handover_app_logo.png",
                        width: ScreenUtil.getInstance().setWidth(140),
                        height: ScreenUtil.getInstance().setHeight(110),
                      ),
                      Text(" Handover",
                          style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: ScreenUtil.getInstance().setSp(65),
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(200),
                  ),
                  Container(
        width: double.infinity,
        height: ScreenUtil.getInstance().setHeight(630),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 15.0),
                  blurRadius: 15.0),
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, -10.0),
                  blurRadius: 10.0),
            ]),
        child: Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("SignUp",
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(45),
                        fontFamily: "Poppins-Bold",
                        letterSpacing: .6)),
                SizedBox(
                  height: ScreenUtil.getInstance().setHeight(30),
                ),
                Text("Name",
                style: TextStyle(
                    fontFamily: "Poppins-Medium",
                    fontSize: ScreenUtil.getInstance().setSp(26))),
            TextFormField(
              decoration: InputDecoration(
                  hintText: "Name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                  validator: (input) => input.trim().isEmpty
                            ? 'Please enter a valid name'
                            : null,
                        onSaved: (input) => _name = input,
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(30),
                ),
                Text("Email",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil.getInstance().setSp(28))),
                TextFormField(
                  decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                  validator: (input) => !input.contains("@")
                      ? "Please enter a valid email address"
                      : null,
                  onSaved: (input) => _email = input,
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().setHeight(30),
                ),
                Text("Password",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil.getInstance().setSp(28))),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Password", hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                    validator: (input) => input.length < 6
                      ? "Password must contain at least 6 characters"
                      : null,
                  onSaved: (input) => _password = input,
                  obscureText: true,
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().setHeight(40),
                ),
              ],
            ),
          ),
        )),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 12.0,
                          ),
                          GestureDetector(
                            onTap: _radio,
                            child: radioButton(_isSelected),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text("Remember me",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "Poppins-Medium"))
                        ],
                      ),
                      InkWell(
                        child: Container(
                          width: ScreenUtil.getInstance().setWidth(330),
                          height: ScreenUtil.getInstance().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF17ead9),
                                Color(0xFF6078ea)
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                showDialog(context: context, builder: (BuildContext context) => _buildAboutDialog(context));
                              },
                              child: Center(
                                child: Text("SignUp",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 19,
                                        letterSpacing: 1.5)),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(28),
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Have an Account? ",
                        style: TextStyle(fontFamily: "Poppins-Medium", fontSize: 24),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => LoginScreen()));
                            },
                        child: Text("LogIn",
                            style: TextStyle(
                                color: Color(0xFF5d74e3),
                                fontFamily: "Poppins-Bold", fontSize: 20)),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildAboutDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Privacy Policy'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("I agree to my data being stored")
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Cancel'),
        ),
        FlatButton(
          onPressed: _submit,
          textColor: Theme.of(context).primaryColor,
          child: const Text('Agree'),
        ),
      ],
    );
}
}