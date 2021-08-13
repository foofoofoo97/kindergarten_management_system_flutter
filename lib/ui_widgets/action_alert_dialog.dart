import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class ActionAlertDialog extends StatefulWidget {
  String title;
  String msg;
  Function onPressed;
  ActionAlertDialog({this.title,this.msg,this.onPressed});
  @override
  _ActionAlertDialogState createState() => _ActionAlertDialogState();
}

class _ActionAlertDialogState extends State<ActionAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: Container(
        height: SizeConfig.safeBlockVertical * 45,
        width: SizeConfig.safeBlockHorizontal * 80,
        padding: EdgeInsets.all(SizeConfig.small),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/alert.png',
              height: SizeConfig.safeBlockVertical*15,
            ),
            SizeConfig.smallVerticalBox,
            Text(widget.title,style: smalllTextStyle(color: ThemeColor.redColor),),
            SizeConfig.extraSmallVerticalBox,
            Text(widget.msg, style: smallerTextStyle(color: ThemeColor.blueColor),textAlign: TextAlign.center,),
            SizeConfig.mediumVerticalBox,
            KiButton.rectButton(
              child: Text('Confirm',style: smallerTextStyle(color: ThemeColor.whiteColor),),
              color: ThemeColor.blueColor,
              onPressed: (){
                widget.onPressed();
              }
            )
          ])));
  }
}
