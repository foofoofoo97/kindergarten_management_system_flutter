import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ManageBillSettingsPage extends StatefulWidget {
  @override
  _ManageBillSettingsPageState createState() => _ManageBillSettingsPageState();
}

class _ManageBillSettingsPageState extends State<ManageBillSettingsPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int day;
  List<int>days =[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30];

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();


  @override
  void initState() {
    // TODO: implement initState
    day=kindergartenProfile.dayToBill;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KiPage(
      scaffoldKey: _scaffoldKey,
      appBarType: AppBarType.backButton,
      color: ThemeColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.small),
        child: Column(
          children: <Widget>[
            Center(
              child: Text('Bill Settings',style: mediumSTextStyle(color: ThemeColor.themeBlueColor),),
            ),
            SizeConfig.mediumVerticalBox,
            Container(
              padding: EdgeInsets.symmetric(
                    vertical: SizeConfig
                        .safeBlockVertical,
                    horizontal:
                    SizeConfig.smaller),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                      color: ThemeColor.themeBlueColor, width: 1.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Day No To Start Collect Fees',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                  DropdownButton<int>(
                    isExpanded: false,
                    hint: Text(
                      "Select Day",
                      style: smallerTextStyle(
                          color: ThemeColor.blueGreyColor),
                    ),
                    underline:
                    Container(),
                    value: day,
                    onChanged: (int value) {
                      setState(() {
                        day = value;
                      });
                    },
                    items: days.map(
                            (int day) {
                          return DropdownMenuItem<int>(
                            value: day,
                            child: Text(day.toString(),
                                style: smallerTextStyle(
                                    color: ThemeColor
                                        .themeBlueColor),),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            SizeConfig.extraLargeVerticalBox,
            KiButton.rectButton(
              color: ThemeColor.themeBlueColor,
              child: Text('Set',style: smallerTextStyle(color: ThemeColor.whiteColor),),
              onPressed: ()async{
                try {
                  kindergartenProfile.dayToBill=day;
                  await kindergarten.doc(kindergartenProfile.name).update({
                    'date to bill': day
                  });
                  Navigator.pop(context);
                }catch(e){
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
                    content: Text(
                      'Connection failed. Please check your connection',
                      style: extraSmallTextStyle(color: ThemeColor.whiteColor),
                    ),
                  ));
                }
              }
            )
          ],
        ),
      ),
    );
  }
}
