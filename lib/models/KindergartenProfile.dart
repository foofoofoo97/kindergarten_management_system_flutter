class KindergartenProfile{
   static var _name;
   static var _address;
   static var _contactNo;
   static var _employeeFirstName;
   static var _employeeLastName;
   static var _employeeJobTitle;
   static var _employeeUID;
   static var _studentFirstName;
   static var _studentLastName;
   static var _studentUID;
   static var _ownerUID;
   static var _studentAge;
   static var _startWorkHours;
   static var _startWorkMinutes;
   static var _startStudyHours;
   static var _startStudyMinutes;
   static var _studentCourses;
   static var _feesType;
   static var _employeeAttendanceCheck;
   static var _studentAttendanceCheck;
   static var _dayToBill;
   static var _monthToBill;
   static var _isBilled;
   static var _isLater;
   static var _canAttendance;
   static var _canPosts;
   static var _canResults;
   static var _canPerformance;
   static var _employeePresent;
   static var _employeeLate;
   static var _employeeLeave;
   static var _employeeAbsent;
   static var _studentPresent;
   static var _studentLate;
   static var _studentLeave;
   static var _studentAbsent;
   static var _pendingStudentUID;
   static var _pendingEmployeeUID;

   set pendingStudentUID(List<String> value)=>_pendingStudentUID=value;
   get pendingStudentUID=>_pendingStudentUID;

   set pendingEmployeeUID(List<String> value)=>_pendingEmployeeUID=value;
   get pendingEmployeeUID=>_pendingEmployeeUID;

   set employeePresent(int value)=>_employeePresent= value;
   get employeePresent=>_employeePresent;

   set employeeLate(int value)=>_employeeLate=value;
   get employeeLate=>_employeeLate;

   set employeeAbsent(int value)=>_employeeAbsent=value;
   get employeeAbsent=>_employeeAbsent;

   set employeeLeave(int value)=>_employeeLeave=value;
   get employeeLeave=>_employeeLeave;

   set studentPresent(int value)=>_studentPresent= value;
   get studentPresent=>_studentPresent;

   set studentLate(int value)=>_studentLate=value;
   get studentLate=>_studentLate;

   set studentAbsent(int value)=>_studentAbsent=value;
   get studentAbsent=>_studentAbsent;

   set studentLeave(int value)=>_studentLeave=value;
   get studentLeave=>_studentLeave;

   set canAttendance(List<int> value)=> _canAttendance=value;
   get canAttendance=> _canAttendance;

   set canPosts(List<int> value)=> _canPosts=value;
   get canPosts=> _canPosts;

   set canPerformance(List<int> value)=>_canPerformance=value;
   get canPerformance=>_canPerformance;

   set canResults(List<int> value)=>_canResults=value;
   get canResults=> _canResults;

   set isLater(Duration time)=> _isLater=time;
   get isLater=>_isLater;

   set dayToBill(int day)=>_dayToBill=day;
   get dayToBill=>_dayToBill;

   set monthToBill(int day)=>_monthToBill=day;
   get monthToBill=>_monthToBill;

   set isBilled(bool value)=>_isBilled=value;
   get isBilled=>_isBilled;

   set studentAttendanceCheck(String date)=>_studentAttendanceCheck=date;
   get studentAttendanceCheck=>_studentAttendanceCheck;

   set employeeAttendanceCheck(String date)=>_employeeAttendanceCheck=date;
   get employeeAttendanceCheck=>_employeeAttendanceCheck;

   set feesType(Map<String,dynamic> value)=>_feesType = value;
   get feesType=>_feesType;

   set studentCourse(Map<String,dynamic> value)=>_studentCourses=value;
   get studentCourse=>_studentCourses;

   set startWorkHours(int value)=>_startWorkHours = value;
   get startWorkHours=>_startWorkHours;

   set startWorkMinutes(int value)=>_startWorkMinutes = value;
   get startWorkMinutes=>_startWorkMinutes;

   set startStudyHours(int value)=>_startStudyHours = value;
   get startStudyHours=>_startStudyHours;

   set startStudyMinutes(int value)=>_startStudyMinutes = value;
   get startStudyMinutes=>_startStudyMinutes;

   set name(String value)=>_name=value;
   get name=>_name;

   set contactNo(String value)=>_contactNo=value;
   get contactNo=>_contactNo;

   set address(String value)=>_address=value;
   get address=>_address;

   set ownerUID(List<String> value)=>_ownerUID=value;
   get ownerUID=>_ownerUID;


   set employeeFirstName(List<String> value)=>_employeeFirstName=value;
   get employeeFirstName=>_employeeFirstName;

   set employeeLastName(List<String> value)=>_employeeLastName=value;
   get employeeLastName=>_employeeLastName;

   set employeeUID(List<String> value)=>_employeeUID=value;
   get employeeUID=>_employeeUID;

   set employeeJobTitle(List<String> value)=>_employeeJobTitle=value;
   get employeeJobTitle=>_employeeJobTitle;


   set studentFirstName(List<String> value)=>_studentFirstName=value;
   get studentFirstName=>_studentFirstName;

   set studentLastName(List<String> value)=>_studentLastName=value;
   get studentLastName=>_studentLastName;

   set studentUID(List<String> value)=>_studentUID=value;
   get studentUID=>_studentUID;

   set studentAge(List<int> value)=>_studentAge=value;
   get studentAge=>_studentAge;
}