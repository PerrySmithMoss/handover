import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:handover_app/models/patient_model.dart';
import 'package:handover_app/models/user_model.dart';
import 'package:handover_app/screens/add_patient.dart';
import 'package:handover_app/screens/edit_patient.dart';
import 'package:handover_app/services/database_service.dart';
import 'package:handover_app/utils/constants.dart';

class PatientsScreen extends StatefulWidget {
  final String userId;

  PatientsScreen({this.userId});

  @override
  _PatientsScreenState createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  getCurrentUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String uid = user.uid.toString();
    return uid;
  }

  // if not working remove the Future<void>
  Future<String> getUserKey() async {
    final uid = await getCurrentUser();
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(uid).get();
    String userKey = snapshot.data['userKey'];
    return userKey;
  }

  Stream<QuerySnapshot> getUsersPatientStreamSnapshots(
      BuildContext context) async* {
    final uid = await getCurrentUser();
    yield* Firestore.instance
        .collection('patients')
        .document(uid)
        .collection('Patients')
        // .orderBy('Timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "My Patients",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 7),
            child: FutureBuilder(
                future: usersRef.document(widget.userId).get(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  User user = User.fromDoc(snapshot.data);
                  return CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: user.profileImageUrl.isEmpty
                        ? AssetImage(
                            'assets/images/default_profile_picture.png')
                        : CachedNetworkImageProvider(user.profileImageUrl),
                  );
                }),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(3, 12, 3, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: InputBorder.none,
                  hintText: "Search Patients",
                  prefixIcon: Icon(
                    Icons.search,
                    size: 30,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
                  filled: true,
                ),
                onSubmitted: (input) {
                  if (input.isNotEmpty) {
                    setState(() {
                      _users = DatabaseService.searchUsers(input);
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    child: Row(children: <Widget>[
                      Icon(Icons.person_add),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                        child: Text(
                          "Add Patient",
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      )
                    ]),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddPatient()));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: StreamBuilder(
                    stream: getUsersPatientStreamSnapshots(context),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Loading...");
                      return new ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildPatientCard(
                                  context, snapshot.data.documents[index]));
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPatientCard(BuildContext context, DocumentSnapshot document) {
    final patient = Patient.fromSnapshot(document);

    Future<String> _decryptName() async {
      var userKey = await getUserKey();
      String decryptText =
          await FlutterAesEcbPkcs5.decryptString(patient.name, userKey);
      return decryptText;
    }

    Future<String> _decryptGender() async {
      var userKey = await getUserKey();
      String decryptText =
          await FlutterAesEcbPkcs5.decryptString(patient.gender, userKey);
      return decryptText;
    }

    Future<String> _decryptAge() async {
      var userKey = await getUserKey();
      String decryptText =
          await FlutterAesEcbPkcs5.decryptString(patient.age, userKey);
      return decryptText;
    }

    Future<String> _decryptDOB() async {
      var userKey = await getUserKey();
      String decryptText =
          await FlutterAesEcbPkcs5.decryptString(patient.dob, userKey);
      return decryptText;
    }

    Future<String> _decryptNotes() async {
      var userKey = await getUserKey();
      String decryptText =
          await FlutterAesEcbPkcs5.decryptString(patient.notes, userKey);
      return decryptText;
    }

    return new Container(
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditPatient(patient: patient)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Row(children: <Widget>[
                    FutureBuilder(
                      future: _decryptName(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData)
                          return Text(
                            '${snapshot.data}',
                            style: new TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          );
                        if (snapshot.error)
                          return Text(
                            'Error getting the data.',
                            style: new TextStyle(
                                fontSize: 7.0, fontWeight: FontWeight.bold),
                          );
                        return const CircularProgressIndicator();
                      },
                    ),
                    Spacer(),
                    FutureBuilder(
                      future: _decryptGender(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData)
                          return Text(
                            '${snapshot.data}',
                            style: new TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          );
                        if (snapshot.error)
                          return Text(
                            'error',
                            style: new TextStyle(
                                fontSize: 7.0, fontWeight: FontWeight.bold),
                          );
                        return const CircularProgressIndicator();
                      },
                    ),
                    Text(", ",
                        style: new TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    FutureBuilder(
                      future: _decryptAge(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData)
                          return Text(
                            '${snapshot.data}',
                            style: new TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          );
                        if (snapshot.error)
                          return Text(
                            'error',
                            style: new TextStyle(
                                fontSize: 7.0, fontWeight: FontWeight.bold),
                          );
                        return const CircularProgressIndicator();
                      },
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 80.0),
                  child: Row(children: <Widget>[
                    FutureBuilder(
                      future: _decryptDOB(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData)
                          return Text(
                            '${snapshot.data}',
                            style: new TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          );
                        if (snapshot.error)
                          return Text(
                            'error',
                            style: new TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          );
                        return const CircularProgressIndicator();
                      },
                    ),
                    Spacer(),
                  ]),
                ),
                Row(
                  children: <Widget>[
                    FutureBuilder(
                      future: _decryptNotes(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData)
                          return Text(
                            '${snapshot.data}',
                            style: new TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          );
                        if (snapshot.error)
                          return Text(
                            'error',
                            style: new TextStyle(
                                fontSize: 7.0, fontWeight: FontWeight.bold),
                          );
                        return const CircularProgressIndicator();
                      },
                    ),
                    Spacer(),
                    Icon(Icons.person),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
