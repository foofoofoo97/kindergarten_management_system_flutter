import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/employee_function_pages/employee_dashboard.dart';
import 'package:kiki/employee_function_pages/employee_attendance_page.dart';
import 'package:kiki/employee_function_pages/employee_manage_performance_page.dart';
import 'package:kiki/employee_function_pages/employee_manage_posts_page.dart';
import 'package:kiki/employee_function_pages/employee_manage_results_page.dart';
import 'package:kiki/employee_function_pages/employee_manage_student_attendance_page.dart';
import 'package:kiki/employee_function_pages/manage_personal_account.dart';
import 'package:kiki/chatroom_pages/employee_search_receiver_page.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/services/authentication.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class MainEmployeePage extends StatefulWidget {
  VoidCallback logoutCallback;
  VoidCallback switchCallback;
  VoidCallback employeeCallback;
  String uid;
  BaseAuth auth;

  MainEmployeePage(
      {this.uid, this.auth, this.employeeCallback,this.logoutCallback, this.switchCallback});

  @override
  _MainEmployeePageState createState() => _MainEmployeePageState();
}

class _MainEmployeePageState extends State<MainEmployeePage> {
  CollectionReference employee =
      FirebaseFirestore.instance.collection('employee');
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  EmployeeProfile employeeProfile = new EmployeeProfile();
  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    init();

