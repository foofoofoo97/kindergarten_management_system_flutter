import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/models/ChatRoomSearch.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class GuardianSearchReceiverPage extends StatefulWidget {

  @override
  _GuardianSearchReceiverPageState createState() => _GuardianSearchReceiverPageState();
}

class _GuardianSearchReceiverPageState extends State<GuardianSearchReceiverPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GuardianProfile guardianProfile = new GuardianProfile();

  List duplicateEmployee = new List<EmployeeReceiver>.from([]);
  List duplicateOwner = new List<OwnerReceiver>.from([]);

  var items =new List.from([]);
  List<String> guardianChecker;
  bool isOwner;
  TextEditingController searchController;

  CollectionReference owner = FirebaseFirestore.instance.collection('owner');
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading =true;
    guardianChecker=new List.from([]);
    searchController = new TextEditingController();
    isOwner=true;
    init();
  }

  Future<void> init()async{
    try{
      for(String kindergartenName in guardianProfile.childrenKindergarten.toSet().toList()){
        DocumentSnapshot documentSnapshot = await kindergarten.doc(kindergartenName).get();
        Map data = documentSnapshot.data();
          for(String uid in List.from(data['owner uid'])){
            OwnerReceiver ownerReceiver = new OwnerReceiver();
            DocumentSnapshot documentSnapshot =await owner.doc(uid).get();
            ownerReceiver.name ='${documentSnapshot.data()['first name']} ${documentSnapshot.data()['last name']}';
            ownerReceiver.uid = uid;
            ownerReceiver.kindergarten = kindergartenName;
            duplicateOwner.add(ownerReceiver);
          }

          for(int x =0; x<List.from(data['employee uid']).length;x++){
            EmployeeReceiver employeeReceiver = new EmployeeReceiver();
            employeeReceiver.name = '${List.from(data['employee first name'])[x]} ${List.from(data['employee last name'])[x]}';
            employeeReceiver.uid = List.from(data['employee uid'])[x];
            employeeReceiver.kindergarten = kindergartenName;
            employeeReceiver.jobTitle = List.from(data['employee job title'])[x];
            duplicateEmployee.add(employeeReceiver);
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
                          color: isOwner?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                            child: KiButton.smallButton(
                              child: Text('Owner (${duplicateOwner.length})',
                                style: smallerTextStyle(color: isOwner?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                              onPressed: (){
                                setState(() {
                                  items.clear();
                                  items.addAll(duplicateOwner);
                                  isOwner=true;
                                });
                              },
                            ),
                          )),
                      Card(
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: !isOwner?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
                            child: KiButton.smallButton(
                              child: Text('Employees (${duplicateEmployee.length})',
                                style: smallerTextStyle(color: !isOwner?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                              onPressed: (){
                                setState(() {
                                  items.clear();
                                  items.addAll(duplicateEmployee);
                                  isOwner=false;
                                });
                              },
                            ),
                          )),
                    ]),
                SizeConfig.mediumVerticalBox,
                KiTextField.borderedTextFormField(
                    controller: searchController,
                    titleText: 'Search',
                    hintText: 'Search ${isOwner? 'owner name, kindergarten': 'employee name, job title, kindergarten'}',
                    maxLines: 1,
                    onChanged: (value)async{
                      isOwner?filterOwnerResults(value):filterEmployeeResults(value);
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
                            uid: guardianProfile.uid,
                            peerId: items[x].uid,
                            peerName: items[x].name,
                            peerType: isOwner? 'owner':'employee',
                            type: 'guardian',
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
                                  Text(isOwner? 'Owner':items[x].jobTitle,style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                                  SizeConfig.ultraSmallVerticalBox,
                                  Text(items[x].kindergarten,style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
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

  void filterOwnerResults(String query){
    List dummySearchList = new List<OwnerReceiver>();
    dummySearchList.addAll(duplicateOwner);
    if(query.isNotEmpty) {
      List dummyListData = new List<OwnerReceiver>();
      for(OwnerReceiver item in dummySearchList){
        if((item.name).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        if((item.kindergarten).toLowerCase().contains(query.toLowerCase())) {
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
        else if(item.kindergarten.toLowerCase().contains(query.toLowerCase())){
          dummyListData.add(item);
        }      }
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
