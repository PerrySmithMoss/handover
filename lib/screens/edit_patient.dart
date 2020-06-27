import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handover_app/models/patient_model.dart';

class EditPatient extends StatefulWidget {
  final Patient patient;

  EditPatient({Key key, @required this.patient}) : super(key: key);

  @override
  _EditPatientState createState() => _EditPatientState();
}

class _EditPatientState extends State<EditPatient> {

  void initState() {
    super.initState();
      // add a timestamp controller, variable and textformfeild.
      // _nameController.text = widget.patient.name;
      // _dateController.text = widget.patient.dob;
      // _currentGenderSelected = widget.patient.gender;
      // _ageController.text = widget.patient.age;
      // _notesController.text = widget.patient.notes;
      // _name = widget.patient.name;
      // _age = widget.patient.age;
      // _dob = widget.patient.dob;
      // _gender = widget.patient.gender;
      // _currentGenderSelected = widget.patient.gender;
      // _notes = widget.patient.notes;
      
  }
  final db = Firestore.instance;

  final _formKey = GlobalKey<FormState>();
  var _name, _age, _dob, _gender, _notes, _currentGenderSelected;

  DateTime selectedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  List<String> _genders = <String>['Male', 'Female', 'Other'];

  Future<String> getCurrentUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String uid = user.uid.toString();
    return uid;
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
        _dateController.value = TextEditingValue(text: picked.toString().split(" ")[0]);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Patient",
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
                  controller: _nameController,
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
                      controller: _dateController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                          hintText: "Date of Birth",
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
                        labelText: "Gender",
                        icon: Icon(Icons.person_add)),
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
                      input.trim().isEmpty ? 'Please enter a valid age' : null,
                  onSaved: (input) => _age = input,
                  controller: _ageController,
                  decoration: InputDecoration(
                      labelText: "Age",
                      icon: Icon(Icons.date_range)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(.2),
                child: TextFormField(
                  maxLength: 300,
                  onSaved: (input) => _notes = input,
                  controller: _notesController,
                  decoration: InputDecoration(
                      labelText: "Notes",
                      icon: Icon(Icons.note_add)),
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
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed:  
                      () async {
                        widget.patient.name = (_nameController.text);
                        widget.patient.dob = (_dateController.text);
                        // widget.patient.gender = .text;
                        widget.patient.age = (_ageController.text);
                        widget.patient.notes = (_notesController.text);
                        setState(() {
                          _name = widget.patient.name;
                          _dob = widget.patient.dob;
                          _gender = widget.patient.gender;
                          _age = widget.patient.age;
                          _notes = widget.patient.notes;
                        });
                        await updatePatient(context);
                        Navigator.of(context).pop();
                      }
                  ),
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                      "Remove",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await deletePatient(context);
                      Navigator.of(context).pop();
                    }
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future updatePatient(context) async {
    var uid = await getCurrentUser();
    final patient = Firestore.instance
        .collection("patients")
        .document(uid)
        .collection("Patients")
        .document(widget.patient.patientId);
        return await patient.setData(widget.patient.toJson());
  }

    Future deletePatient(context) async {
    var uid = await getCurrentUser();
    final patient = Firestore.instance
        .collection("patients")
        .document(uid)
        .collection("Patients")
        .document(widget.patient.patientId);
        return await patient.delete();
  }
}
