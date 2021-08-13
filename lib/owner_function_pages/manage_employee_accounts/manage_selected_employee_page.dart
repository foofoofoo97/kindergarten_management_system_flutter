import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class ManageSelectedEmployeePage extends StatefulWidget {

  EmployeeAccounts employeeAccounts;
  int index;
  ManageSelectedEmployeePage({this.employeeAccounts,this.index});

  @override
  _ManageSelectedEmployeePageState createState() => _ManageSelectedEmployeePageState();
}

class _ManageSelectedEmployeePageState extends State<ManageSelectedEmployeePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  OwnerProfile ownerProfile = new OwnerProfile();
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  EmployeeAccounts employeeAccounts = new EmployeeAccounts();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference employee = FirebaseFirestore.instance.collection('employee');


  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading=true;
    employeeAccounts =widget.employeeAccounts;
    init();
    super.initState();
  }

  Future<void> init()async{
    try {
      DocumentSnapshot documentSnapshot = await employee.doc(widget.employeeAccounts.uid).get();
      Map data = documentSnapshot.data();
      employeeAccounts.homeAddress =data['home address'];
      employeeAccounts.contactNo = data['contact no'];

      setState(() {
        isLoading = false;
      });
    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to connect server',fontSize: SizeConfig.smaller,backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor);
    }
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
                valueColor:
                AlwaysStoppedAnimation<Color>(ThemeColor.blueColor)),
          ),
        ))
        : Scaffold(
      key: _scaffoldKey,
      appBar: kiAppBar(AppBarType.backButton, context),
      backgroundColor: ThemeColor.whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.small,
              right: SizeConfig.small),
          child: Column(
            children: <Widget>[
              Center(
                child: Image.asset('assets/user.png',height: SizeConfig.safeBlockVertical*6,),
              ),
              SizeConfig.extraSmallVerticalBox,
              Center(
                child:Text('Employee Profile',style:smalllTextStyle(color: ThemeColor.themeBlueColor),),
              ),
              SizeConfig.mediumVerticalBox,
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.mediumSmall,
                    horizontal: SizeConfig.small),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: ThemeColor.lightBlueColor2.withOpacity(0.7), width: 1.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('First Name',style: smallererTextStyle(color: ThemeColor.blueColor),),
                    Text(widget.employeeAccounts.firstName,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                  ],
                ),
              ),
              SizeConfig.ultraSmallVerticalBox,
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.mediumSmall,
                    horizontal: SizeConfig.small),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: ThemeColor.lightBlueColor2.withOpacity(0.7), width: 1.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Last Name',style: smallererTextStyle(color: ThemeColor.blueColor),),
                    Text(widget.employeeAccounts.lastName,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                  ],
                ),
              ),
              SizeConfig.ultraSmallVerticalBox,
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.mediumSmall,
                    horizontal: SizeConfig.small),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: ThemeColor.lightBlueColor2.withOpacity(0.7), width: 1.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Job Title',style: smallererTextStyle(color: ThemeColor.blueColor),),
                    Text(widget.employeeAccounts.jobTitle,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                  ],
                ),
              ),
              SizeConfig.ultraSmallVerticalBox,
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.mediumSmall,
                    horizontal: SizeConfig.small),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: ThemeColor.lightBlueColor2.withOpacity(0.7), width: 1.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Contact No',style: smallererTextStyle(color: ThemeColor.blueColor),),
                    Text(widget.employeeAccounts.contactNo,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                  ],
                ),
              ),
              SizeConfig.ultraSmallVerticalBox,
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.mediumSmall,
                    horizontal: SizeConfig.small),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: ThemeColor.lightBlueColor2.withOpacity(0.7), width: 1.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Home Address',style: smallererTextStyle(color: ThemeColor.blueColor),),
                    SizeConfig.ultraSmallVerticalBox,
                    Text(widget.employeeAccounts.homeAddress,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                  ],
                ),
              ),
              SizeConfig.ultraSmallVerticalBox,
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.mediumSmall,
                    horizontal: SizeConfig.small),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: ThemeColor.lightBlueColor2.withOpacity(0.7), width: 1.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Accessibility',style: smallererTextStyle(color: ThemeColor.blueColor),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Posts',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                        LiteRollingSwitch(
                          value: employeeAccounts.canPosts==0?false:true,
                          textOn: 'ON',
                          textOff: 'OFF',
                          colorOn: ThemeColor.blueColor,
                          colorOff: ThemeColor.lightBlueColor2,
                          iconOn: Icons.done,
                          iconOff: Icons.remove_circle_outline,
                          textSize: SizeConfig.extraSmall,
                          onChanged: (bool state) async{
                            setState(() {
                              state==true?employeeAccounts.canPosts=1:employeeAccounts.canPosts=0;
                            });
                            kindergartenProfile.canPosts[widget.index]=employeeAccounts.canPosts;
                            await kindergarten.doc(kindergartenProfile.name).update({
                              'can posts': kindergartenProfile.canPosts
                            });
                          },
                        ),
                      ],
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Performance Analysis',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                        LiteRollingSwitch(
                          //initial value
                          value: employeeAccounts.canPerformance==0?false:true,
                          textOn: 'ON',
                          textOff: 'OFF',
                          colorOn: ThemeColor.blueColor,
                          colorOff: ThemeColor.lightBlueColor2,
                          iconOn: Icons.done,
                          iconOff: Icons.remove_circle_outline,
                          textSize: SizeConfig.extraSmall,
                          onChanged: (bool state) async{
                            setState(() {
                              state==true?employeeAccounts.canPerformance=1:employeeAccounts.canPerformance=0;
                            });
                            kindergartenProfile.canPerformance[widget.index]=employeeAccounts.canPerformance;
                            await kindergarten.doc(kindergartenProfile.name).update({
                              'can performance': kindergartenProfile.canPerformance
                            });
                          },
                        ),
                      ],
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Attendance Management',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                        LiteRollingSwitch(
                          //initial value
                          value: employeeAccounts.canAttendance==0?false:true,
                          textOn: 'ON',
                          textOff: 'OFF',
                          colorOn: ThemeColor.blueColor,
                          colorOff: ThemeColor.lightBlueColor2,
                          iconOn: Icons.done,
                          iconOff: Icons.remove_circle_outline,
                          textSize: SizeConfig.extraSmall,
                          onChanged: (bool state) async{
                            setState(() {
                              state==true?employeeAccounts.canAttendance=1:employeeAccounts.canAttendance=0;
                            });
                            kindergartenProfile.canAttendance[widget.index]=employeeAccounts.canAttendance;
                            await kindergarten.doc(kindergartenProfile.name).update({
                              'can attendance': kindergartenProfile.canAttendance
                            });
                          },
                        ),
                      ],
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Results',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                        LiteRollingSwitch(
                          //initial value
                          value: employeeAccounts.canResults==0?false:true,
                          textOn: 'ON',
                          textOff: 'OFF',
                          colorOn: ThemeColor.blueColor,
                          colorOff: ThemeColor.lightBlueColor2,
                          iconOn: Icons.done,
                          iconOff: Icons.remove_circle_outline,
                          textSize: SizeConfig.extraSmall,
                          onChanged: (bool state) async{
                            setState(() {
                              state==true?employeeAccounts.canResults=1:employeeAccounts.canResults=0;
                            });
                            kindergartenProfile.canResults[widget.index]=employeeAccounts.canResults;
                            await kindergarten.doc(kindergartenProfile.name).update({
                              'can results': kindergartenProfile.canResults
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // SizeConfig.extraLargeVerticalBox,
              // SizeConfig.extraLargeVerticalBox
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.message,color: ThemeColor.whiteColor,size: SizeConfig.extraLarge,),
      //   backgroundColor: ThemeColor.themeBlueColor,
      //   onPressed: (){
      //     Navigator.push(context, MaterialPageRoute(builder: (context)=> Chat(
      //       uid: ownerProfile.uid,
      //       peerId: employeeAccounts.uid,
      //       peerName: '${employeeAccounts.firstName} ${employeeAccounts.lastName}',
      //       peerType:  'guardian',
      //       type: 'owner',
      //     )));
      //   },
      // ),
    );
  }
}
