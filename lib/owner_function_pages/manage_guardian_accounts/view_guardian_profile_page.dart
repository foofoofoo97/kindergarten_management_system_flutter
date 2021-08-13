import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ViewGuardianProfilePage extends StatefulWidget {

  GuardianAcc guardianAcc;
  ViewGuardianProfilePage({this.guardianAcc});

  @override
  _ViewGuardianProfilePageState createState() => _ViewGuardianProfilePageState();
}

class _ViewGuardianProfilePageState extends State<ViewGuardianProfilePage> {

  OwnerProfile ownerProfile = new OwnerProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      appBar: kiAppBar(AppBarType.backButton, context),
      body: Padding(
        padding: EdgeInsets.only(left: SizeConfig.small,right: SizeConfig.small,top: SizeConfig.extraSmall),
        child: Column(
          children: <Widget>[
            Center(
              child: Image.asset('assets/user.png',height: SizeConfig.safeBlockVertical*6,),
            ),
            SizeConfig.extraSmallVerticalBox,
            Center(
              child:Text('Guardian Profile',style:smallTextStyle(color: ThemeColor.themeBlueColor),),
            ),
            SizeConfig.largeVerticalBox,
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
                  Text(widget.guardianAcc.firstName,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
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
                  Text(widget.guardianAcc.lastName,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
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
                  Text(widget.guardianAcc.contactNo,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
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
                  Text(widget.guardianAcc.homeAddress,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
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
                children: getChildrenWidget(widget.guardianAcc.childrenFirstName, widget.guardianAcc.childrenLastName, widget.guardianAcc.childrenAge)
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message,color: ThemeColor.whiteColor,size: SizeConfig.extraLarge,),
        backgroundColor: ThemeColor.themeBlueColor,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Chat(
            uid: ownerProfile.uid,
            peerId: widget.guardianAcc.uid,
            peerName: '${widget.guardianAcc.firstName} ${widget.guardianAcc.lastName}',
            peerType:  'guardian',
            type: 'owner',
          )));
        },
      ),
    );
  }

  List<Widget> getChildrenWidget(List<String> firstName, List<String> lastName, List<String> age){
    List<Widget> list = new List.from([]);
    list.add(SizeConfig.extraSmallVerticalBox);
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Children Name',style: smallererTextStyle(color: ThemeColor.blueColor),),
        Text('Children Age',style: smallererTextStyle(color: ThemeColor.blueColor),),
      ],
    ));
    list.add(SizeConfig.smallVerticalBox);
    for(int x=0;x<firstName.length;x++){
      list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('${firstName[x]} ${lastName[x]}',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
              Text('${age[x]} Years Old',style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
            ],
          )
      );
      list.add(SizeConfig.ultraSmallVerticalBox);
    }
    return list;
  }
}

