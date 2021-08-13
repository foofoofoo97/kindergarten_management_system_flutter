import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';

class InfoMessageDialog extends StatefulWidget {

  String info;
  InfoMessageDialog({this.info});

  @override
  _InfoMessageDialogState createState() => _InfoMessageDialogState();
}

class _InfoMessageDialogState extends State<InfoMessageDialog> {

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: SingleChildScrollView(
        child: Container(
            height: SizeConfig.safeBlockVertical * 35,
            width: SizeConfig.safeBlockHorizontal * 80,
            padding: EdgeInsets.all(SizeConfig.smaller),
          child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizeConfig.mediumVerticalBox,
                  Icon(Icons.info,color: ThemeColor.accentCyanColor,size: SizeConfig.largest,),
                  SizeConfig.mediumVerticalBox,
                  Text(widget.info,style: smallerTextStyle(color: ThemeColor.themeBlueColor),textAlign: TextAlign.center,),
                  SizeConfig.smallVerticalBox
                ],
              ),
            )),
      );
  }
}
