import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class AddDashboardMessageDialog extends StatefulWidget {

  Function onPressed;
  TextEditingController titleController;
  TextEditingController subtitleController;

  AddDashboardMessageDialog({this.titleController,this.subtitleController,this.onPressed});

  @override
  _AddDashboardMessageDialogState createState() => _AddDashboardMessageDialogState();
}

class _AddDashboardMessageDialogState extends State<AddDashboardMessageDialog> {

  bool noTitleError;
  bool noSubtitleError;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    noSubtitleError=true;
    noTitleError =true;
  }
  @override
  Widget build(BuildContext context) {
    return  Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: Container(
          height: SizeConfig.safeBlockVertical * 45,
          width: SizeConfig.safeBlockHorizontal * 80,
          child: Form(
            key: _formKey,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('New Message',style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor)),
                SizeConfig.mediumVerticalBox,
                KiTextField.borderlessTextFormField(
                    controller: widget.titleController,
                    titleText: 'Title',
                    hintText: 'Enter message title',
                    onSaved: (value){
                      setState(() {
                        noTitleError = Validators.compulsoryValidator(value);
                      });
                    },
                    maxLines: 1,
                    noError: noTitleError,
                    textStyle: smallerTextStyle(color: ThemeColor.blackColor),
                    errorText: 'Title cannot be empty',
                    errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.blackColor)
                ),
                SizeConfig.smallVerticalBox,
                KiTextField.borderlessTextFormField(
                    controller: widget.subtitleController,
                    titleText: 'Content',
                    maxLines: 3,
                    hintText: 'Enter message content',
                    onSaved: (value){
                      setState(() {
                        noSubtitleError = Validators.compulsoryValidator(value);
                      });
                    },
                    noError: noSubtitleError,
                    errorText: 'Content cannot be empty',
                    textStyle: smallerTextStyle(color: ThemeColor.blackColor),
                    errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.blackColor)
                ),
                SizeConfig.largeVerticalBox,
                KiButton.rectButton(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.medium,vertical: SizeConfig.blockSizeVertical),
                    child: Text('ADD',style: smallerTextStyle(color: ThemeColor.whiteColor),),
                    color: ThemeColor.themeBlueColor,
                    onPressed: (){
                      _formKey.currentState.save();
                      if(noSubtitleError&&noTitleError){
                        widget.onPressed();
                      }
                    }
                ),
              ],
            ),
          )),
    );
  }
}
