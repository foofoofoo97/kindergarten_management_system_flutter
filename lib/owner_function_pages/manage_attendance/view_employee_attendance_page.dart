import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Attendance.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ViewEmployeeAttendancePage extends StatefulWidget {
  int index;

  ViewEmployeeAttendancePage({this.index});

  @override
  _ViewEmployeeAttendancePageState createState() =>
      _ViewEmployeeAttendancePageState();
}

class _ViewEmployeeAttendancePageState
    extends State<ViewEmployeeAttendancePage> {
  EmployeeProfile employeeProfile = EmployeeProfile();
  KindergartenProfile kindergartenProfile = KindergartenProfile();

  CollectionReference employee =
      FirebaseFirestore.instance.collection('employee');

  DateFormat formatter = DateFormat('dd MMM yy');
  DateFormat formatter2 = DateFormat('dd MMM yyy kk:mm');
  DateTime startDateTime;
  DateTime endDateTime;
  bool isLoading;
  bool isFinding;
  int open;

  List<Attendance> attendances = new List.from([]);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    open=0;
    isLoading=true;
    isFinding=false;
    prepareList();
    super.initState();
  }

  Future<void> prepareList()async{
    QuerySnapshot querySnapshot= await employee.doc(kindergartenProfile.employeeUID[widget.index]).collection('attendance').orderBy('datetime',descending: true).get();
    for(DocumentSnapshot documentSnapshot in querySnapshot.docs){
      Map data =documentSnapshot.data();
      Attendance attendance = new Attendance(
          dateTime: data['datetime'].toDate(),
          status: data['status'],
          checkInAddress: data['check in address'],
          checkOutAddress: data['check out address'],
          checkInStatus: data['checkInStatus'],
          checkOutHrs: data['check out hrs'],
          checkOutMin: data['check out min'],
          checkInHrs: data['check in hrs'],
          checkInMin: data['check in min'],
          checkInDateTime: data['check in datetime']==null?null:data['check in datetime'].toDate(),
          checkOutDateTime:data['check out datetime']==null?null:data['check out datetime'].toDate()
      );
      attendances.add(attendance);
    }

    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading?Container(
      color: ThemeColor.whiteColor,
      child: Center(
        child: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            width: SizeConfig.safeBlockVertical * 5,
            child: CircularProgressIndicator(
              backgroundColor: ThemeColor.whiteColor,
            )
        ),
      ),
    ):Scaffold(
      key: _scaffoldKey,
            appBar: kiAppBar(AppBarType.backButton, context),
            backgroundColor: ThemeColor.whiteColor,
            body: Padding(
              padding: EdgeInsets.only(left:SizeConfig.small,right: SizeConfig.small),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      Column(children: <Widget>[
                      Text(
                        '${kindergartenProfile.employeeFirstName[widget.index]} ${kindergartenProfile.employeeLastName[widget.index]}',
                        style: mediumSmallTextStyle(
                            color: ThemeColor.themeBlueColor),
                      ),
                      Text(
                        kindergartenProfile.employeeJobTitle[widget.index],
                        style: smallTextStyle(color: ThemeColor.blueColor),
                      )],)
                    ]),
                    SizeConfig.extraSmallVerticalBox,
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizeConfig.smallHorizontalBox,
                        Text('from',style: extraSmallTextStyle(color: ThemeColor.themeBlueColor),),
                        SizeConfig.extraSmallHorizontalBox,
                        KiButton.smallButton(
                            child: Card(
                                elevation: 8.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),                                child:
                            Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal*1.3),
                                width: SizeConfig.safeBlockHorizontal*30,
                                child:Text(startDateTime==null?'Start Date':formatter.format(startDateTime),style: smallerTextStyle(color: ThemeColor.themeBlueColor),))),
                            onPressed: ()async{
                              DateTime date = await showRoundedDatePicker(
                                context: context,
                                theme: ThemeData(
                                  primaryColor: ThemeColor.themeBlueColor,
                                  accentColor: ThemeColor.themeBlueColor,
                                  backgroundColor: ThemeColor.whiteColor,
                                  textTheme: TextTheme(
                                    bodyText1: smallerTextStyle(color: ThemeColor.themeBlueColor),
                                    caption: smallerTextStyle(color: ThemeColor.themeBlueColor),
                                  ),
                                ),
                                styleDatePicker: MaterialRoundedDatePickerStyle(
                                    textStyleYearButton: mediumTextStyle(color: ThemeColor.whiteColor),
                                    textStyleDayButton: largeTextStyle(color: ThemeColor.whiteColor),
                                    textStyleMonthYearHeader: smallTextStyle(color: ThemeColor.blackColor)
                                ),
                                height: SizeConfig.safeBlockVertical*36,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                borderRadius: 16,
                              );

                              if(endDateTime==null||date.isBefore(endDateTime)){
                                setState(() {
                                  startDateTime=date;
                                });
                              }
                              else{
                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  backgroundColor: ThemeColor
                                      .themeBlueColor
                                      .withOpacity(0.8),
                                  content: Text(
                                    'Start date cannot after end date',
                                    style: extraSmallTextStyle(
                                        color: ThemeColor
                                            .whiteColor),
                                  ),
                                ));
                              }
                            }
                        ),
                        SizeConfig.smallHorizontalBox,
                        Text('to',style: extraSmallTextStyle(color: ThemeColor.themeBlueColor),),
                        SizeConfig.extraSmallHorizontalBox,
                        KiButton.smallButton(
                            child: Card(
                                elevation: 8.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),                                child:
                            Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal*1.3),
                                width: SizeConfig.safeBlockHorizontal*30,
                                child:Text(endDateTime==null?'End Date':formatter.format(endDateTime),style: smallerTextStyle(color: ThemeColor.themeBlueColor),))),
                            onPressed: ()async{
                              DateTime date = await showRoundedDatePicker(
                                context: context,
                                theme: ThemeData(
                                  primaryColor: ThemeColor.themeBlueColor,
                                  accentColor: ThemeColor.themeBlueColor,
                                  backgroundColor: ThemeColor.whiteColor,
                                  textTheme: TextTheme(
                                    bodyText1: smallerTextStyle(color: ThemeColor.themeBlueColor),
                                    caption: smallerTextStyle(color: ThemeColor.themeBlueColor),
                                  ),
                                ),
                                styleDatePicker: MaterialRoundedDatePickerStyle(
                                    textStyleYearButton: mediumTextStyle(color: ThemeColor.whiteColor),
                                    textStyleDayButton: largeTextStyle(color: ThemeColor.whiteColor),
                                    textStyleMonthYearHeader: smallTextStyle(color: ThemeColor.blackColor)
                                ),
                                height: SizeConfig.safeBlockVertical*36,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                borderRadius: 16,
                              );
                              if(startDateTime==null||startDateTime.isBefore(date)){
                                setState(() {
                                  endDateTime=date;
                                });
                              }
                              else{
                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  backgroundColor: ThemeColor
                                      .themeBlueColor
                                      .withOpacity(0.8),
                                  content: Text(
                                    'End date cannot before start date',
                                    style: extraSmallTextStyle(
                                        color: ThemeColor
                                            .whiteColor),
                                  ),
                                ));
                              }
                            }
                        ),
                        IconButton(
                          icon: Icon(Icons.search,color: ThemeColor.blueColor,size: SizeConfig.medium,),
                          onPressed: ()async{
                            setState(() {
                              open=0;
                              isFinding=true;
                            });
                            if(endDateTime==null&&startDateTime==null){
                              attendances.clear();
                              prepareList();
                            }
                            else if(endDateTime!=null&&startDateTime!=null){
                              attendances.clear();
                              DateTime end =endDateTime.add(Duration(days: 1));
                              DateTime start =startDateTime;
                              //.subtract(Duration(days: 1));
                              QuerySnapshot querySnapshot= await employee.doc(kindergartenProfile.employeeUID[widget.index]).collection('attendance').where('datetime',isGreaterThan: start).where('datetime',isLessThan: end).orderBy('datetime',descending: true).get();
                              for(DocumentSnapshot documentSnapshot in querySnapshot.docs){
                                Map data =documentSnapshot.data();
                                Attendance attendance = new Attendance(
                                    dateTime: data['datetime'].toDate(),
                                    status: data['status'],
                                    checkInAddress: data['check in address'],
                                    checkOutAddress: data['check out address'],
                                    checkInStatus: data['checkInStatus'],
                                    checkOutHrs: data['check out hrs'],
                                    checkOutMin: data['check out min'],
                                    checkInHrs: data['check in hrs'],
                                    checkInMin: data['check in min'],
                                    checkInDateTime: data['check in datetime']==null?null:data['check in datetime'].toDate(),
                                    checkOutDateTime:data['check out datetime']==null?null:data['check out datetime'].toDate()
                                );
                                attendances.add(attendance);
                              }}
                            else{
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                backgroundColor: ThemeColor
                                    .themeBlueColor
                                    .withOpacity(0.8),
                                content: Text(
                                  'Please complete the dates first',
                                  style: extraSmallTextStyle(
                                      color: ThemeColor
                                          .whiteColor),
                                ),
                              ));
                            }
                            setState(() {
                              isFinding=false;
                            });
                          },
                        )
                      ],
                    ),
                    SizeConfig.smallVerticalBox,
                    isFinding?Container(
                      color: ThemeColor.whiteColor,
                      child: Center(
                        child: SizedBox(
                            height: SizeConfig.safeBlockVertical * 5,
                            width: SizeConfig.safeBlockVertical * 5,
                            child: CircularProgressIndicator(
                              backgroundColor: ThemeColor.whiteColor,
                            )
                        ),
                      ),
                    ):attendances.length==0? Container(
                        height: SizeConfig.blockSizeVertical * 60,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'No attendance is recorded yet',
                                style:
                                smallerTextStyle(color: ThemeColor.blueGreyColor),
                              ),
                            ])):
                    Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.all(SizeConfig.ultraSmall),
                          itemCount: attendances.length,
                          itemBuilder: (context,x){
                            return Card(
                              color: ThemeColor.whiteColor,
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                dense: true,
                                trailing: Icon(open==x?Icons.expand_less:Icons.expand_more,color: ThemeColor.lightBlueColor2,size: SizeConfig.extraLarge,),
                                  onTap: (){
                                    setState(() {
                                      if(open==x)
                                        open=null;
                                      else
                                        open=x;
                                    });},
                                contentPadding: EdgeInsets.symmetric(horizontal:SizeConfig.small,vertical: SizeConfig.extraSmall),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(formatter.format(attendances[x].dateTime),style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                                    SizeConfig.mediumHorizontalBox,
                                    Text(attendances[x].status.toUpperCase(),style: smallerTextStyle(color: attendances[x].status=='late'? ThemeColor.redColor:ThemeColor.blueColor),)
                                  ],
                                ),
                                subtitle: open==x? getContent(attendances[x]):null,
                              ),
                            );
                          }),
                    )
                  ]),
            ),
          );
  }

  Widget getContent(Attendance attendance){
    if(attendance.status=='absent') {
      return null;
    }
    switch(attendance.checkInStatus){
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizeConfig.extraSmallVerticalBox,
            attendance.checkInDateTime==null? checkInWidget2():checkInWidget(attendance),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizeConfig.extraSmallVerticalBox,
            attendance.checkInDateTime==null? checkInWidget2():checkInWidget(attendance),
            SizeConfig.extraSmallVerticalBox,
            checkOutWidget(attendance)
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizeConfig.extraSmallVerticalBox,
            Text('No related data',style: smallererTextStyle(color: ThemeColor.blueGreyColor),)
          ],
        );
    }
  }


  Widget checkInWidget(Attendance attendance){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Text('CHECK IN TIME', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
          SizeConfig.mediumHorizontalBox,
          Text(formatter2.format(attendance.checkInDateTime),style: smallererTextStyle(color: ThemeColor.blackColor),),
        ],),
        Text('CHECK IN ADDRESS', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
        Text(attendance.checkInAddress,style: smallererTextStyle(color: ThemeColor.blackColor),),

      ],
    );
  }

  Widget checkInWidget2(){
    return Row(
      children: <Widget>[
        Text('CHECK IN',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
        SizeConfig.mediumHorizontalBox,
        Text('Check In Is Done By Owner', style: smallererTextStyle(color: ThemeColor.blackColor
        ),)
      ],
    );
  }

  Widget checkOutWidget(Attendance attendance){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('CHECK OUT TIME', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
            SizeConfig.mediumHorizontalBox,
            Text(attendance.checkOutDateTime==null?'no checked out yet':formatter2.format(attendance.checkOutDateTime),style: smallererTextStyle(color: ThemeColor.blackColor),),
          ],
        ),
        Text('CHECK OUT ADDRESS', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
        Text(attendance.checkOutAddress??'not available',style: smallererTextStyle(color: ThemeColor.blackColor),),

      ],
    );
  }
}
