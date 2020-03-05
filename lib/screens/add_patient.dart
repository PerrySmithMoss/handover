import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPatient extends StatefulWidget {
  @override
  _AddPatientState createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  final db = Firestore.instance;

  final _formKey = GlobalKey<FormState>();
  String _name, _age, _dob, _gender, _notes;
  DateTime selectedDate = DateTime.now();
  TextEditingController _date = TextEditingController();

  var _currentGenderSelected;
  List<String> _genders = <String>['Male', 'Female', 'Other'];

  Future<String>getCurrentUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String uid = user.uid.toString();
    return uid;
  }

// add user's patient to firebase
  void _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await db
          .collection("patients")
          .document(await getCurrentUser())
          .collection("Patients")
          .add({
        'Patient name': _name,
        'Age': _age,
        'Date of Birth': _dob,
        'Gender': _gender,
        'Notes': _notes,
        "Timestamp": Timestamp.fromDate(DateTime.now())
      });
    }
    Navigator.pop(context);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Add Patient",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(.2),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Name",
                    icon: Icon(Icons.person),
                  ),
                  validator: (input) =>
                      input.trim().isEmpty ? 'Please enter a valid name' : null,
                  onSaved: (input) => _name = input,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(.2),
                child: GestureDetector(
                  onTap: () => selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      validator: (input) => input.trim().isEmpty
                          ? 'Please enter a valid Date of Birth'
                          : null,
                      onSaved: (input) => _dob = input,
                      controller: _date,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                          hintText: 'Date of Birth',
                          icon: Icon(
                            Icons.calendar_today,
                            size: 22,
                          )),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(.2),
                  child: DropdownButtonFormField(
                    validator: (input) => input.trim().isEmpty
                        ? 'Please enter a valid Gender'
                        : null,
                    onSaved: (input) => _gender = input,
                    decoration: InputDecoration(
                        labelText: "Gender", icon: Icon(Icons.person_add)),
                    items: _genders
                        .map((value) => DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.black),
                              ),
                              value: value,
                            ))
                        .toList(),
                    onChanged: (selectedGenderType) {
                      setState(() {
                        _currentGenderSelected = selectedGenderType;
                      });
                    },
                    value: _currentGenderSelected,
                  )),
              Padding(
                padding: EdgeInsets.all(.2),
                child: TextFormField(
                  validator: (input) =>
                      input.trim().isEmpty ? 'Please enter a valid name' : null,
                  onSaved: (input) => _age = input,
                  decoration: InputDecoration(
                      labelText: "Age", icon: Icon(Icons.date_range)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(.2),
                child: TextFormField(
                  maxLength: 300,
                  onSaved: (input) => _notes = input,
                  decoration: InputDecoration(
                      labelText: "Notes", icon: Icon(Icons.note_add)),
                ),
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
      ),
    );
  }
}
