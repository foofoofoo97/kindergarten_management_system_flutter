import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/owner_function_pages/manage_guardian_accounts/view_guardian_profile_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ManageGuardianAccountsPage extends StatefulWidget {

  @override
  _ManageGuardianAccountsPageState createState() => _ManageGuardianAccountsPageState();
}

class _ManageGuardianAccountsPageState extends State<ManageGuardianAccountsPage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  OwnerProfile ownerProfile = new OwnerProfile();

  List<String> guardianIDs = new List.from([]);
  TextEditingController searchController = new TextEditingController();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');
  Map<String,GuardianAcc> guardianAccs = new Map();
  Map<String, GuardianAcc> items = new Map();

  bool isLoading;
  int open;

  @override
  void initState() {
    // TODO: implement initState
    isLoading=true;
    open =0;
    init();
    super.initState();
  }

  Future<void> init()async{
    try {
      kindergartenProfile.studentUID.forEach((id) {
        String guardianId = id.split('+')[0];
        if (!guardianIDs.contains(guardianId)) {
          guardianIDs.add(guardianId);
        }
      });
      for (String guardianId in guardianIDs) {
        DocumentSnapshot documentSnapshot = await guardian.doc(guardianId).get();
        Map data = documentSnapshot.data();
        GuardianAcc guardianAcc = new GuardianAcc();
        guardianAcc.firstName = data['first name'];
        guardianAcc.lastName = data['last name'];
        guardianAcc.uid = guardianId;
        guardianAcc.homeAddress =data['home address'];
        guardianAcc.contactNo = data['contact no'];

        guardianAcc.childrenKindergarten = List.from(data['children kindergarten']);
        guardianAcc.childrenFirstName = List.from(data['children first name']);
        guardianAcc.childrenLastName = List.from(data['children last name']);
        guardianAcc.childrenAge = List.from(data['children age']);
        guardianAcc.childrenUID = List.from(data['children uid']);
        List<String> temp = List.from(data['children kindergarten']);
        List<String> temp2 = List.from(data['children uid']);
        for(int index =0; index<temp2.length;index++){
          if(temp[index]!=kindergartenProfile.name){
            int x=guardianAcc.childrenUID.indexOf(temp2[index]);
            guardianAcc.childrenKindergarten.removeAt(x);
            guardianAcc.childrenFirstName.removeAt(x);
            guardianAcc.childrenLastName.removeAt(x);
            guardianAcc.childrenAge.removeAt(x);
            guardianAcc.childrenUID.removeAt(x);
          }
        }
        guardianAccs.putIfAbsent(guardianId, () => guardianAcc);
      }
      items.addAll(guardianAccs);
      setState(() {
        isLoading=false;
      });
    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to connect server',fontSize: SizeConfig.smaller, textColor: ThemeColor.whiteColor, backgroundColor: ThemeColor.themeBlueColor);
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
              valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeColor.blueColor)
          ),
        ),
      ),
    ):Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      appBar: kiAppBar(AppBarType.backButton, context),
      body: Padding(
        padding: EdgeInsets.only(left: SizeConfig.small,right: SizeConfig.small, top: SizeConfig.extraSmall),
        child: Column(
          children: <Widget>[
            Center(child:
              Text('Guardian Accounts',style: mediumSTextStyle(color: ThemeColor.themeBlueColor),)),
            SizeConfig.smallVerticalBox,
            Padding(
              padding: EdgeInsets.all(SizeConfig.extraSmall),
              child: KiTextField.borderedTextFormField(
                  controller: searchController,
                  titleText: 'Search',
                  hintText: 'Search guardian, student',
                  maxLines: 1,
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  hintStyle:
                  smallerTextStyle(color: ThemeColor.blueGreyColor),
                  activeBorderColor: ThemeColor.themeBlueColor,
                  borderColor: ThemeColor.blueGreyColor,
                  radius: 25.0,
                  textStyle:
                  smallerTextStyle(color: ThemeColor.themeBlueColor),
                  labelStyle:
                  smallerTextStyle(color: ThemeColor.themeBlueColor)),
            ),
            SizeConfig.ultraSmallVerticalBox,
            Expanded(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, x) {
                  return Card(
                    color:  ThemeColor.whiteColor,
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.all(SizeConfig.safeBlockVertical),
                      leading: IconButton(
                        icon: Icon(Icons.message,color: ThemeColor.lightBlueColor2,),
                        iconSize: SizeConfig.large,
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Chat(
                            uid: ownerProfile.uid,
                            peerId: items.values.toList()[x].uid,
                            peerName: '${items.values.toList()[x].firstName} ${items.values.toList()[x].lastName}',
                            peerType:  'guardian',
                            type: 'owner',
                          )));
                        },
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context)=> ViewGuardianProfilePage(guardianAcc: items.values.toList()[x],)
                        ));
                      },
                      trailing: IconButton(
                        icon:Icon(open==x?Icons.expand_less:Icons.expand_more,color: ThemeColor.lightBlueColor2),
                        iconSize: SizeConfig.extraLarge,
                        onPressed: (){
                          setState(() {
                            open==x? open=null: open=x;
                          });
                        },
                      ),
                      title: Text(
                        '${items.values.toList()[x].firstName} ${items.values.toList()[x].lastName}',
                        style: smallerTextStyle(
                            color: ThemeColor.themeBlueColor),
                      ),
                      subtitle:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: open!=x?[
                              SizeConfig.ultraSmallVerticalBox,
                              Text(
                              getChildren(items.values.toList()[x].childrenFirstName, items.values.toList()[x].childrenLastName),
                              style: smallererTextStyle(
                                  color: ThemeColor.blueGreyColor),
                            )]:getChildrenWidget(items.values.toList()[x].childrenFirstName, items.values.toList()[x].childrenLastName,
                            items.values.toList()[x].childrenAge),
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getChildren(List<String> firstName, List<String> lastName){
    String temp= '';
    for(int x=0; x<firstName.length;x++){
      temp = '${firstName[x]} ${lastName[x]}, '+temp;
    }
    temp=temp.substring(0, temp.length-2);

    return temp;
  }

  List<Widget> getChildrenWidget(List<String> firstName, List<String> lastName, List<String> age){
    List<Widget> list = new List.from([]);
    list.add(SizeConfig.extraSmallVerticalBox);
    for(int x=0;x<firstName.length;x++){
      list.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('${firstName[x]} ${lastName[x]}',style: smallererTextStyle(color: ThemeColor.blueColor),),
            Text('${age[x]} Years Old',style: smallererTextStyle(color: ThemeColor.blueGreyColor),)
          ],
        )
      );
      list.add(SizeConfig.ultraSmallVerticalBox);
    }
    return list;
  }

  void filterSearchResults(String query) {
    Map<String, GuardianAcc> dummySearchList = new Map();
    dummySearchList.addAll(guardianAccs);
    if (query.isNotEmpty) {
      Map<String,GuardianAcc> dummyListData = new Map();
      dummySearchList.forEach((key,item) {
        if (('${item.firstName} ${item.lastName}')
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.putIfAbsent(key, () => item);
        } else if (getChildren(item.childrenFirstName, item.childrenLastName).toLowerCase().contains(query)) {
          dummyListData.putIfAbsent(key, () => item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(guardianAccs);
      });
    }
  }
}
