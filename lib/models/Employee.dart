class EmployeeProfile{
  static var _firstName;
  static var _lastName;
  static var _contactNo;
  static var _kindergarten;
  static var _homeAddress;
  static var _jobTitle;
  static var _uid;
  static var _status;

  set status(int value)=>_status=value;
  get status=>_status;

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

  set homeAddress(String value)=>_homeAddress=value;
  get homeAddress=>_homeAddress;

  set jobTitle(String value)=>_jobTitle=value;
  get jobTitle=>_jobTitle;
}

class EmployeeAccounts{
   var _firstName;
   var _lastName;
   var _contactNo;
   var _canAttendance;
   var _canPosts;
   var _canResults;
   var _canPerformance;
   var _kindergarten;
   var _homeAddress;
   var _jobTitle;
   var _uid;

   set canAttendance(int value)=> _canAttendance=value;
   get canAttendance=> _canAttendance;

   set canPosts(int value)=> _canPosts=value;
   get canPosts=> _canPosts;

   set canPerformance(int value)=>_canPerformance=value;
   get canPerformance=>_canPerformance;

   set canResults(int value)=>_canResults=value;
   get canResults=> _canResults;

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

  set homeAddress(String value)=>_homeAddress=value;
  get homeAddress=>_homeAddress;

  set jobTitle(String value)=>_jobTitle=value;
  get jobTitle=>_jobTitle;
}