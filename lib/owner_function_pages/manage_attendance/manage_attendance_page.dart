import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/face_recognition/face_recognition_home_page.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/owner_function_pages/manage_attendance/check_in_student_attendance_page.dart';
import 'package:kiki/owner_function_pages/manage_attendance/view_employee_attendance_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/info_message_dialog.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ManageAttendancePage extends StatefulWidget {
  @override
  _ManageAttendancePageState createState() => _ManageAttendancePageState();
}

class _ManageAttendancePageState extends State<ManageAttendancePage> {
  final GlobalKey<ScaffoldState> _employeeKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _studentKey = new GlobalKey<ScaffoldState>();

  CollectionReference employee =
      FirebaseFirestore.instance.collection('employee');
  CollectionReference student =
      FirebaseFirestore.instance.collection('student');
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  TextEditingController searchStudentController = new TextEditingController();
  TextEditingController searchEmployeeController = new TextEditingController();

  List<Student> students = new List.from([]);
  List<EmployeeAccounts> employees = new List.from([]);
  List<Student> items = new List.from([]);
  List<EmployeeAccounts> items2 = new List.from([]);

  bool employeeIsLoading;
  bool employeeShowBottom;
  bool studentIsLoading;
  bool studentShowBottom;

  Map statusToIndex = {'present': 0, 'late': 1, 'absent': 2, 'leave': 3};
  List<String> states = ['present', 'late', 'absent', 'leave'];

  String preEmployeeStatus;
  String employeeStatus;
  String selectedEmployee;

  String preStudentStatus;
  String studentStatus;
  String selectedStudent;

  DateTime today;
  String date;

  DateFormat formatter = DateFormat('dd MMM yyy');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  @override
  void initState() {
    // TODO: implement initState
    employeeShowBottom = false;
    employeeIsLoading = false;

    studentShowBottom = false;
    studentIsLoading = false;

    today = DateTime.now();
    date = '${today.day}-${today.month}-${today.year}';

    prepareData();
    prepareData2();
    condition();

    super.initState();
  }

  void prepareData() {
    for (int index = 0;
        index < kindergartenProfile.studentUID.length;
        index++) {
      Student student = new Student();
      student.firstName = kindergartenProfile.studentFirstName[index];
      student.lastName = kindergartenProfile.studentLastName[index];
      student.uid = kindergartenProfile.studentUID[index];
      student.age = kindergartenProfile.studentAge[index];

      students.add(student);
    }
    items.addAll(students);
  }

  void prepareData2() {
    for (int index = 0;
        index < kindergartenProfile.employeeUID.length;
        index++) {
      EmployeeAccounts employeeAccounts = new EmployeeAccounts();
      employeeAccounts.firstName = kindergartenProfile.employeeFirstName[index];
      employeeAccounts.lastName = kindergartenProfile.employeeLastName[index];
      employeeAccounts.uid = kindergartenProfile.employeeUID[index];
      employeeAccounts.jobTitle = kindergartenProfile.employeeJobTitle[index];
      employees.add(employeeAccounts);
    }
    items2.addAll(employees);
  }

  Future<void> condition() async {
    bool update = false;
    if (kindergartenProfile.employeeAttendanceCheck !=
        formatter.format(DateTime.now())) {
      await initEmployeeAttendance();

      kindergartenProfile.employeeAttendanceCheck =
          formatter.format(DateTime.now());
      update = true;
    }
    if (kindergartenProfile.studentAttendanceCheck !=
        formatter.format(DateTime.now())) {
      await initStudentAttendance();

      kindergartenProfile.studentAttendanceCheck =
          formatter.format(DateTime.now());
      update = true;
    }

    if (update) {
      await kindergarten.doc(kindergartenProfile.name).update({
        'employee absent': kindergartenProfile.employeeUID.length,
        'employee present': 0,
        'employee late': 0,
        'employee leave': 0,
        'student absent': kindergartenProfile.studentUID.length,
        'student present': 0,
        'student late': 0,
        'student leave': 0,
        'employee attendance check': kindergartenProfile.employeeAttendanceCheck,
        'student attendance check': kindergartenProfile.studentAttendanceCheck
      });
    }
  }

