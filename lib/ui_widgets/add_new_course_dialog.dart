import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class AddNewCourseDialog extends StatefulWidget {

  Function onPressed;
  TextEditingController nameController;
  TextEditingController ageController;
  TextEditingController detailsController;
  int type;
  AddNewCourseDialog({this.type,this.nameController,this.detailsController,this.ageController,this.onPressed});

  @override
  _AddNewCourseDialogState createState() => _AddNewCourseDialogState();
}

class _AddNewCourseDialogState extends State<AddNewCourseDialog> {

  bool noTitleError;
  bool noAgeError;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    noAgeError=true;
    noTitleError =true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: Container(
          height: SizeConfig.safeBlockVertical * 53,
          width: SizeConfig.safeBlockHorizontal * 80,
          padding: EdgeInsets.all(SizeConfig.extraSmall),
          child: Form(
            key: _formKey,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.type==0?'New Course':'Edit Course',style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor)),
                SizeConfig.mediumVerticalBox,
                KiTextField.borderedTextFormField(
                    activeBorderColor: ThemeColor.blueColor,
                    borderColor: ThemeColor.themeBlueColor,
                    controller: widget.nameController,
                    titleText: 'Course',
                    hintText: 'Enter course name',
                    onSaved: (value){
                      setState(() {
                        noTitleError = Validators.compulsoryValidator(value);
                      });
                    },
                    maxLines: 1,
                    noError: noTitleError,
                    textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                    hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                    errorText: 'Course name cannot be empty',
                    errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor)
                ),
                SizeConfig.extraSmallVerticalBox,
                KiTextField.borderedTextFormField(
                    activeBorderColor: ThemeColor.blueColor,
                    borderColor: ThemeColor.themeBlueColor,
                    controller: widget.ageController,
                    textInputType: TextInputType.number,
                    titleText: 'Student Age',
                    maxLines: 1,
                    hintText: 'Enter age of student who take this course',
                    hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                    onSaved: (value){
                      setState(() {
                        noAgeError = Validators.numberValidator(value);
                      });
                    },
                    noError: noAgeError,
                    errorText: 'Student age cannot be empty',
                    textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                    errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor)
                ),
                SizeConfig.extraSmallVerticalBox,
                KiTextField.borderedTextFormField(
                    activeBorderColor: ThemeColor.blueColor,
                    borderColor: ThemeColor.themeBlueColor,
                    controller: widget.detailsController,
                    titleText: 'Details',
                    hintText: 'Enter course details',
                    maxLines: 3,
                    noError: true,
                    hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                    textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                    errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor)
                ),
                SizeConfig.largeVerticalBox,
                KiButton.rectButton(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.medium,vertical: SizeConfig.blockSizeVertical),
                    child: Text('ADD',style: smallerTextStyle(color: ThemeColor.whiteColor),),
                    color: ThemeColor.themeBlueColor,
                    onPressed: (){
                      _formKey.currentState.save();
                      if(noAgeError&&noTitleError){
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
