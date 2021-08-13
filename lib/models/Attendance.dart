class Attendance{
  DateTime checkInDateTime;
  DateTime checkOutDateTime;
  int checkInHrs;
  int checkInMin;
  int checkOutHrs;
  int checkOutMin;
  DateTime dateTime;
  String status;
  int checkInStatus;
  String checkInAddress;
  String checkOutAddress;

  Attendance({
    this.checkInDateTime,
    this.checkOutDateTime,
    this.checkInHrs,
    this.checkInMin,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkOutHrs,
    this.checkOutMin,
    this.dateTime,
    this.status,
    this.checkInStatus
  });
}