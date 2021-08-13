import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/ChatRoomSearch.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class OwnerSearchReceiverPage extends StatefulWidget {

  @override
  _OwnerSearchReceiverPageState createState() => _OwnerSearchReceiverPageState();
}

class _OwnerSearchReceiverPageState extends State<OwnerSearchReceiverPage> {

  OwnerProfile ownerProfile = new OwnerProfile();
  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');

  List duplicateGuardian = new List<GuardianReceiver>.from([]);
  List duplicateEmployee = new List<EmployeeReceiver>.from([]);
  var items =new List.from([]);
  List<String> guardianChecker;
  bool isGuardian;
  TextEditingController searchController;

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    registerNotification();
    configLocalNotification();
    isLoading =true;
    guardianChecker = new List.from([]);
    searchController = new TextEditingController();
    isGuardian=true;
    employeeInit();
    guardianInit();

  }

  //KIUPDATE PUSH NOTIFICATION
  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance.collection('users').doc(ownerProfile.uid).update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.fyp.kiki' : 'com.fyp.kiki',
      'KIKI',
      'Kindergarten Management Platform',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  Future<void> employeeInit()async{
    try {
      for(int x=0;x<kindergartenProfile.employeeFirstName.length;x++){
        EmployeeReceiver employeeReceiver = new EmployeeReceiver();
        employeeReceiver.name='${kindergartenProfile.employeeFirstName[x]} ${kindergartenProfile.employeeLastName[x]}';
        employeeReceiver.uid=kindergartenProfile.employeeUID[x];
        employeeReceiver.jobTitle=kindergartenProfile.employeeJobTitle[x];
        duplicateEmployee.add(employeeReceiver);
      }
    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to connect database server.',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
    }
  }

  Future<void> guardianInit()async{
    try {
      QuerySnapshot querySnapshot = await guardian.get();
      if (kindergartenProfile.studentFirstName != null &&
          kindergartenProfile.studentFirstName.length != 0) {

        for (int x=0;x<kindergartenProfile.studentUID.length;x++) {
          List<String> strings = kindergartenProfile.studentUID[x].split('+');
          Map data = new Map();
          for(DocumentSnapshot doc in querySnapshot.docs){
            if(doc.id==strings[0]){
              data=doc.data();
              break;
            }
          }
          if(guardianChecker.contains(strings[0])){
            GuardianReceiver guardianReceiver = duplicateGuardian[guardianChecker.indexOf(strings[0])];
            guardianReceiver.studentName = guardianReceiver.studentName+'${kindergartenProfile.studentFirstName[x]} ${kindergartenProfile
                .studentLastName[x]} ';
            duplicateGuardian[guardianChecker.indexOf(strings[0])]=guardianReceiver;
          }
          else {
            guardianChecker.add(strings[0]);
            GuardianReceiver guardianReceiver = new GuardianReceiver();
            guardianReceiver.name =
            '${data['first name']} ${data['last name']}';

            guardianReceiver.uid = strings[0];
            guardianReceiver.studentName =
            '${kindergartenProfile.studentFirstName[x]} ${kindergartenProfile
                .studentLastName[x]} ';
            duplicateGuardian.add(guardianReceiver);
          }
        }
      }
      setState(() {
        items.addAll(duplicateGuardian);
        isLoading=false;
      });
    }catch(e){
     Fluttertoast.showToast(msg: 'Failed to connect database server.',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiPage(
          scaffoldKey: _scaffoldKey,
          color: ThemeColor.whiteColor,
          appBarType: AppBarType.backButton,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.small),
            child: Column(
              children: <Widget>[
                Text('Contacts',style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor),),
                SizeConfig.smallVerticalBox,
                Wrap(
                  children: <Widget>[
                  Card(
                  elevation: 12.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: isGuardian?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                    child: KiButton.smallButton(
                      child: Text('Guardians (${duplicateGuardian.length})',
                        style: smallerTextStyle(color: isGuardian?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                      onPressed: (){
                        setState(() {
                          items.clear();
                          items.addAll(duplicateGuardian);
                          isGuardian=true;

                        });
                      },
                    ),
                  )),
                    Card(
                        elevation: 12.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: !isGuardian?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                          child: KiButton.smallButton(
                            child: Text('Employees (${kindergartenProfile.employeeFirstName.length})',
                              style: smallerTextStyle(color: !isGuardian?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                            onPressed: (){
                              setState(() {
                                items.clear();
                                items.addAll(duplicateEmployee);
                                isGuardian=false;
                              });
                            },
                          ),
                        )),
                ]),
                SizeConfig.mediumVerticalBox,
                KiTextField.borderedTextFormField(
                    controller: searchController,
                    titleText: 'Search',
                    hintText: 'Search ${isGuardian?'guardian, student name':'employee name, job title'}',
                    maxLines: 1,
                    onChanged: (value)async{
                      isGuardian? filterGuardianResults(value):filterEmployeeResults(value);
                    },
                    hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                    activeBorderColor: ThemeColor.themeBlueColor,
                    borderColor: ThemeColor.blueGreyColor,
                    radius: 25.0,
                    textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor)),
                SizeConfig.mediumVerticalBox,
                Container(
                  height: SizeConfig.safeBlockVertical*75,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, x) {
                      return KiButton.smallButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Chat(
                            uid: ownerProfile.uid,
                            peerId: items[x].uid,
                            peerName: items[x].name,
                            peerType: isGuardian? 'guardian':'employee',
                            type: 'owner',
                          )));
                        },
                        child: Card(
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: ThemeColor.whiteColor,
                          child: Padding(
                            padding: EdgeInsets.only(left:SizeConfig.extraSmall,right:SizeConfig.extraSmall,top:SizeConfig.extraSmall*1.1,bottom: SizeConfig.extraSmall*1.1),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(items[x].name,style:
                                  smallerTextStyle(color: ThemeColor.themeBlueColor),),
                                  SizeConfig.ultraSmallVerticalBox,
                                  Text(isGuardian? items[x].studentName:items[x].jobTitle,style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                                ]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading? Container(
          color:ThemeColor.whiteColor,
          child: Center(
          child: SizedBox(
          height: SizeConfig.safeBlockVertical * 5,
          width: SizeConfig.safeBlockVertical * 5,
          child: CircularProgressIndicator(
          backgroundColor: ThemeColor.whiteColor,
          ),
          ))):Container()
            ],
          );
  }

  void filterGuardianResults(String query){
    List dummySearchList = new List<GuardianReceiver>.from([]);
    dummySearchList.addAll(duplicateGuardian);
    if(query.isNotEmpty) {
      List dummyListData = new List<GuardianReceiver>.from([]);
      for(GuardianReceiver item in dummySearchList){
        if((item.name).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        else if(item.studentName.toLowerCase().contains(query.toLowerCase())){
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
        items.addAll(duplicateGuardian);
      });
    }
  }

  void filterEmployeeResults(String query) {
    List dummySearchList = new List<EmployeeReceiver>.from([]);
    dummySearchList.addAll(duplicateEmployee);
    if(query.isNotEmpty) {
      List dummyListData = new List<EmployeeReceiver>.from([]);
      for(EmployeeReceiver item in dummySearchList){
        if((item.name).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        else if(item.jobTitle.toLowerCase().contains(query.toLowerCase())){
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
        items.addAll(duplicateEmployee);
      });
    }
  }

}
