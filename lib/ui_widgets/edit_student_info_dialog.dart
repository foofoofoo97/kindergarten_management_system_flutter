import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class EditStudentInfoDialog extends StatefulWidget {
  int index;
  Function onPressed;

  EditStudentInfoDialog({this.index,this.onPressed});

  @override
  _EditStudentInfoDialogState createState() => _EditStudentInfoDialogState();
}

class _EditStudentInfoDialogState extends State<EditStudentInfoDialog> {
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  TextEditingController ageController = new TextEditingController();
  bool noAgeError;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    noAgeError=true;
    isLoading=false;
    ageController.text=kindergartenProfile.studentAge[widget.index].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: SingleChildScrollView(
          child: Container(
            height: SizeConfig.safeBlockVertical * 50,
            width: SizeConfig.safeBlockHorizontal * 80,
            padding: EdgeInsets.all(SizeConfig.smaller),
            child:Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizeConfig.mediumVerticalBox,
                    Text('Update Student Information',style: smalllTextStyle(color: ThemeColor.themeBlueColor),),
                    SizeConfig.mediumVerticalBox,
                    KiTextField.borderedTextFormField(
                      enabled: false,
                      activeBorderColor: ThemeColor.blueColor,
                      borderColor: ThemeColor.themeBlueColor,
                      controller: TextEditingController(text: kindergartenProfile.studentFirstName[widget.index]),
                      titleText: 'First Name',
                      maxLines: 1,
                      textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                      errorStyle:
                      extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor
                                  )),
                    SizeConfig.smallVerticalBox,
                    KiTextField.borderedTextFormField(
                        enabled: false,
                        activeBorderColor: ThemeColor.blueColor,
                        borderColor: ThemeColor.themeBlueColor,
                        controller: TextEditingController(text: kindergartenProfile.studentLastName[widget.index]),
                        titleText: 'Last Name',
                        maxLines: 1,
                        textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                        errorStyle:
                        extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                        labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor
                        )),
                    SizeConfig.smallVerticalBox,
                    Form(
                      key: _formKey,
                        child:
                    KiTextField.borderedTextFormField(
                        activeBorderColor: ThemeColor.blueColor,
                        borderColor: ThemeColor.themeBlueColor,
                        controller: ageController,
                        titleText: 'Age',
                        maxLines: 1,
                        hintText: 'Enter student age',
                        onSaved: (value) {
                          setState(() {
                            noAgeError =Validators.numberValidator(value);
                          });
                        },
                        noError: noAgeError,
                        errorText: 'Student age cannot be empty or less than 0',
                        hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                        textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                        errorStyle:
                        extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                        labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor
                        ))),
                    SizeConfig.mediumVerticalBox,
                    KiButton.rectButton(
                      onPressed: ()async{
                        _formKey.currentState.save();
                        if(noAgeError){
                          setState(() {
                            isLoading=true;
                          });
                          await widget.onPressed(ageController.text.toString());
                          setState(() {
                            isLoading=false;
                          });
                          Navigator.pop(context);
                        }
                      },
                      color: ThemeColor.lightBlueColor,
                      child: Text('Update',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                    )
                  ],
                ),
                isLoading
                    ? Center(
                  child: SizedBox(
                    height: SizeConfig.safeBlockVertical * 5,
                    width: SizeConfig.safeBlockVertical * 5,
                    child: CircularProgressIndicator(
                      backgroundColor: ThemeColor.whiteColor,
                    ),
                  ),
                ): Container()
              ],
            ),
          )),
    );
  }
}
