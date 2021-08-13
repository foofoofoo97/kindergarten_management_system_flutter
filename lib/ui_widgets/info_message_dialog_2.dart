import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';

class InfoMessageDialog2 extends StatefulWidget {
  Widget child;
  double height;

  InfoMessageDialog2({this.child,this.height});
  @override
  _InfoMessageDialog2State createState() => _InfoMessageDialog2State();
}

class _InfoMessageDialog2State extends State<InfoMessageDialog2> {
  @override
  Widget build(BuildContext context) {
    return  Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: SingleChildScrollView(
          child: Container(
            height: widget.height,
            width: SizeConfig.safeBlockHorizontal * 80,
            padding: EdgeInsets.all(SizeConfig.smaller),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizeConfig.mediumVerticalBox,
                Icon(Icons.info,color: ThemeColor.blueColor,size: SizeConfig.largest,),
                SizeConfig.mediumVerticalBox,
                widget.child,
                SizeConfig.smallVerticalBox
              ],
            ),
          )),
    );  }
}