  Future<void> initEmployeeAttendance() async {
    for (String uid in kindergartenProfile.employeeUID) {
      await employee
          .doc(uid)
          .collection('attendance')
          .doc(date)
          .set({'status': 'absent', 'datetime': DateTime.now()});
    }
  }

  Future<void> initStudentAttendance() async {
    for (String uid in kindergartenProfile.studentUID) {
      await student
          .doc(uid)
          .collection('attendance')
          .doc(date)
          .set({'status': 'absent', 'datetime': DateTime.now()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: ThemeColor.whiteColor,
            appBar: new PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight * 0.9),
              child: new Container(
                color: ThemeColor.themeBlueColor,
                child: new SafeArea(
                  child: Column(
                    children: <Widget>[
                      new TabBar(
                          indicatorColor: ThemeColor.accentCyanColor,
                          unselectedLabelColor: ThemeColor.whiteColor,
                          labelColor: ThemeColor.accentCyanColor,
                          labelStyle: TextStyle(
                              fontFamily: 'PatrickHand',
                              fontSize: SizeConfig.extraSmall),
                          isScrollable: true,
                          tabs: [
                            Tab(
                                child: Text(
                              'Student Attendance',
                              style: TextStyle(letterSpacing: 1.2),
                            )),
                            Tab(
                                child: Text(
                              'Employee Attendance',
                              style: TextStyle(letterSpacing: 1.2),
                            )),
                          ]),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                kindergartenProfile.studentAttendanceCheck !=
                        formatter.format(DateTime.now())
                    ? Container(
                        color: ThemeColor.whiteColor,
                        child: Center(
                          child: SizedBox(
                            height: SizeConfig.safeBlockVertical * 5,
                            width: SizeConfig.safeBlockVertical * 5,
                            child: CircularProgressIndicator(
                                backgroundColor: ThemeColor.whiteColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeColor.blueColor)),
                          ),
                        ),
                      )
                    : studentTabView(),
                kindergartenProfile.employeeAttendanceCheck !=
                        formatter.format(DateTime.now())
                    ? Container(
                        color: ThemeColor.whiteColor,
                        child: Center(
                          child: SizedBox(
                            height: SizeConfig.safeBlockVertical * 5,
                            width: SizeConfig.safeBlockVertical * 5,
                            child: CircularProgressIndicator(
                                backgroundColor: ThemeColor.whiteColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeColor.blueColor)),
                          ),
                        ),
                      )
                    : employeeTabView()
              ],
            ),
          ),
        ),
        employeeIsLoading || studentIsLoading
            ? Center(
                child: SizedBox(
                  height: SizeConfig.safeBlockVertical * 5,
                  width: SizeConfig.safeBlockVertical * 5,
                  child: CircularProgressIndicator(
                    backgroundColor: ThemeColor.whiteColor,
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  List<Widget> buildStudentChildren() {
    List<Widget> temp = new List.from([]);
    for (int x = 0; x < items.length; x++) {
      temp.add(KiButton.smallButton(
          onLongPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CheckInStudentAttendancePage(
                          index: x,
                        )));
          },
          onPressed: () async {
            if (selectedStudent == items[x].uid) {
              setState(() {
                selectedStudent = null;
                studentShowBottom = false;
              });
            } else {
              setState(() {
                studentIsLoading = true;
                selectedStudent = items[x].uid;
              });
              await readStudentStatus();
              setState(() {
                selectedStudent = items[x].uid;
                studentShowBottom = true;
                studentIsLoading = false;
              });
            }
          },
          child: Container(
              height: SizeConfig.safeBlockHorizontal * 28,
              width: SizeConfig.safeBlockHorizontal * 28,
              decoration: new BoxDecoration(
                color: selectedStudent == items[x].uid
                    ? ThemeColor.accentCyanColor.withOpacity(0.2)
                    : ThemeColor.blueGreyColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
              child: Column(
                children: <Widget>[
                  SizeConfig.extraSmallVerticalBox,
                  Icon(
                    Icons.perm_identity,
                    color: selectedStudent == items[x].uid
                        ? ThemeColor.accentCyanColor
                        : ThemeColor.blueGreyColor,
                    size: SizeConfig.ultraLarge,
                  ),
                  Text('${items[x].firstName} ${items[x].lastName}',
                      style: extraSmallTextStyle(
                        color: selectedStudent == items[x].uid
                            ? ThemeColor.themeBlueColor
                            : ThemeColor.blueGreyColor,
                      )),
                ],
              ))));
    }
    return temp;
  }

  List<Widget> buildEmployeeChildren() {
    List<Widget> temp = new List.from([]);
    for (int x = 0; x < items2.length; x++) {
      temp.add(KiButton.smallButton(
          onLongPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewEmployeeAttendancePage(
                          index: x,
                        )));
          },
          onPressed: () async {
            if (selectedEmployee == items2[x].uid) {
              setState(() {
                selectedEmployee = null;
                employeeShowBottom = false;
              });
            } else {
              setState(() {
                employeeIsLoading = true;
                selectedEmployee = items2[x].uid;
              });
              await readEmployeeStatus();
              setState(() {
                selectedEmployee = items2[x].uid;
                employeeShowBottom = true;
                employeeIsLoading = false;
              });
            }
          },
          child: Container(
              height: SizeConfig.safeBlockHorizontal * 28,
              width: SizeConfig.safeBlockHorizontal * 28,
              decoration: new BoxDecoration(
                color: selectedEmployee == items2[x].uid
                    ? ThemeColor.accentCyanColor.withOpacity(0.2)
                    : ThemeColor.blueGreyColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
              child: Column(
                children: <Widget>[
                  SizeConfig.extraSmallVerticalBox,
                  Icon(
                    Icons.perm_identity,
                    color: selectedEmployee == items2[x].uid
                        ? ThemeColor.accentCyanColor
                        : ThemeColor.blueGreyColor,
                    size: SizeConfig.ultraLarge,
                  ),
                  Text('${items2[x].firstName} ${items2[x].lastName}',
                      style: extraSmallTextStyle(
                        color: selectedEmployee == items2[x].uid
                            ? ThemeColor.themeBlueColor
                            : ThemeColor.blueGreyColor,
                      )),
                  extraSmallTitleText(
                      text: '${items2[x].jobTitle}',
                      color: selectedEmployee == items2[x].uid
                          ? ThemeColor.blackColor
                          : ThemeColor.blueGreyColor),
                ],
              ))));
    }
    return temp;
  }

