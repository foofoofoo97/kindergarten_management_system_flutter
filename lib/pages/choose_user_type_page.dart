import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:toggle_switch/toggle_switch.dart';

//KIUPDATE :DO SWITCH
class ChooseUserTypePage extends StatelessWidget {

  String uid;
  VoidCallback signOutCallback;
  VoidCallback employeeCallback;
  VoidCallback ownerCallback;
  VoidCallback guardianCallback;
  ChooseUserTypePage({this.signOutCallback,this.uid,this.ownerCallback,this.employeeCallback,this.guardianCallback});
  String accountType = 'employee';
  List<String> accountTypes =['owner', 'employee', 'guardian'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      body: Container(
        alignment: Alignment.center,
        padding:  EdgeInsets.all(SizeConfig.small),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, User',style: smalllTextStyle(color: ThemeColor.themeBlueColor),),
            SizeConfig.extraSmallVerticalBox,
            Text('Choose Your Role', style: largeTextStyle(color:ThemeColor.themeBlueColor)),
            SizeConfig.extraLargeVerticalBox,
            ToggleSwitch(
              minWidth: SizeConfig.safeBlockHorizontal*25,
              minHeight: SizeConfig.safeBlockVertical*7,
              fontSize: SizeConfig.smaller*0.9,
              initialLabelIndex: 1,
              activeBgColor: ThemeColor.themeBlueColor,
              activeFgColor: ThemeColor.whiteColor,
              inactiveBgColor: ThemeColor.lightBlueColor,
              inactiveFgColor: ThemeColor.blueGreyColor,
              labels: ['OWNER','EMPLOYEE','GUARDIAN'],
              onToggle: (index) {
                accountType = accountTypes.elementAt(index);
              },
            ),
            SizeConfig.largeVerticalBox,
            SizeConfig.largeVerticalBox,
            KiButton.circleButton(
                color: ThemeColor.themeBlueColor,
                child: Icon(Icons.navigate_next,color: ThemeColor.whiteColor,size: SizeConfig.ultraLarge,),
                onPressed: () async {
                    if(accountType=='employee')
                      employeeCallback();
                    else if(accountType == 'guardian')
                      guardianCallback();
                    else ownerCallback();
                }
            ),
            SizeConfig.extraLargeVerticalBox,
            KiButton.smallButton(
                child: Card(
                    color: ThemeColor.whiteColor,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child:Padding(
                      padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
                      child:Icon(Icons.exit_to_app,color: ThemeColor.redColor,size: SizeConfig.large,),)),
                onPressed: (){
                  signOutCallback();
                }
            ),
          //  SizeConfig.extraLargeVerticalBox,
          ],
        ),
      ),
    );
  }
}


