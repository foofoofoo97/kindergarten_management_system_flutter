import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/owner_function_pages/performance_analysis/manage_student_performance_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class EmployeeManagePerformancePage extends StatefulWidget {
  @override
  _EmployeeManagePerformancePageState createState() => _EmployeeManagePerformancePageState();
}

class _EmployeeManagePerformancePageState extends State<EmployeeManagePerformancePage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  EmployeeProfile employeeProfile = new EmployeeProfile();
  CollectionReference owner = FirebaseFirestore.instance.collection('owner');

  @override
  Widget build(BuildContext context) {
    switch(kindergartenProfile.canPerformance.elementAt(kindergartenProfile.employeeUID.indexOf(employeeProfile.uid))){
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
                Text('Access To Student Performance & Behaviour Analysis Tool Is Not Permitted By Kindergarten Owner',
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
        return ManageStudentPerformancePage(
          roleName: employeeProfile.jobTitle,
          name: '${employeeProfile.firstName} ${employeeProfile.lastName}',
        );
    }
  }
}
