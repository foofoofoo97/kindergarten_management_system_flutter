import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/face_recognition/face_recognition_home_page.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/owner_function_pages/manage_attendance/check_in_student_attendance_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/info_message_dialog.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ManageStudentAttendancePage extends StatefulWidget {
  @override
  _ManageStudentAttendancePageState createState() =>
      _ManageStudentAttendancePageState();
}

class _ManageStudentAttendancePageState
    extends State<ManageStudentAttendancePage> {
  final GlobalKey<ScaffoldState> _studentKey = new GlobalKey<ScaffoldState>();
  CollectionReference student =
      FirebaseFirestore.instance.collection('student');
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  bool studentIsLoading;
  bool studentShowBottom;

  TextEditingController searchStudentController = new TextEditingController();

  String preStudentStatus;

  Map statusToIndex = {'present': 0, 'late': 1, 'absent': 2, 'leave': 3};
  List<String> states = ['present', 'late', 'absent', 'leave'];

  List<Student> items = List.from([]);
  List<Student> students = List.from([]);

  String studentStatus;
  String selectedStudent;

  DateTime today;
  String date;

  DateFormat formatter = DateFormat('dd MMM yyy');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  @override
  void initState() {
    // TODO: implement initState
    studentShowBottom = false;
    studentIsLoading = false;

    today = DateTime.now();
    date = '${today.day}-${today.month}-${today.year}';

    prepareData();
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

  Future<void> condition() async {
    bool update = false;
    if (kindergartenProfile.studentAttendanceCheck !=
        formatter.format(DateTime.now())) {
      await initStudentAttendance();

      kindergartenProfile.studentAttendanceCheck =
          formatter.format(DateTime.now());
      update = true;
    }

    if (update) {
      kindergarten.doc(kindergartenProfile.name).update({
        'employee absent': kindergartenProfile.studentUID.length,
        'employee present': 0,
        'employee late': 0,
        'employee leave': 0,
        'student absent': kindergartenProfile.studentAbsent.length,
        'student present': 0,
        'student late': 0,
        'student leave': 0,
        'employee attendance check':
            kindergartenProfile.employeeAttendanceCheck,
        'student attendance check': kindergartenProfile.studentAttendanceCheck
      });
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
        RefreshIndicator(
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
                    padding: EdgeInsets.all(SizeConfig.small),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Manage Student Attendance',
                              style: smallTextStyle(
                                  color: ThemeColor.themeBlueColor),
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
                                    kindergartenProfile.studentPresent
                                        .toString(),
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
                                    kindergartenProfile.studentAbsent
                                        .toString(),
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
                              hintStyle: smallerTextStyle(
                                  color: ThemeColor.blueGreyColor),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    spacing:
                                        SizeConfig.blockSizeHorizontal * 1.2,
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
                    builder: (context)=>FaceRecognitionHomePage()
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
                            preStudentStatus = studentStatus;
                            studentStatus = states[index];
                            await updateStudentStatus();
                          },
                        )),
            )),
        studentIsLoading
            ? Center(
                child: SizedBox(
                  height: SizeConfig.safeBlockVertical * 5,
                  width: SizeConfig.safeBlockVertical * 5,
                  child: CircularProgressIndicator(
                    backgroundColor: ThemeColor.whiteColor,
                  ),
                ),
              )
            : Container(),
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
      if (studentStatus != preStudentStatus) {
        switch (preStudentStatus) {
          case 'present':
            kindergartenProfile.studentPresent =
                kindergartenProfile.studentPresent - 1;
            break;
          case 'late':
            kindergartenProfile.studentLate =
                kindergartenProfile.studentLate - 1;
            break;
          case 'leave':
            kindergartenProfile.studentLeave =
                kindergartenProfile.studentLeave - 1;
            break;
          default:
            kindergartenProfile.studentAbsent =
                kindergartenProfile.studentAbsent - 1;
        }
        switch (studentStatus) {
          case 'present':
            kindergartenProfile.studentPresent =
                kindergartenProfile.studentPresent + 1;
            break;
          case 'late':
            kindergartenProfile.studentLate =
                kindergartenProfile.studentLate + 1;
            break;
          case 'leave':
            kindergartenProfile.studentLeave =
                kindergartenProfile.studentLeave + 1;
            break;
          default:
            kindergartenProfile.studentAbsent =
                kindergartenProfile.studentAbsent + 1;
        }
        await student
            .doc('$selectedStudent/attendance/$date')
            .update({'status': studentStatus, 'datetime': DateTime.now()});

        await kindergarten.doc(kindergartenProfile.name).update({
          'student present': kindergartenProfile.studentPresent,
          'student absent': kindergartenProfile.studentAbsent,
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