    super.initState();
  }

  Future<void> init() async {
    DocumentSnapshot userSnapshot = await employee.doc(widget.uid).get();
    Map userData = userSnapshot.data();
    employeeProfile.uid = widget.uid;
    employeeProfile.homeAddress = userData['home address'];
    employeeProfile.firstName = userData['first name'];
    employeeProfile.lastName = userData['last name'];
    employeeProfile.contactNo = userData['contact no'];
    employeeProfile.kindergarten = userData['kindergarten'];
    employeeProfile.jobTitle = userData['job title'];
    employeeProfile.status = userData['status'];

    setState(() {
      isLoading = false;
    });
  }

  void initKindergarten(Map data) {
    kindergartenProfile.name = data['name'];
    kindergartenProfile.contactNo = data['contact no'];
    kindergartenProfile.address = data['address'];
    kindergartenProfile.startStudyHours = data['start study hrs'];
    kindergartenProfile.startStudyMinutes = data['start study min'];
    kindergartenProfile.startWorkHours = data['start work hrs'];
    kindergartenProfile.startWorkMinutes = data['start work min'];

    kindergartenProfile.feesType = Map.from(data['fees type'] ?? new Map());

    kindergartenProfile.employeeUID =
        List.from(data['employee uid'] ?? new List.from([]));
    kindergartenProfile.ownerUID = List.from(data['owner uid'] ?? new List.from([]));
    kindergartenProfile.employeeFirstName =
        List.from(data['employee first name'] ?? new List.from([]));
    kindergartenProfile.employeeLastName =
        List.from(data['employee last name'] ?? new List.from([]));
    kindergartenProfile.employeeJobTitle =
        List.from(data['employee job title'] ?? new List.from([]));

    kindergartenProfile.canResults =
        List.from(data['can results'] ?? new List.from([]));
    kindergartenProfile.canPerformance =
        List.from(data['can performance'] ?? new List.from([]));
    kindergartenProfile.canPosts = List.from(data['can posts'] ?? new List.from([]));
    kindergartenProfile.canAttendance =
        List.from(data['can attendance'] ?? new List.from([]));

    kindergartenProfile.pendingEmployeeUID =
        List.from(data['pending employee uid'] ?? new List.from([]));
    kindergartenProfile.pendingStudentUID =
        List.from(data['pending student uid'] ?? new List.from([]));

    kindergartenProfile.studentUID =
        List.from(data['student uid'] ?? new List.from([]));
    kindergartenProfile.studentFirstName =
        List.from(data['student first name'] ?? new List.from([]));
    kindergartenProfile.studentLastName =
        List.from(data['student last name'] ?? new List.from([]));
    kindergartenProfile.studentAge =
        List.from(data['student age'] ?? new List.from([]));

    kindergartenProfile.studentCourse =
        Map.from(data['student course'] ?? new Map());
    kindergartenProfile.employeeAttendanceCheck =
        data['employee attendance check'] == null
            ? null
            : data['employee attendance check'];
    kindergartenProfile.studentAttendanceCheck =
        data['student attendance check'] == null
            ? null
            : data['student attendance check'];

    kindergartenProfile.employeePresent = data['employee present'] ?? 0;
    kindergartenProfile.employeeLate = data['employee late'] ?? 0;
    kindergartenProfile.employeeLeave = data['employee leave'] ?? 0;
    kindergartenProfile.employeeAbsent = data['employee absent'] ?? 0;

    kindergartenProfile.studentPresent = data['student present'] ?? 0;
    kindergartenProfile.studentLate = data['student late'] ?? 0;
    kindergartenProfile.studentLeave = data['student leave'] ?? 0;
    kindergartenProfile.studentAbsent = data['student absent'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: ThemeColor.whiteColor,
            child: Center(
              child: SizedBox(
                height: SizeConfig.safeBlockVertical * 5,
                width: SizeConfig.safeBlockVertical * 5,
                child: CircularProgressIndicator(
                  backgroundColor: ThemeColor.whiteColor,
                ),
              ),
            ),
          )
        : employeeProfile.status == 0
            ? KiCenterPage(
                color: ThemeColor.whiteColor,
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.verified_user,
                        size: SizeConfig.extraLarge * 2,
                        color: ThemeColor.blueColor,
                      ),
                      SizeConfig.mediumVerticalBox,
                      Text(
                        'Waiting For Verification',
                        style: largeTextStyle(color: ThemeColor.themeBlueColor),
                      ),
                      SizeConfig.smallVerticalBox,
                      Text(
                        'Please Wait A While..',
                        style: smallTextStyle(color: ThemeColor.themeBlueColor),
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      Text(
                        'Your Account Has No Yet Verified By Kindergarten Owner',
                        style: smallTextStyle(color: ThemeColor.themeBlueColor),
                        textAlign: TextAlign.center,
                      ),
                      SizeConfig.largeVerticalBox,
                      KiButton.rectButton(
                          child: Text(
                            'Sign Out',
                            style: smallTextStyle(color: ThemeColor.whiteColor),
                          ),
                          color: ThemeColor.blueColor,
                          onPressed: () {
                            widget.logoutCallback();
                          }),
                      SizeConfig.largeVerticalBox
                    ],
                  ),
                ),
              )
            : employeeProfile.status == -1
                ? KiCenterPage(
                    color: ThemeColor.whiteColor,
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.verified_user,
                            size: SizeConfig.extraLarge * 2,
                            color: ThemeColor.redColor,
                          ),
                          SizeConfig.mediumVerticalBox,
                          Text(
                            'Failed Verification',
                            style: largeTextStyle(
                                color: ThemeColor.redColor),
                          ),
                          SizeConfig.extraLargeVerticalBox,
                          Text(
                            'Your Account Has Been Rejected By Kindergarten Owner',
                            style: smallTextStyle(
                                color: ThemeColor.themeBlueColor),
                            textAlign: TextAlign.center,
                          ),
                          SizeConfig.largeVerticalBox,
                          KiButton.rectButton(
                              child: Text('Apply New Kindergarten',style: smallTextStyle(color: ThemeColor.whiteColor),),
                            color: ThemeColor.themeBlueColor,
                            onPressed: ()async{
                              await employee.doc(widget.uid).delete();
                              widget.employeeCallback();
                            }
                          ),
                          KiButton.rectButton(
                              child: Text(
                                'Sign Out',
                                style: smallTextStyle(
                                    color: ThemeColor.whiteColor),
                              ),
                              color: ThemeColor.blueColor,
                              onPressed: () {
                                widget.logoutCallback();
                              }),
                          SizeConfig.largeVerticalBox
                        ],
                      ),
                    ),
                  )
                : StreamBuilder<DocumentSnapshot>(
                    stream: kindergarten
                        .doc(employeeProfile.kindergarten)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
                      if (!documentSnapshot.hasData) {
                        return Container(
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
                        );
                      } else if (documentSnapshot.hasError) {
                        Fluttertoast.showToast(
                            msg: 'Failed to connect database',
                            backgroundColor: ThemeColor.themeBlueColor,
                            textColor: ThemeColor.whiteColor,
                            fontSize: SizeConfig.smaller);
                        return Container(
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
                        );
                      }
                      Map data = documentSnapshot.data.data();
                      initKindergarten(data);

                      return MaterialApp(
                          home: DefaultTabController(
                              length: 5,
                              child: Scaffold(
                                  appBar: AppBar(
                                    backgroundColor: ThemeColor.themeBlueColor,
                                    bottom: TabBar(
                                      indicatorColor:
                                          ThemeColor.accentCyanColor,
                                      unselectedLabelColor:
                                          ThemeColor.whiteColor,
                                      labelColor: ThemeColor.accentCyanColor,
                                      labelStyle: TextStyle(
                                          fontFamily: 'PatrickHand',
                                          fontSize: SizeConfig.extraSmall),
                                      isScrollable: true,
                                      tabs: [
                                        Tab(
                                          child: Text(
                                            'Dashboard',
                                            style:
                                                TextStyle(letterSpacing: 1.2),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            'Attendance',
                                            style:
                                                TextStyle(letterSpacing: 1.2),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            'Posts',
                                            style:
                                                TextStyle(letterSpacing: 1.2),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            'Results',
                                            style:
                                                TextStyle(letterSpacing: 1.2),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            'Performance',
                                            style:
                                                TextStyle(letterSpacing: 1.2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: largeTitleText(
                                        text: 'KIKI Employee',
                                        color: ThemeColor.whiteColor),
                                  ),
                                  body: TabBarView(
                                    children: [
                                      EmployeeDashboardPage(),
                                      EmployeeManageStudentAttendancePage(),
                                      EmployeeManagePostsPage(),
                                      EmployeeManageResultsPage(),
                                      EmployeeManagePerformancePage(),
                                    ],
                                  ),
                                  drawer: Drawer(
                                    child: ListView(
                                      // Important: Remove any padding from the ListView.
                                      padding: EdgeInsets.zero,
                                      children: <Widget>[
                                        DrawerHeader(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              CircleAvatar(
                                                child: Icon(
                                                  Icons.person,
                                                  color: ThemeColor.whiteColor,
                                                  size: SizeConfig
                                                          .safeBlockVertical *
                                                      6,
                                                ),
                                                backgroundColor:
                                                    ThemeColor.blueColor,
                                                radius: SizeConfig
                                                        .safeBlockVertical *
                                                    4,
                                              ),
                                              SizeConfig.mediumVerticalBox,
                                              Text(
                                                  '${employeeProfile.firstName} ${employeeProfile.lastName}',
                                                  style: mediumLargeTextStyle(
                                                      color: ThemeColor
                                                          .blueColor)),
                                              SizeConfig.smallVerticalBox
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            color: ThemeColor.themeBlueColor,
                                          ),
                                        ),
                                        SizeConfig.largeVerticalBox,
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: SizeConfig.extraSmall),
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(
                                                title: Text(
                                                    'Check In Check Out',
                                                    style: smallTextStyle(
                                                        color: ThemeColor
                                                            .themeBlueColor)),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EmployeeAttendancePage(
                                                                  uid: widget
                                                                      .uid)));
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Chat Room',
                                                    style: smallTextStyle(
                                                        color: ThemeColor
                                                            .themeBlueColor)),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EmployeeSearchReceiverPage()));
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Personal Account',
                                                    style: smallTextStyle(
                                                        color: ThemeColor
                                                            .themeBlueColor)),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ManageEmployeePersonalAccount()));
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Switch Account',
                                                    style: smallTextStyle(
                                                        color: ThemeColor
                                                            .blueColor)),
                                                onTap: () {
                                                  widget.switchCallback();
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Sign Out',
                                                    style: smallTextStyle(
                                                        color: ThemeColor
                                                            .redColor)),
                                                onTap: () {
                                                  widget.logoutCallback();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))));
                    });
  }
}
