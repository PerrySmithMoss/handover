import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handover_app/models/user_model.dart';
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

  final _formKey = GlobalKey<FormState>();
  String _name, _age;
  DateTime selectedDate = DateTime.now();
  TextEditingController _date = TextEditingController();

  List<String> _gender = ["Male", "Female", "Other"];
  var _selectedGender;

  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _date.value = TextEditingValue(text: picked.toString().split(" ")[0]);
      });
  }

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
  }

  _addPatientDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Patient"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(.2),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(.2),
                    child: GestureDetector(
                      onTap: () => selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _date,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'Date of Birth',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(.2),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(labelText: "Gender"),
                      value: _selectedGender,
                      isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                        print(_selectedGender);
                      },
                      items: _gender
                          .map<DropdownMenuItem<String>>
                          ((String value) {
                            return DropdownMenuItem<String>(
                            value: value,
                                child: Text(value),
                              );
                          }).toList(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(.2),
                    child: TextFormField(
                        decoration: InputDecoration(labelText: "Age"),
                        onSaved: (input) => _age = input),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _submit,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
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
        padding: const EdgeInsets.fromLTRB(0, 16, 7, 0),
        child: Column(
          children: <Widget>[
            Row(
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
                    _addPatientDialog(context);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 0, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: InputBorder.none,
                  hintText: "Search",
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
          ],
        ),
      ),
    );
  }
}
