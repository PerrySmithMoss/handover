import 'package:cloud_firestore/cloud_firestore.dart';

class Patient{
  String patientId;
  String name;
  String gender;
  String age;
  String dob;
  String notes;

  Patient({
    this.patientId,
    this.name,
    this.gender,
    this.age,
    this.dob,
    this.notes
  });

    Map<String, dynamic> toJson() => {
    'Patient name': name,
    'Gender': gender,
    'Age': age,
    'Date of Birth': dob,
    'Notes': notes,
  };

    Patient.fromSnapshot(DocumentSnapshot snapshot):
    patientId = snapshot.documentID,
      name = snapshot['Patient name'],
      gender = snapshot['Gender'],
      age = snapshot['Age'],
      dob = snapshot['Date of Birth'],
      notes = snapshot['Notes'];   
  }