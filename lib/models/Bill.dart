class Bill{
  var _billTime;
  var _paidTime;
  var _childrenName;
  var _fname;
  var _lname;
  var _status;
  var _totalFee;
  var _uid;
  var _noOfBills;
  var _billId;
  var _kindergarten;

  set billId(String value)=>_billId=value;
  get billId=>_billId;

  set kindergarten(String value)=>_kindergarten=value;
  get kindergarten=>_kindergarten;

  set noOfBills(int value)=>_noOfBills=value;
  get noOfBills=>_noOfBills;

  set billTime(DateTime time)=>_billTime=time;
  get billTime=>_billTime;

  set paidTime(DateTime time)=>_paidTime=time;
  get paidTime=>_paidTime;

  set childrenName(List value)=>_childrenName=value;
  get childrenName=>_childrenName;

  set fname(String value)=>_fname=value;
  get fname=>_fname;

  set lname(String value)=>_lname=value;
  get lname=>_lname;

  set status(int value)=>_status=value;
  get status=>_status;

  set totalFee(double value)=>_totalFee=value;
  get totalFee=>_totalFee;

  set uid(String value)=>_uid=value;
  get uid=>_uid;
}