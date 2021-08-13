import 'package:kiki/contents/size_config.dart';

class GuardianProfile{
  static var _firstName;
  static var _lastName;
  static var _homeAddress;
  static var _contactNo;
  static var _noOfChildren;
  static var _childrenFirstName;
  static var _childrenLastName;
  static var _childrenAge;
  static var _childrenUID;
  static var _childrenStatus;
  static var _childrenKindergarten;
  static var _uid;

  set uid(String value)=>_uid=value;
  get uid=>_uid;

  set childrenStatus(List<int> value)=>_childrenStatus=value;
  get childrenStatus=>_childrenStatus;

  set childrenUID(List<String> value)=>_childrenUID=value;
  get childrenUID=>_childrenUID;

  set firstName(String value)=>_firstName=value;
  get firstName=>_firstName;

  set lastName(String value)=>_lastName=value;
  get lastName=>_lastName;

  set contactNo(String value)=>_contactNo=value;
  get contactNo=>_contactNo;

  set homeAddress(String value)=>_homeAddress=value;
  get homeAddress=>_homeAddress;

  set noOfChildren(String value)=>_noOfChildren=value;
  get noOfChildren=>_noOfChildren;

  set childrenKindergarten(List<String> value)=>_childrenKindergarten=value;
  get childrenKindergarten=>_childrenKindergarten;

  set childrenFirstName(List<String> value)=>_childrenFirstName=value;
  get childrenFirstName=>_childrenFirstName;

  set childrenLastName(List<String> value)=>_childrenLastName=value;
  get childrenLastName=>_childrenLastName;

  set childrenAge(List<String> value)=>_childrenAge=value;
  get childrenAge=>_childrenAge;

}

class GuardianAcc{
   var _firstName;
   var _lastName;
   var _homeAddress;
   var _contactNo;
   var _noOfChildren;
   var _childrenFirstName;
   var _childrenLastName;
   var _childrenAge;
   var _childrenUID;
   var _childrenKindergarten;
   var _uid;

  set uid(String value)=>_uid=value;
  get uid=>_uid;


  set childrenUID(List<String> value)=>_childrenUID=value;
  get childrenUID=>_childrenUID;

  set firstName(String value)=>_firstName=value;
  get firstName=>_firstName;

  set lastName(String value)=>_lastName=value;
  get lastName=>_lastName;

  set contactNo(String value)=>_contactNo=value;
  get contactNo=>_contactNo;

  set homeAddress(String value)=>_homeAddress=value;
  get homeAddress=>_homeAddress;

  set noOfChildren(String value)=>_noOfChildren=value;
  get noOfChildren=>_noOfChildren;

  set childrenKindergarten(List<String> value)=>_childrenKindergarten=value;
  get childrenKindergarten=>_childrenKindergarten;

  set childrenFirstName(List<String> value)=>_childrenFirstName=value;
  get childrenFirstName=>_childrenFirstName;

  set childrenLastName(List<String> value)=>_childrenLastName=value;
  get childrenLastName=>_childrenLastName;

  set childrenAge(List<String> value)=>_childrenAge=value;
  get childrenAge=>_childrenAge;
}