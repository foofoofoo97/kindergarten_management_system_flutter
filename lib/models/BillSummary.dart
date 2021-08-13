class BillSummary{
  var _totalBills;
  var _totalUnPaid;
  var _totalPaid;
  var _totalBillsStudents;
  var _totalUnPaidStudents;
  var _totalPaidStudents;
  var _totalBillsNo;
  var _totalUnPaidNo;
  var _totalPaidNo;
  var _status;
  var _billTime;

  set billTime(DateTime date)=>_billTime=date;
  get billTime=>_billTime;

  set totalBills(double value)=>_totalBills=value;
  get totalBills=>_totalBills;

  set totalUnPaid(double value)=>_totalUnPaid=value;
  get totalUnPaid=>_totalUnPaid;

  set totalPaid(double value)=>_totalPaid=value;
  get totalPaid=>_totalPaid;

  set totalBillsStudents(int value)=>_totalBillsStudents=value;
  get totalBillsStudents=>_totalBillsStudents;

  set totalUnPaidStudents(int value)=>_totalUnPaidStudents=value;
  get totalUnPaidStudents=>_totalUnPaidStudents;

  set totalPaidStudents(int value)=>_totalPaidStudents=value;
  get totalPaidStudents=>_totalPaidStudents;

  set totalBillsNo(int value)=>_totalBillsNo=value;
  get totalBillsNo=>_totalBillsNo;

  set totalUnPaidNo(int value)=>_totalUnPaidNo=value;
  get totalUnPaidNo=>_totalUnPaidNo;

  set totalPaidNo(int value)=>_totalPaidNo=value;
  get totalPaidNo=>_totalPaidNo;

  set status(int value)=>_status=value;
  get status=>_status;
}