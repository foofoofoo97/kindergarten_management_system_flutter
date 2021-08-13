import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/face_recognition/add_new_face_page.dart';
import 'package:kiki/face_recognition/db/database.dart';
import 'package:kiki/face_recognition/services/facenet.service.dart';
import 'package:flutter/material.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/owner_function_pages/manage_attendance/check_in_student_attendance_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class User {
  String uid;
  String name;

  User({@required this.uid, @required this.name});

  static User fromDB(String dbuser) {
    return new User(uid: dbuser.split(':')[0], name: dbuser.split(':')[1]);
  }
}

class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {@required this.onPressed,
      @required this.onChecking,
      @required this.isLogin});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final Function onChecking;
  final bool isLogin;

  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  CollectionReference student =
      FirebaseFirestore.instance.collection('student');
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  User predictedUser;
  bool checkedIn;
  int status;
  String statuses;

  Future _signUp2(context, String uid, String name) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;

    /// creates a new user in the 'database'
    await _dataBaseService.saveData(uid, name, predictedData);

    /// resets the face stored in the face net sevice
    this._faceNetService.setPredictedData(null);
  }

  String _predictUser() {
    String userAndPass = _faceNetService.predict();
    return userAndPass ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: widget.isLogin ? Text('Check In') : Text('Add Face'),
      icon: Icon(Icons.camera_alt),
      // Provide an onPressed callback.
      onPressed: () async {
        try {
          // Ensure that the camera is initialized.
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          bool faceDetected = await widget.onPressed();

          if (faceDetected) {
             if (widget.isLogin) {
              var userAndPass = _predictUser();
              if (userAndPass != null) {
                this.predictedUser = User.fromDB(userAndPass);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>CheckInStudentAttendancePage(
                    index: kindergartenProfile.studentUID.indexOf(predictedUser.uid),
                    type: 2,
                  )
                ));
              }
              else{
                Scaffold.of(context).showBottomSheet((context) => signSheet(context));
              }
            }
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
    );
  }

  Future<void> addAttendance(String uid) async {
    DateTime today = DateTime.now();
    int day = today.day;
    int month = today.month;
    int year = today.year;
    String date = '$day-$month-$year';
    String attendanceStatus;

    if (today.hour < kindergartenProfile.startWorkHours) {
      attendanceStatus = 'present';
    } else if (today.hour == kindergartenProfile.startWorkHours) {
      if (today.minute >= kindergartenProfile.startWorkMinutes)
        attendanceStatus = 'late';
      else
        attendanceStatus = 'present';
    } else {
      attendanceStatus = 'late';
    }

    await student.doc(uid).collection('attendance').doc(date).set({
      'check in min': today.minute,
      'check in hrs': today.hour,
      'check in datetime': today,
      'datetime': today,
      'status': attendanceStatus,
      'checkInStatus': 1
    });

    kindergartenProfile.studentAbsent = kindergartenProfile.studentAbsent - 1;
    if (attendanceStatus == 'late') {
      kindergartenProfile.studentLate = kindergartenProfile.studentLate + 1;
    } else {
      kindergartenProfile.studentPresent = kindergartenProfile.studentPresent + 1;
    }

    await kindergarten.doc(kindergartenProfile.name).update({
      'student absent': kindergartenProfile.studentAbsent,
      'student present': kindergartenProfile.studentPresent,
      'student late': kindergartenProfile.studentLate
    });

    statuses=attendanceStatus;
  }

  Future<void> addAttendance2(String uid) async {
    DateTime today = DateTime.now();
    int day = today.day;
    int month = today.month;
    int year = today.year;
    String date = '$day-$month-$year';

    await student.doc(uid).collection('attendance').doc(date).update({
      'check out min': today.minute,
      'check out hrs': today.hour,
      'check out datetime': today,
      'checkInStatus': 2
    });
  }

  signSheet(context) {
    try {
      return Container(
          padding: EdgeInsets.all(SizeConfig.small),
          height: 300,
          child: Stack(
            children: <Widget>[
              Column(
                children: [
                  widget.isLogin && predictedUser != null
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Student Detected: ' + predictedUser.name,
                            style: mediumSTextStyle(
                                color: ThemeColor.themeBlueColor),
                          ),
                        )
                      : widget.isLogin
                          ? Container(
                              alignment: Alignment.center,
                              child: Column(children: <Widget>[
                                SizeConfig.mediumVerticalBox,
                                Text(
                                  'Sorry, student face cannot be recognised',
                                  style: mediumSTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                ),
                                SizeConfig.mediumVerticalBox,
                                KiButton.rectButton(
                                    child: Text(
                                      'Add New Face',
                                      style: smalllTextStyle(
                                          color: ThemeColor.whiteColor),
                                    ),
                                    color: ThemeColor.blueColor,
                                    onPressed: () async {
                                      Map<String, dynamic> data =
                                          await _dataBaseService.loadDB();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddNewFacePage(
                                                    data: data ?? new Map(),
                                                    onPressed1: (uid, name) async {
                                                      await _signUp2(
                                                          context, uid, name);

                                                      await addAttendance(uid);

                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              '$name has checked in as ${statuses.toUpperCase()}',
                                                          fontSize: SizeConfig
                                                              .smaller,
                                                          textColor: ThemeColor
                                                              .whiteColor,
                                                          backgroundColor:
                                                              ThemeColor
                                                                  .themeBlueColor);
                                                    },
                                                    onPressed2:
                                                        (uid, name) async {
                                                      await _signUp2(
                                                          context, uid, name);
                                                      await addAttendance2(uid);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Fluttertoast.showToast(
                                                          msg:
                                                          '$name has been checked out',
                                                          fontSize: SizeConfig
                                                              .smaller,
                                                          textColor: ThemeColor
                                                              .whiteColor,
                                                          backgroundColor:
                                                          ThemeColor
                                                              .themeBlueColor);
                                                    },
                                                    onPressed:
                                                        (uid, name) async {
                                                      await _signUp2(
                                                          context, uid, name);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              '$name faceID is added',
                                                          fontSize: SizeConfig
                                                              .smaller,
                                                          textColor: ThemeColor
                                                              .whiteColor,
                                                          backgroundColor:
                                                              ThemeColor
                                                                  .themeBlueColor);
                                                    },
                                                  )));
                                    })
                              ]))
                          : Container(),
                  SizeConfig.mediumVerticalBox,
                  widget.isLogin && predictedUser != null &&statuses!='leave'
                      ? KiButton.rectButton(
                          color: ThemeColor.blueColor,
                          child: Text(
                            status == 0
                                ? 'Check In'
                                : status == 1 ? 'Check Out' : 'Checked Out',
                            style:
                                smalllTextStyle(color: ThemeColor.whiteColor),
                          ),
                          onPressed: status == 2
                              ? () {}
                              : () async {
                                  widget.onChecking(true);
                                  if (status == 0) {
                                    await addAttendance(predictedUser.uid);
                                  } else {
                                    await addAttendance2(predictedUser.uid);
                                  }
                                  widget.onChecking(false);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: 'Student attendance is recorded',
                                      fontSize: SizeConfig.smaller,
                                      textColor: ThemeColor.whiteColor,
                                      backgroundColor:
                                          ThemeColor.themeBlueColor);
                                },
                        )
                      : Container(),
                  widget.isLogin && predictedUser != null && status == 2
                      ? Text(
                          'Today Attendance Has Been Recorded',
                          style:
                              smallererTextStyle(color: ThemeColor.blueColor),
                        )
                      : Container(),
                ],
              ),
            ],
          ));
    } catch (e, s) {
      print(s);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
