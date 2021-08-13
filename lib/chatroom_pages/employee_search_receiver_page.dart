import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/models/ChatRoomSearch.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class EmployeeSearchReceiverPage extends StatefulWidget {

  @override
  _EmployeeSearchReceiverPageState createState() => _EmployeeSearchReceiverPageState();
}

class _EmployeeSearchReceiverPageState extends State<EmployeeSearchReceiverPage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  EmployeeProfile employeeProfile = new EmployeeProfile();

  List duplicateGuardian = new List<GuardianReceiver>.from([]);
  List duplicateEmployee = new List<EmployeeReceiver>.from([]);
  List duplicateOwner = new List<OwnerReceiver>.from([]);

  var items =new List.from([]);
  List<String> guardianChecker;
  int type;
  TextEditingController searchController;

  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');
  CollectionReference owner = FirebaseFirestore.instance.collection('owner');

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading =true;
    guardianChecker=new List.from([]);
    searchController = new TextEditingController();
    type=0;
    guardianInit();
  }

  Future<void> ownerInit()async{
    try{
      for(String uid in kindergartenProfile.ownerUID){
        OwnerReceiver ownerReceiver = new OwnerReceiver();
        DocumentSnapshot documentSnapshot =await owner.doc(uid).get();
        ownerReceiver.name ='${documentSnapshot.data()['first name']} ${documentSnapshot.data()['last name']}';
        ownerReceiver.uid = uid;

        duplicateOwner.add(ownerReceiver);
      }
    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to connect database server.',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
    }
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
      await employeeInit();
      await ownerInit();
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
        items.addAll(duplicateOwner);
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
                          color: type==0?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                            child: KiButton.smallButton(
                              child: Text('Owner (${duplicateOwner.length})',
                                style: smallerTextStyle(color: type==0?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                              onPressed: (){
                                setState(() {
                                  items.clear();
                                  items.addAll(duplicateOwner);
                                  type=0;
                                });
                              },
                            ),
                          )),
                      Card(
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: type==1?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                            child: KiButton.smallButton(
                              child: Text('Guardians (${duplicateGuardian.length})',
                                style: smallerTextStyle(color: type==1?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                              onPressed: (){
                                setState(() {
                                  items.clear();
                                  items.addAll(duplicateGuardian);
                                  type=1;
                                });
                              },
                            ),
                          )),
                      Card(
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: type==2?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                            child: KiButton.smallButton(
                              child: Text('Employees (${kindergartenProfile.employeeFirstName.length})',
                                style: smallerTextStyle(color: type==2?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                              onPressed: (){
                                setState(() {
                                  items.clear();
                                  items.addAll(duplicateEmployee);
                                  type=2;
                                });
                              },
                            ),
                          )),
                    ]),
                SizeConfig.mediumVerticalBox,
                KiTextField.borderedTextFormField(
                    controller: searchController,
                    titleText: 'Search',
                    hintText: 'Search ${type==0? 'owner name': type==1?'guardian, student name':'employee name, job title'}',
                    maxLines: 1,
                    onChanged: (value)async{
                      type==0?filterOwnerResults(value):type==1? filterGuardianResults(value):filterEmployeeResults(value);
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
                            uid: employeeProfile.uid,
                            peerId: items[x].uid,
                            peerName: items[x].name,
                            peerType: type==0? 'owner':type==1?'guardian':'employee',
                            type: 'employee',
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
                                  Text(type==0? 'Owner':type==1? items[x].studentName:items[x].jobTitle,style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
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
            color: ThemeColor.whiteColor,
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

  void filterOwnerResults(String query){
    List dummySearchList = new List<OwnerReceiver>.from([]);
    dummySearchList.addAll(duplicateOwner);
    if(query.isNotEmpty) {
      List dummyListData = new List<OwnerReceiver>.from([]);
      for(OwnerReceiver item in dummySearchList){
        if((item.name).toLowerCase().contains(query.toLowerCase())) {
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
        items.addAll(duplicateOwner);
      });
    }
  }
  void filterGuardianResults(String query){
    List dummySearchList = new List<GuardianReceiver>();
    dummySearchList.addAll(duplicateGuardian);
    if(query.isNotEmpty) {
      List dummyListData = new List<GuardianReceiver>();
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
    List dummySearchList = new List<EmployeeReceiver>();
    dummySearchList.addAll(duplicateEmployee);
    if(query.isNotEmpty) {
      List dummyListData = new List<EmployeeReceiver>();
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
