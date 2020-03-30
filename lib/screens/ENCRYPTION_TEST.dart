import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';

class Encryption extends StatefulWidget {
  @override
  _EncryptionState createState() => _EncryptionState();
}

class _EncryptionState extends State<Encryption> {

  String _name = "Perry Smith-Moss";

  // encrypting the patient data 
  _encrypt() async {
    var userKey = await getUserKey();

    final encryptedName =
        await FlutterAesEcbPkcs5.encryptString(_name, userKey);
    return encryptedName;
  }

  // decrypting the patient data
  _decrypt() async {
    var userKey = await getUserKey();

    final decryptText =
        await FlutterAesEcbPkcs5.decryptString(await _encrypt(), userKey);
    print(decryptText);    
  }

  getCurrentUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String uid = user.uid.toString();
    return uid;
  }

  Future<String>getUserKey() async {
    final uid = await getCurrentUser();
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(uid).get();
    String userKey = snapshot.data['userKey'];
    return userKey.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: <Widget>[
        Center(
          child: RaisedButton(
            color: Colors.green,
            onPressed: () {
              _encrypt();
            },
          ),
        ),
        RaisedButton(
            color: Colors.blue,
            onPressed: () {
              _decrypt();
            },
          ),
      ],
    ));
  }
}
