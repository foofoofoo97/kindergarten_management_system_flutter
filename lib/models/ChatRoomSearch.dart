class OwnerReceiver{
  var _uid;
  var _name;
  var _kindergarten;

  set kindergarten(String value)=>_kindergarten=value;
  get kindergarten=>_kindergarten;

  set uid(String value)=>_uid=value;
  get uid=>_uid;

  set name(String value)=>_name=value;
  get name=>_name;
}


class GuardianReceiver{
  var _uid;
  var _name;
  var _studentName;

  set uid(String value)=>_uid=value;
  get uid=>_uid;

  set name(String value)=>_name=value;
  get name=>_name;

  set studentName(String value)=>_studentName=value;
  get studentName=>_studentName;
}

class EmployeeReceiver{
  var _uid;
  var _name;
  var _jobTitle;
  var _kindergarten;

  set kindergarten(String value)=>_kindergarten=value;
  get kindergarten=>_kindergarten;

  set uid(String value)=>_uid=value;
  get uid=>_uid;

  set name(String value)=>_name=value;
  get name=>_name;

  set jobTitle(String value)=>_jobTitle=value;
  get jobTitle=>_jobTitle;
}