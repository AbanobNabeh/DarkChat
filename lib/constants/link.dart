import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseFirestore FIRESTORE = FirebaseFirestore.instance;
FirebaseStorage STOAGE = FirebaseStorage.instance;
var FIREUSER = FIRESTORE.collection("users");
var FIRESARAHAH = FIRESTORE.collection("sarahah");
var FIREGROUP = FIRESTORE.collection("group");
var FIREROOM = FIRESTORE.collection("room");
var STOAGEUSER = STOAGE.ref("users");
var STORAGEGROUP = STOAGE.ref("group");
var STORAGESARAHAH = STOAGE.ref("sarahah");
String MYFAV = "myfavorite";
String HISFAV = "hisfavorite";
String NOTIFI = "notifications";
String CHAT = "chat";
String MESSAGS = "messages";
String SARAHAH = 'sarahah';
String REPORT = 'report';
String MUTE = 'mute';
