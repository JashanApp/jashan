import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:jashan/data/track.dart';
import 'package:collection/collection.dart';
import 'package:jashan/data/user.dart';

class PartyInfo {
  final String title;
  final DocumentReference firebaseDocument;
  final int id;
  final QueueList<Track> songs = new QueueList();
  final JashanUser owner;

  PartyInfo({@required this.title, @required this.id, @required this.owner}) :
    firebaseDocument = Firestore.instance.collection('parties').document('$id');
}