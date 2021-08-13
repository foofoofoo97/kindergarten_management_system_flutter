import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/owner_function_pages/manage_results/manage_results_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class EmployeeManageResultsPage extends StatefulWidget {
  @override
  _EmployeeManageResultsPageState createState() => _EmployeeManageResultsPageState();
}

class _EmployeeManageResultsPageState extends State<EmployeeManageResultsPage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  EmployeeProfile employeeProfile = new EmployeeProfile();
  CollectionReference owner = FirebaseFirestore.instance.collection('owner');

  @override
  Widget build(BuildContext context) {
    switch(kindergartenProfile.canResults.elementAt(kindergartenProfile.employeeUID.indexOf(employeeProfile.uid))){
      case 0:
        return Scaffold(
          backgroundColor: ThemeColor.whiteColor,
          body: Container(
            padding: EdgeInsets.all(SizeConfig.medium),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.block,color: ThemeColor.redColor,size: SizeConfig.extraLarge*2.8,),
                SizeConfig.extraSmallVerticalBox,
                Text('Access To Student Result Management Feature Is Not Permitted By Kindergarten Owner',
                  style: smalllTextStyle(color: ThemeColor.themeBlueColor),
                  textAlign: TextAlign.center,),
                SizeConfig.smallVerticalBox,
                KiButton.rectButton(
                  color: ThemeColor.lightBlueColor,
                  child: Text('Contact Owner',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                  onPressed: ()async{
                    DocumentSnapshot document = await owner.doc(kindergartenProfile.ownerUID[0]).get();
                    Map data = document.data();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Chat(
                      uid: employeeProfile.uid,
                      peerId: kindergartenProfile.ownerUID[0],
                      peerName: '${data['first name']} ${data['last name']}',
                      peerType: 'owner',
                      type: 'employee',
                    )));
                  }
                ),
                SizeConfig.extraLargeVerticalBox
              ],
            ),
          ),
        );
      default:
        return ManageResultsPage();
    }
  }
}
