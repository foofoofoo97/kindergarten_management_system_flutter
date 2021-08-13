import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/face_recognition/db/database.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class AddNewFacePage extends StatefulWidget {
  Function onPressed;
  Function onPressed1;
  Function onPressed2;
  Map<String, dynamic> data;
  AddNewFacePage({this.data, this.onPressed,this.onPressed1,this.onPressed2});

  @override
  _AddNewFacePageState createState() => _AddNewFacePageState();
}

class _AddNewFacePageState extends State<AddNewFacePage> {
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  final DataBaseService dataBaseService = DataBaseService();
  List<Student> studentList = new List.from([]);
  bool isLoading;
  Student selectedStudent;

  int checkInStatus;
  String status;
  CollectionReference student = FirebaseFirestore.instance.collection('student');


  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    init();

    super.initState();
  }

  Future<void> init() async {
    for (int x = 0; x < kindergartenProfile.studentUID.length; x++) {
      String key =
          '${kindergartenProfile.studentUID[x]}:${kindergartenProfile.studentFirstName[x]} ${kindergartenProfile.studentLastName[x]}';
      if (!widget.data.containsKey(key)) {
        Student student = new Student();
        student.firstName = kindergartenProfile.studentFirstName[x];
        student.lastName = kindergartenProfile.studentLastName[x];
        student.uid = kindergartenProfile.studentUID[x];

        studentList.add(student);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiPage(
          color: ThemeColor.whiteColor,
          appBarType: AppBarType.backButton,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.medium),
            child: Column(
              children: <Widget>[
                Text(
                  'Register New Face',
                  style: mediumSTextStyle(color: ThemeColor.themeBlueColor),
                ),
                SizeConfig.mediumVerticalBox,
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.safeBlockVertical,
                      horizontal: SizeConfig.extraSmall),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: ThemeColor.themeBlueColor, width: 1.0)),
                  child: DropdownButton<Student>(
                    isExpanded: true,
                    underline: Container(),
                    hint: Text("Select student to register FaceID"),
                    style: smalllTextStyle(color: ThemeColor.blackColor),
                    value: selectedStudent,
                    onChanged: (Student value) async{
                      setState((){
                        isLoading=true;
                        selectedStudent = value;
                      });
                      DateTime today = DateTime.now();
                      int day = today.day;
                      int month = today.month;
                      int year = today.year;
                      String date = '$day-$month-$year';
                      DocumentSnapshot doc = await student.doc(value.uid).collection('attendance').doc(date).get();
                      if(doc.exists){
                        setState(() {
                          status=doc.data()['status'];
                          checkInStatus=doc.data()['checkInStatus'];
                        });
                      }
                      else{
                        setState(() {
                          status='absent';
                          checkInStatus=0;
                        });
                      }
                      setState(() {
                        isLoading=false;
                      });
                    },
                    items: studentList.map((Student student) {
                      return DropdownMenuItem<Student>(
                        value: student,
                        child: Text('${student.firstName} ${student.lastName}',
                            style: smalllTextStyle(
                                color: ThemeColor.themeBlueColor)),
                      );
                    }).toList(),
                  ),
                ),
                SizeConfig.extraLargeVerticalBox,
                status==null||checkInStatus==2||status=='leave'?Container():KiButton.rectButton(
                    onPressed: () async {
                      if (selectedStudent != null) {
                        setState(() {
                          isLoading=true;
                        });
                        status=='absent'?
                        await widget.onPressed1(selectedStudent.uid,'${selectedStudent.firstName} ${selectedStudent.lastName}'):
                        await widget.onPressed2(selectedStudent.uid,'${selectedStudent.firstName} ${selectedStudent.lastName}');
                        setState(() {
                          isLoading=false;
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please choose a student',
                            fontSize: SizeConfig.smaller,
                            textColor: ThemeColor.whiteColor,
                            backgroundColor: ThemeColor.themeBlueColor);
                      }
                    },
                    color: ThemeColor.blueColor,
                    child: Text(
                      'Register FaceID & ${status=='absent'?'Check In':'Check Out'}',
                      style: smalllTextStyle(color: ThemeColor.whiteColor),
                    )),
                SizeConfig.smallVerticalBox,
                KiButton.rectButton(
                    onPressed: () async {
                      if (selectedStudent != null) {
                        setState(() {
                          isLoading=true;
                        });
                        await widget.onPressed(selectedStudent.uid,'${selectedStudent.firstName} ${selectedStudent.lastName}');
                        setState(() {
                          isLoading=false;
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please choose a student',
                            fontSize: SizeConfig.smaller,
                            textColor: ThemeColor.whiteColor,
                            backgroundColor: ThemeColor.themeBlueColor);
                      }

                    },
                    color: ThemeColor.blueColor,
                    child: Text(
                      'Register FaceID',
                      style: smalllTextStyle(color: ThemeColor.whiteColor),
                    ))
              ],
            ),
          ),
        ),
        isLoading
            ? Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: SizedBox(
                      height: SizeConfig.safeBlockVertical * 5,
                      width: SizeConfig.safeBlockVertical * 5,
                      child: CircularProgressIndicator(
                        backgroundColor: ThemeColor.whiteColor,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ThemeColor.blueColor),
                      )),
                ))
            : Container()
      ],
    );
  }
}
