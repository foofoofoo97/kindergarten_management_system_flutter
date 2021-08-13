import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
   var _description;
   var _url;
   var _dateTime;
   var _firstName;
   var _lastName;
   var _uid;
   var _kindergarten;
   var _docID;

   set docID(String value)=>_docID=value;
   get docID=>_docID;

   set kindergarten(String value)=>_kindergarten=value;
   get kindergarten=>_kindergarten;

  set description(String value)=>_description=value;
  get description=>_description;

  set dateTime(DateTime value)=>_dateTime=value;
  get dateTime=>_dateTime;

  set uid(List<String> value)=>_uid=value;
  get uid=>_uid;

  set url(String value)=>_url=value;
  get url=>_url;

  set firstName(List<String> value)=>_firstName=value;
  get firstName=>_firstName;

  set lastName(List<String> value)=>_lastName=value;
  get lastName=>_lastName;

}