import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class EmployeeAttendancePage extends StatefulWidget {
  String uid;
  EmployeeAttendancePage({this.uid});

  @override
  _EmployeeAttendancePageState createState() => _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState extends State<EmployeeAttendancePage> {

  String buttonText;

  CollectionReference employee = FirebaseFirestore.instance.collection('employee');
  CollectionReference kindergarten =
  FirebaseFirestore.instance.collection('kindergarten');

  EmployeeProfile employeeProfile = new EmployeeProfile();
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
  String checkInAddress;
  String checkOutAddress;
  Position position;
  String addressLine;
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
    loading = 'Retrieving your GPS location';
    getToday();
  }

  Future<void> getToday() async {
    DocumentSnapshot documentSnapshot =
        await employee.doc(widget.uid).collection('attendance').doc(date).get();
    addressLine = await getUserLocation();
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
        checkInAddress ='${data['check in address']}';
        if(data.containsKey('check out address')){
          checkOutAddress=data['check out address'];
          checkOutTime = data['check out datetime']==null?null:timeFormat.format(data['check out datetime'].toDate());
          setState(() {
            buttonText = 'CHECKED OUT';
          });
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
                  SizeConfig.mediumVerticalBox,
                  Text(
                    'Retrieving your GPS Location',
                    style:
                        mediumSmallTextStyle(color: ThemeColor.blueGreyColor),
                  )
                ],
              ),
            ),
          )
        : KiCenterPage(
            scaffoldKey: _scaffoldKey,
            color: ThemeColor.whiteColor,
            appBarType: AppBarType.backButton,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.mediumSmall),
              child: Column(
                children: <Widget>[
                  Text('Record Your Attendance',
                      style: mediumTextStyle(color: ThemeColor.themeBlueColor)),
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
                      if (addressLine == null) {
                        addressLine = await getUserLocation();
                      }
                      if (addressLine != null) {
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
                          await employee.doc('${widget.uid}/attendance/$date').set(
                           { 'check in min': now.minute,
                             'check in hrs': now.hour,
                             'check in address': addressLine,
                             'check in datetime':now,
                             'datetime':DateTime.now(),
                             'status':attendanceStatus,
                             'checkInStatus': 1
                          }, SetOptions(merge: true)).then((_) {
                            print("success!");
                          });

                          kindergartenProfile.employeeAbsent=kindergartenProfile.employeeAbsent-1;
                          switch (attendanceStatus) {
                            case 'present':
                              kindergartenProfile.employeePresent =
                                  kindergartenProfile.employeePresent + 1;
                              break;
                            case 'late':
                              kindergartenProfile.employeeLate =
                                  kindergartenProfile.employeeLate + 1;
                              break;
                          }

                          await kindergarten.doc(kindergartenProfile.name).update({
                            'employee present': kindergartenProfile.employeePresent,
                            'employee absent':kindergartenProfile.employeeAbsent,
                            'employee late': kindergartenProfile.employeeLate,
                            'employee leave': kindergartenProfile.employeeLeave
                          });
                          setState(() {
                            buttonText = 'CHECK OUT';
                            checkInAddress = addressLine;
                            checkInTime ='${now.hour}:${now.minute}';
                          });

                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor:
                                ThemeColor.themeBlueColor.withOpacity(0.8),
                            content: Text(
                              'Your attendance is recorded as ${attendanceStatus.toUpperCase()}.',
                              style: extraSmallTextStyle(
                                  color: ThemeColor.whiteColor),
                            ),
                          ));

                        }
                        else if (buttonText == 'CHECK OUT') {
                          DateTime now = DateTime.now();

                          await employee.doc('${widget.uid}/attendance/$date').set(
                              { 'check out min': now.minute,
                                'check out hrs': now.hour,
                                'check out address': addressLine,
                                'check out datetime': now,
                                'checkInStatus': 2
                              }, SetOptions(merge: true)).then((_) {
                            print("success!");
                          });

                          setState(() {
                            buttonText = 'CHECKED OUT';
                            checkOutAddress = addressLine;
                            date = '${now.day}-${now.month}-${now.year}';
                            checkOutTime = '$date ${now.hour}:${now.minute}';
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
                      } else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor:
                              ThemeColor.themeBlueColor.withOpacity(0.8),
                          content: Text(
                            'Failed to detect GPS location. Please check your settings and try again later',
                            style: extraSmallTextStyle(
                                color: ThemeColor.whiteColor),
                          ),
                        ));
                      }
                    },
                  ),
                  SizeConfig.mediumVerticalBox,
                   Card(
                          color: ThemeColor.whiteColor,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.extraSmall),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Location Detected',
                                  style: extraSmallTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                ),
                                Text(
                                  addressLine ?? 'Failed to detect GPS address',
                                  style: extraSmallTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  SizeConfig.extraLargeVerticalBox,
                  attendanceStatus==null||attendanceStatus=='absent'? Container():
                  checkInTime==null? Text('Attendance is checked in by Owner as ${attendanceStatus.toUpperCase()}',
                  style: extraSmallTextStyle(color: ThemeColor.blueColor),)
                      :Text(
                          'Checked in at $checkInAddress on $date $checkInTime',
                          style: extraSmallTextStyle(
                              color: ThemeColor.blueGreyColor),
                    textAlign: TextAlign.center,

                  ),
                  SizeConfig.extraSmallVerticalBox,
                  checkOutAddress == null
                      ? Container(): Text(
                          'Checked out at $checkOutAddress on $date $checkOutTime',
                          style: extraSmallTextStyle(
                              color: ThemeColor.blueGreyColor),
                    textAlign: TextAlign.center,

                  ),
                ],
              ),
            ),
          );
  }

  Future<String> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Location services are disabled.',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Location permissions are permanently denied, we cannot request permissions.',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
      return null;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
          content: Text(
            'Location permissions are denied (actual value: $permission).',
            style: extraSmallTextStyle(color: ThemeColor.whiteColor),
          ),
        ));
        return null;
      }
    }

    position = await Geolocator.getCurrentPosition();
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    return first.addressLine;
  }
}