  Future<void> readStudentStatus() async {
    try {
      DocumentSnapshot documentSnapshot =
          await student.doc('$selectedStudent/attendance/$date').get();
      if (documentSnapshot.exists) {
        setState(() {
          studentStatus = documentSnapshot.data()['status'];
        });
      } else {
        setState(() {
          studentStatus = 'absent';
        });
      }
    } catch (e) {
      _studentKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Connection failed. Please check your connection',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }

  Future<void> updateStudentStatus() async {
    try {
      if(studentStatus!=preStudentStatus) {
        switch(preStudentStatus){
          case 'present':
            kindergartenProfile.studentPresent=kindergartenProfile.studentPresent-1;
            break;
          case 'late':
            kindergartenProfile.studentLate = kindergartenProfile.studentLate-1;
            break;
          case 'leave':
            kindergartenProfile.studentLeave = kindergartenProfile.studentLeave-1;
            break;
          default:
            kindergartenProfile.studentAbsent = kindergartenProfile.studentAbsent-1;
        }
        switch(studentStatus){
          case 'present':
            kindergartenProfile.studentPresent=kindergartenProfile.studentPresent+1;
            break;
          case 'late':
            kindergartenProfile.studentLate = kindergartenProfile.studentLate+1;
            break;
          case 'leave':
            kindergartenProfile.studentLeave = kindergartenProfile.studentLeave+1;
            break;
          default:
            kindergartenProfile.studentAbsent = kindergartenProfile.studentAbsent+1;
        }

        if(studentStatus=='absent'){
          await student
              .doc('$selectedStudent/attendance/$date')
              .set({
            'checkInStatus':0,
            'status':studentStatus,
            'datetime':DateTime.now()
          });
        }
        else{
          await student
              .doc('$selectedStudent/attendance/$date')
              .update({
              'status': studentStatus,
            'datetime': DateTime.now()},
          );
        }

        await kindergarten.doc(kindergartenProfile.name).update({
          'student present': kindergartenProfile.studentPresent,
          'student absent':kindergartenProfile.studentAbsent,
          'student late': kindergartenProfile.studentLate,
          'student leave': kindergartenProfile.studentLeave
        });
      }
      _studentKey.currentState.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
          content: Text(
            'Attendance status is updated successfully.',
            style: extraSmallTextStyle(color: ThemeColor.whiteColor),
          )));
    } catch (e) {
      _studentKey.currentState.showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Connection failed. Status cannot be updated.',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }

  Future<void> readEmployeeStatus() async {
    try {
      DocumentSnapshot documentSnapshot =
          await employee.doc('$selectedEmployee/attendance/$date').get();
      if (documentSnapshot.exists) {
        setState(() {
          employeeStatus = documentSnapshot.data()['status'];
        });
      } else {
        setState(() {
          employeeStatus = 'absent';
        });
      }
    } catch (e) {
      _employeeKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Connection failed. Please check your connection',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }

  Future<void> updateEmployeeStatus() async {
    try {
      if(employeeStatus!=preEmployeeStatus) {
        switch (preEmployeeStatus) {
          case 'present':
            kindergartenProfile.employeePresent =
                kindergartenProfile.employeePresent - 1;
            break;
          case 'late':
            kindergartenProfile.employeeLate =
                kindergartenProfile.employeeLate - 1;
            break;
          case 'leave':
            kindergartenProfile.employeeLeave =
                kindergartenProfile.employeeLeave - 1;
            break;
          default:
            kindergartenProfile.employeeAbsent =
                kindergartenProfile.employeeAbsent - 1;
        }
        switch (employeeStatus) {
          case 'present':
            kindergartenProfile.employeePresent =
                kindergartenProfile.employeePresent + 1;
            break;
          case 'late':
            kindergartenProfile.employeeLate =
                kindergartenProfile.employeeLate + 1;
            break;
          case 'leave':
            kindergartenProfile.employeeLeave =
                kindergartenProfile.employeeLeave +1;
            break;
          default:
            kindergartenProfile.employeeAbsent =
                kindergartenProfile.employeeAbsent + 1;
        }
        if(employeeStatus=='absent'){
          await employee
              .doc('$selectedEmployee/attendance/$date')
              .set({
                  'checkInStatus':0,
                  'status': employeeStatus,
                  'datetime': DateTime.now()});

        }else {
          await employee
              .doc('$selectedEmployee/attendance/$date')
              .update({'status': employeeStatus, 'datetime': DateTime.now()});
        }
        await kindergarten.doc(kindergartenProfile.name).update({
          'employee present': kindergartenProfile.employeePresent,
          'employee absent':kindergartenProfile.employeeAbsent,
          'employee late': kindergartenProfile.employeeLate,
          'employee leave': kindergartenProfile.employeeLeave
        });
      }
      _employeeKey.currentState.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
          content: Text(
            'Attendance status is updated successfully.',
            style: extraSmallTextStyle(color: ThemeColor.whiteColor),
          )));
    } catch (e) {
      _employeeKey.currentState.showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Connection failed. Status cannot be updated.',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }

  Widget studentTabView() {
    return RefreshIndicator(
        onRefresh: () async {
          items.clear();
          students.clear();
          setState(() {
            prepareData();
          });
        },
        child: Scaffold(
          backgroundColor: ThemeColor.whiteColor,
          key: _studentKey,
          body: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top:SizeConfig.small,left: SizeConfig.small, right: SizeConfig.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Manage Student Attendance',
                          style:
                              smallTextStyle(color: ThemeColor.themeBlueColor),
                        ),
                        SizeConfig.mediumHorizontalBox,
                        KiButton.smallButton(
                            child: Icon(
                              Icons.info,
                              color: ThemeColor.themeBlueColor,
                              size: SizeConfig.medium,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      InfoMessageDialog(
                                        info:
                                            'Single tap to view and update attendance status. Long press to view detailed attendance record.',
                                      ));
                            })
                      ],
                    ),
                    SizeConfig.ultraSmallVerticalBox,
                    Text(
                      'Swipe down to refresh',
                      style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.extraSmall,
                          horizontal: SizeConfig.smaller),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: ThemeColor.lightBlueGreyColor,
                              width: 1.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Present',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.studentPresent.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Late',
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.studentLate.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Absent',
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.studentAbsent.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Leave',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.studentLeave.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizeConfig.ultraSmallVerticalBox,
                    Padding(
                      padding: EdgeInsets.all(SizeConfig.extraSmall),
                      child: KiTextField.borderedTextFormField(
                          controller: searchStudentController,
                          titleText: 'Search',
                          hintText: 'Search student name, age',
                          maxLines: 1,
                          onChanged: (value) {
                            filterSearchResults(value);
                          },
                          hintStyle:
                              smallerTextStyle(color: ThemeColor.blueGreyColor),
                          activeBorderColor: ThemeColor.themeBlueColor,
                          borderColor: ThemeColor.blueGreyColor,
                          radius: 25.0,
                          textStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor),
                          labelStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor)),
                    ),
                    kindergartenProfile.studentFirstName.length == 0
                        ? Container(
                            height: SizeConfig.safeBlockVertical * 30,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'No Student',
                                    style: smallTextStyle(
                                        color: ThemeColor.blueGreyColor),
                                  ),
                                  Text(
                                    'Please add new student',
                                    style: smallTextStyle(
                                        color: ThemeColor.blueGreyColor),
                                  )
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              Wrap(
                                runSpacing: SizeConfig.safeBlockVertical,
                                spacing: SizeConfig.blockSizeHorizontal * 1.2,
                                children: buildStudentChildren(),
                              ),
                              SizeConfig.largeVerticalBox
                            ],
                          ),
                  ],
                ),
              )),
          floatingActionButton: FloatingActionButton(
            heroTag: "student attendance float",
            backgroundColor: ThemeColor.themeBlueColor,
            child: Icon(
              Icons.face,
              color: ThemeColor.whiteColor,
              size: SizeConfig.extraLarge,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=> FaceRecognitionHomePage()
              ));
            },
          ),
          bottomNavigationBar: BottomAppBar(
              elevation: 0.0,
              color: ThemeColor.whiteColor,
              child: !studentShowBottom || studentIsLoading
                  ? SizeConfig.extraSmallVerticalBox
                  : ToggleSwitch(
                      minWidth: SizeConfig.safeBlockHorizontal * 30,
                      minHeight: SizeConfig.safeBlockVertical * 6,
                      fontSize: SizeConfig.smaller,
                      initialLabelIndex: statusToIndex[studentStatus],
                      activeBgColor: ThemeColor.accentCyanColor,
                      activeFgColor: ThemeColor.themeBlueColor,
                      inactiveBgColor: ThemeColor.lightBlueColor,
                      inactiveFgColor: ThemeColor.blueGreyColor,
                      labels: ['PRESENT', 'LATE', 'ABSENT', 'LEAVE'],
                      onToggle: (index) async {
                        setState(() {
                          studentIsLoading=true;
                        });
                        preStudentStatus = studentStatus;
                        studentStatus = states[index];
                        await updateStudentStatus();
                        setState(() {
                          studentIsLoading=false;
                        });
                      },
                    )),
        ));
  }

  Widget employeeTabView() {
    return RefreshIndicator(
        onRefresh: () async {
          items2.clear();
          employees.clear();
          setState(() {
            prepareData2();
          });
        },
        child: Scaffold(
          key: _employeeKey,
          backgroundColor: ThemeColor.whiteColor,
          body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
                padding: EdgeInsets.only(top:SizeConfig.small,left: SizeConfig.small, right: SizeConfig.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Manage Employee Attendance',
                          style:
                              smallTextStyle(color: ThemeColor.themeBlueColor),
                        ),
                        SizeConfig.mediumHorizontalBox,
                        KiButton.smallButton(
                            child: Icon(
                              Icons.info,
                              color: ThemeColor.themeBlueColor,
                              size: SizeConfig.medium,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      InfoMessageDialog(
                                        info: 'Single tap to view and update attendance status. Long press to view detailed attendance record.',
                                      ));
                            })
                      ],
                    ),
                    SizeConfig.ultraSmallVerticalBox,
                    Text(
                      'Swipe down to refresh',
                      style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.extraSmall,
                          horizontal: SizeConfig.smaller),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: ThemeColor.lightBlueGreyColor,
                              width: 1.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Present',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.employeePresent.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Late',
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.employeeLate.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Absent',
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.employeeAbsent.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.redColor),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Leave',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                                kindergartenProfile.employeeLeave.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizeConfig.ultraSmallVerticalBox,
                    Padding(
                      padding: EdgeInsets.all(SizeConfig.extraSmall),
                      child: KiTextField.borderedTextFormField(
                          controller: searchEmployeeController,
                          titleText: 'Search',
                          hintText: 'Search employee name, job title',
                          maxLines: 1,
                          onChanged: (value) {
                            filterSearchResults2(value);
                          },
                          hintStyle:
                              smallerTextStyle(color: ThemeColor.blueGreyColor),
                          activeBorderColor: ThemeColor.themeBlueColor,
                          borderColor: ThemeColor.blueGreyColor,
                          radius: 25.0,
                          textStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor),
                          labelStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor)),
                    ),
                    kindergartenProfile.employeeFirstName.length == 0
                        ? Container(
                            height: SizeConfig.safeBlockVertical * 30,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'No Employee',
                                    style: smallTextStyle(
                                        color: ThemeColor.blueGreyColor),
                                  ),
                                  Text(
                                    'Please add new employee',
                                    style: smallTextStyle(
                                        color: ThemeColor.blueGreyColor),
                                  )
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              Wrap(
                                spacing: SizeConfig.blockSizeHorizontal * 1.2,
                                runSpacing: SizeConfig.safeBlockVertical,
                                children: buildEmployeeChildren(),
                              ),
                              SizeConfig.mediumVerticalBox
                            ],
                          ),
                  ],
                )),
          ),
          bottomNavigationBar: BottomAppBar(
              elevation: 0.0,
              color: ThemeColor.whiteColor,
              child: !employeeShowBottom || employeeIsLoading
                  ? SizeConfig.extraSmallVerticalBox
                  : ToggleSwitch(
                      minWidth: SizeConfig.safeBlockHorizontal * 30,
                      minHeight: SizeConfig.safeBlockVertical * 6,
                      fontSize: SizeConfig.smaller,
                      initialLabelIndex: statusToIndex[employeeStatus],
                      activeBgColor: ThemeColor.accentCyanColor,
                      activeFgColor: ThemeColor.themeBlueColor,
                      inactiveBgColor: ThemeColor.lightBlueColor,
                      inactiveFgColor: ThemeColor.blueGreyColor,
                      labels: ['PRESENT', 'LATE', 'ABSENT', 'LEAVE'],
                      onToggle: (index) async {
                        setState(() {
                          employeeIsLoading=true;
                        });
                        preEmployeeStatus =employeeStatus;
                        employeeStatus = states[index];
                        await updateEmployeeStatus();
                        setState(() {
                          employeeIsLoading=false;
                        });
                      },
                    )),
        ));
  }

  void filterSearchResults2(String query) {
    List<EmployeeAccounts> dummySearchList = new List.from([]);
    dummySearchList.addAll(employees);
    if (query.isNotEmpty) {
      List<EmployeeAccounts> dummyListData = new List.from([]);
      for (EmployeeAccounts item in dummySearchList) {
        if ((item.firstName).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if (item.lastName.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if (item.jobTitle.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }

      setState(() {
        items2.clear();
        items2.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items2.clear();
        items2.addAll(employees);
      });
    }
  }

  void filterSearchResults(String query) {
    List<Student> dummySearchList = new List.from([]);
    dummySearchList.addAll(students);
    if (query.isNotEmpty) {
      List<Student> dummyListData = new List.from([]);
      for (Student item in dummySearchList) {
        if ((item.firstName).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if ('${item.lastName}'
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if (item.age.toString().contains(query)) {
          dummyListData.add(item);
        }
      }

      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(students);
      });
    }
  }
}
