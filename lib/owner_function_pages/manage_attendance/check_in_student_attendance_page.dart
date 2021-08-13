import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/owner_function_pages/manage_attendance/view_student_attendance_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class CheckInStudentAttendancePage extends StatefulWidget {
  int index;
  int type;
  CheckInStudentAttendancePage({this.index,this.type});
  @override
  _CheckInStudentAttendancePageState createState() => _CheckInStudentAttendancePageState();
}

class _CheckInStudentAttendancePageState extends State<CheckInStudentAttendancePage> {

  String buttonText;
  CollectionReference student = FirebaseFirestore.instance.collection('student');
  CollectionReference kindergarten =
  FirebaseFirestore.instance.collection('kindergarten');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  DateTime today = DateTime.now();
  int day;
  int month;
  int year;
  bool isLoading;
  String date;
  String attendanceStatus;
  String checkInTime;
  String checkOutTime;
  String loading;
  DateFormat timeFormat = DateFormat('kk:mm');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buttonText = 'NOT AVAILABLE';
    day = today.day;
    month = today.month;
    year = today.year;
    date = '$day-$month-$year';
    isLoading = true;
    loading = 'Retrieving GPS location';
    getToday();
  }


  Future<void> getToday() async {
    DocumentSnapshot documentSnapshot =
    await student.doc(kindergartenProfile.studentUID[widget.index]).collection('attendance').doc(date).get();
    Map data = documentSnapshot.data();
    if (!documentSnapshot.exists || data['status'] == 'absent') {
      setState(() {
        buttonText = 'CHECK IN';
      });
      if(documentSnapshot.exists){
        attendanceStatus =data['status'];
      }
    } else if(data['status']=='present'||data['status']=='late'){
      attendanceStatus =data['status'];
      checkInTime =data['check in datetime']==null?null:timeFormat.format(data['check in datetime'].toDate());
      if(data.containsKey('check out datetime')){
        checkOutTime = data['check out datetime']==null?null:timeFormat.format(data['check out datetime'].toDate());
        setState(() {
          buttonText = 'CHECKED OUT';
        });

        Fluttertoast.showToast(msg: 'Today attendance has done recorded',fontSize: SizeConfig.smaller,textColor: ThemeColor.whiteColor,backgroundColor: ThemeColor.themeBlueColor);
      }
      else{
        setState(() {
          buttonText = 'CHECK OUT';
        });
      }
    }
    else if(data['status']=='leave'){
      setState(() {
        buttonText = 'ON LEAVE';
      });
      Fluttertoast.showToast(msg: 'Student is on leave',fontSize: SizeConfig.smaller,textColor: ThemeColor.whiteColor,backgroundColor: ThemeColor.themeBlueColor);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Material(
      color: ThemeColor.whiteColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: SizeConfig.safeBlockVertical * 5,
              width: SizeConfig.safeBlockVertical * 5,
              child: CircularProgressIndicator(
                backgroundColor: ThemeColor.whiteColor,
              ),
            ),
          ],
        ),
      ),
    )
        : KiPage(
      scaffoldKey: _scaffoldKey,
      color: ThemeColor.whiteColor,
      appBarType: widget.type==2? AppBarType.doubleBackButton:AppBarType.backButton,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left:SizeConfig.mediumSmall,right: SizeConfig.mediumSmall),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                KiButton.smallButton(child:
                Card(
                  color: ThemeColor.whiteColor,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),

                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.extraSmall),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Attendance History',
                          style: smallerTextStyle(
                              color: ThemeColor.blueColor),
                        ),
                      ],
                    ),
                  ),
                ),
                  onPressed: (){
                   Navigator.push(context, MaterialPageRoute(
                     builder: (context)=>ViewStudentAttendancePage(index:widget.index)
                   ));
                  }
                ),
              ],
            ),
            SizeConfig.extraLargeVerticalBox,
            SizeConfig.mediumVerticalBox,
            Text('Record ${kindergartenProfile.studentFirstName[widget.index]} ${kindergartenProfile.studentLastName[widget.index]} Attendance',
                style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor)),
            SizeConfig.largeVerticalBox,
            KiButton.smallButton(
              child: CircleAvatar(
                  backgroundColor:
                  ThemeColor.blueColor.withOpacity(0.5),
                  radius: SizeConfig.safeBlockVertical * 16,
                  child: CircleAvatar(
                    radius: SizeConfig.safeBlockVertical * 14,
                    backgroundColor:
                    ThemeColor.themeBlueColor.withOpacity(0.8),
                    child: largeTitleText(
                        text: buttonText, color: ThemeColor.whiteColor),
                  )),
              onPressed: () async {

                  if (buttonText == 'CHECK IN') {
                    DateTime now = DateTime.now();
                    if(now.hour<kindergartenProfile.startWorkHours){
                      attendanceStatus='present';
                    }
                    else if(now.hour==kindergartenProfile.startWorkHours){
                      if(now.minute>=kindergartenProfile.startWorkMinutes)
                        attendanceStatus='late';
                      else attendanceStatus='present';
                    }
                    else{
                      attendanceStatus='late';
                    }
                    await student.doc('${kindergartenProfile.studentUID[widget.index]}/attendance/$date').set(
                        { 'check in min': now.minute,
                          'check in hrs': now.hour,
                          'check in datetime':now,
                          'datetime':DateTime.now(),
                          'status':attendanceStatus,
                          'checkInStatus': 1
                        }, SetOptions(merge: true)).then((_) {
                      print("success!");
                    });
                    kindergartenProfile.studentAbsent=kindergartenProfile.studentAbsent-1;
                    switch(attendanceStatus){
                      case 'present':
                        kindergartenProfile.studentPresent=kindergartenProfile.studentPresent+1;
                        break;
                      case 'late':
                        kindergartenProfile.studentLate = kindergartenProfile.studentLate+1;
                        break;
                    }
                    await kindergarten.doc(kindergartenProfile.name).update({
                      'student present': kindergartenProfile.studentPresent,
                      'student absent':kindergartenProfile.studentAbsent,
                      'student late': kindergartenProfile.studentLate,
                    });

                    setState(() {
                      buttonText = 'CHECK OUT';
                      checkInTime ='${now.hour}:${now.minute}';
                    });

                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor:
                      ThemeColor.themeBlueColor.withOpacity(0.8),
                      content: Text(
                        'Student attendance is recorded as ${attendanceStatus.toUpperCase()}.',
                        style: extraSmallTextStyle(
                            color: ThemeColor.whiteColor),
                      ),
                    ));

                  }
                  else if (buttonText == 'CHECK OUT') {
                    DateTime now = DateTime.now();

                    await student.doc('${kindergartenProfile.studentUID[widget.index]}/attendance/$date').set(
                        { 'check out min': now.minute,
                          'check out hrs': now.hour,
                          'check out datetime': now,
                          'checkInStatus': 2
                        }, SetOptions(merge: true)).then((_) {
                      print("success!");
                    });

                    setState(() {
                      buttonText = 'CHECKED OUT';
                      date = '${now.day}-${now.month}-${now.year}';
                      checkOutTime = '${now.hour}:${now.minute}';
                    });

                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor:
                      ThemeColor.themeBlueColor.withOpacity(0.8),
                      content: Text(
                        'Check out is done successfully',
                        style: extraSmallTextStyle(
                            color: ThemeColor.whiteColor),
                      ),
                    ));
                  }

                  if(widget.type==2){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
              },
            ),
            SizeConfig.extraLargeVerticalBox,
            attendanceStatus==null||attendanceStatus=='absent'? Container():
            checkInTime==null? Text('Attendance is checked in by Owner as ${attendanceStatus.toUpperCase()}',
              style: extraSmallTextStyle(color: ThemeColor.blueColor),)
                :Text(
              'Checked in on $date $checkInTime as ${attendanceStatus.toUpperCase()}',
              style: extraSmallTextStyle(
                  color: ThemeColor.blueGreyColor),
              textAlign: TextAlign.center,

            ),
            SizeConfig.extraSmallVerticalBox,
            checkOutTime == null
                ? Container(): Text(
              'Checked out on $date $checkOutTime',
              style: extraSmallTextStyle(
                  color: ThemeColor.blueGreyColor),
              textAlign: TextAlign.center,

            ),
          ],
        ),
      ),
    );
  }
}
