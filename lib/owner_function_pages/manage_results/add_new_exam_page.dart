import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class AddNewExamPage extends StatefulWidget {
  @override
  _AddNewExamPageState createState() => _AddNewExamPageState();
}

class _AddNewExamPageState extends State<AddNewExamPage> {

  DateTime startDateTime;
  DateTime endDateTime;
  TextEditingController examController = new TextEditingController();
  bool noExamError;

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState
    noExamError = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KiPage(
      color: ThemeColor.whiteColor,
      scaffoldKey: _scaffoldKey,
      appBarType: AppBarType.backButton,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.small),
        child: Column(
          children: <Widget>[
            Text(
              'New Exam',
              style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor),
            ),
            SizeConfig.mediumVerticalBox,
            Form(
                key: _formKey,
                child: KiTextField.borderedTextFormField(
                activeBorderColor: ThemeColor.blueColor,
                borderColor: ThemeColor.themeBlueColor,
                controller: examController,
                titleText: 'Exam',
                maxLines: 1,
                hintText: 'Enter exam name',
                onSaved: (value) {
                  setState(() {
                    noExamError = Validators.compulsoryValidator(value);
                  });
                },
                noError: noExamError,
                errorText: 'Exam name cannot be empty',
                hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                errorStyle:
                    extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor))),
            SizeConfig.smallVerticalBox,
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.safeBlockVertical,
                  horizontal: SizeConfig.extraSmall),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                      color: ThemeColor.themeBlueColor, width: 1.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('Exam Start Date',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                  SizeConfig.smallHorizontalBox,
                  Expanded(child:Text(startDateTime==null?'':DateFormat('dd MMM yyyy').format(startDateTime),textAlign:TextAlign.center,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)),
                  KiButton.smallButton(
                      child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(SizeConfig.ultraSmall),
                            child:Icon(Icons.date_range,color: ThemeColor.themeBlueColor,)),
                        color: ThemeColor.whiteColor,
                        elevation: 10.0,
                      ),
                      onPressed: ()async{
                        DateTime date = await showRoundedDatePicker(
                          context: context,
                          theme: ThemeData(
                            primaryColor: ThemeColor.themeBlueColor,
                            accentColor: ThemeColor.themeBlueColor,
                            backgroundColor: ThemeColor.whiteColor,
                            textTheme: TextTheme(
                              bodyText1: smallerTextStyle(color: ThemeColor.themeBlueColor),
                              caption: smallerTextStyle(color: ThemeColor.themeBlueColor),
                            ),
                          ),
                          styleDatePicker: MaterialRoundedDatePickerStyle(
                              textStyleYearButton: mediumTextStyle(color: ThemeColor.whiteColor),
                              textStyleDayButton: largeTextStyle(color: ThemeColor.whiteColor),
                              textStyleMonthYearHeader: smallTextStyle(color: ThemeColor.blackColor)
                          ),
                          height: SizeConfig.safeBlockVertical*36,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          borderRadius: 16,
                        );

                        if(endDateTime==null||date.isBefore(endDateTime)){
                        setState(() {
                          startDateTime=date;
                        });
                      }
                      else{
                          _scaffoldKey.currentState
                              .showSnackBar(SnackBar(
                            backgroundColor: ThemeColor
                                .themeBlueColor
                                .withOpacity(0.8),
                            content: Text(
                              'Exam start date cannot after exam end date',
                              style: extraSmallTextStyle(
                                  color: ThemeColor
                                      .whiteColor),
                            ),
                          ));
                  }
                      }
                  )
                ],
              ),
            ),
            SizeConfig.smallVerticalBox,
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.safeBlockVertical,
                  horizontal: SizeConfig.extraSmall),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                      color: ThemeColor.themeBlueColor, width: 1.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('Exam End Date',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                  SizeConfig.smallHorizontalBox,
                  Expanded(child:Text(endDateTime==null?'':DateFormat('dd MMM yyyy').format(endDateTime),textAlign:TextAlign.center,style: smallerTextStyle(color: ThemeColor.themeBlueColor),)),
                  KiButton.smallButton(
                      child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(SizeConfig.ultraSmall),
                            child:Icon(Icons.date_range,color: ThemeColor.themeBlueColor,)),
                        color: ThemeColor.whiteColor,
                        elevation: 10.0,
                      ),
                      onPressed: ()async{
                          DateTime date = await showRoundedDatePicker(
                            context: context,
                            theme: ThemeData(
                                primaryColor: ThemeColor.themeBlueColor,
                                accentColor: ThemeColor.themeBlueColor,
                                backgroundColor: ThemeColor.whiteColor,
                                textTheme: TextTheme(
                                    bodyText1: smallerTextStyle(color: ThemeColor.themeBlueColor),
                                    caption: smallerTextStyle(color: ThemeColor.themeBlueColor),
                                ),
                            ),
                            styleDatePicker: MaterialRoundedDatePickerStyle(
                              textStyleYearButton: mediumTextStyle(color: ThemeColor.whiteColor),
                              textStyleDayButton: largeTextStyle(color: ThemeColor.whiteColor),
                              textStyleMonthYearHeader: smallTextStyle(color: ThemeColor.blackColor)
                            ),
                            height: SizeConfig.safeBlockVertical*36,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            borderRadius: 16,
                          );
                          if(startDateTime==null||startDateTime.isBefore(date)){
                            setState(() {
                              endDateTime=date;
                            });
                          }
                          else{
                            _scaffoldKey.currentState
                                .showSnackBar(SnackBar(
                              backgroundColor: ThemeColor
                                  .themeBlueColor
                                  .withOpacity(0.8),
                              content: Text(
                                'Exam end date cannot before exam start date',
                                style: extraSmallTextStyle(
                                    color: ThemeColor
                                        .whiteColor),
                              ),
                            ));
                          }
                      }
                  )
                ],
              ),
            ),
            SizeConfig.largeVerticalBox,
            KiButton.rectButton(
              color: ThemeColor.themeBlueColor,
              child: Text('Add',style: smallerTextStyle(color: ThemeColor.whiteColor),),
              onPressed: ()async{
                _formKey.currentState.save();
                if(noExamError&&startDateTime!=null&&endDateTime!=null) {
                  try {
                    await kindergarten.doc(kindergartenProfile.name).collection(
                        'exams').add({
                      'exam name': examController.text.toString(),
                      'examStartDate': startDateTime,
                      'examEndDate': endDateTime
                    });

                    _scaffoldKey.currentState
                        .showSnackBar(SnackBar(
                      backgroundColor: ThemeColor
                          .themeBlueColor
                          .withOpacity(0.8),
                      content: Text(
                        'Exam is added to database',
                        style: extraSmallTextStyle(
                            color: ThemeColor
                                .whiteColor),
                      ),
                    ));

                    Navigator.pop(context);

                  }catch(e){
                    _scaffoldKey.currentState
                        .showSnackBar(SnackBar(
                      backgroundColor: ThemeColor
                          .themeBlueColor
                          .withOpacity(0.8),
                      content: Text(
                        'Failed to connect database',
                        style: extraSmallTextStyle(
                            color: ThemeColor
                                .whiteColor),
                      ),
                    ));
                  }
                }
                else{
                  Fluttertoast.showToast(msg: 'Fields cannot be empty',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
                }
              }
            )
          ],
        ),
      ),
    );
  }
}
