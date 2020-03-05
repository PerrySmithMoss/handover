import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget buildPatientCard(BuildContext context, DocumentSnapshot patient) {
    return new Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Row(children: <Widget>[
                  Text(patient['Patient name'], style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text(patient['Gender'], style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
                  Text(", ", style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
                  Text(patient["Age"], style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold))
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 80.0),
                child: Row(children: <Widget>[
                  Text(
                      patient['Date of Birth'], style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  Spacer(),
                ]),
              ),
                 Row(
                  children: <Widget>[
                    Text(patient['Notes'], style: new TextStyle(fontSize: 20.0),),
                    Spacer(),
                    Icon(Icons.person),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
