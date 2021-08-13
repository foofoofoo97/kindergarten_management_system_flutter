class StudentBill{
  var _fees;
  var _fname;
  var _lname;
  var _totalFee;
  var _uid;

  set fees(Map value)=>_fees=value;
  get fees=>_fees;

  set fname(String value)=>_fname=value;
  get fname=>_fname;

  set lname(String value)=>_lname=value;
  get lname=>_lname;

  set totalFee(double value)=>_totalFee=value;
  get totalFee=>_totalFee;

  set uid(String value)=>_uid=value;
  get uid=>_uid;

}