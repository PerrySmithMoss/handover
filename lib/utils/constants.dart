import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firestore = Firestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final usersRef = _firestore.collection('users');
final postsRef = _firestore.collection('posts');
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');
final feedsRef = _firestore.collection('feeds');
final commentsRef = _firestore.collection("comments");
final likesRef = _firestore.collection("likes");
final activitiesRef = _firestore.collection("activities");

const String MESSAGES_COLLECTION = "messages";
const String USERS_COLLECTION = "collection";
const String TIMESTAMP_FIELD = "timestamp";