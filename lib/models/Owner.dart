class OwnerProfile{
  static var _firstName;
  static var _lastName;
  static var _contactNo;
  static var _kindergarten;
  static var _uid;

  set uid(String value)=>_uid=value;
  get uid=>_uid;


  set firstName(String value)=>_firstName=value;
  get firstName=>_firstName;

  set lastName(String value)=>_lastName=value;
  get lastName=>_lastName;

  set contactNo(String value)=>_contactNo=value;
  get contactNo=>_contactNo;

  set kindergarten(String value)=>_kindergarten=value;
  get kindergarten=>_kindergarten;
}