import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class StudentPerformanceResultPage extends StatefulWidget {
  Student student;
  String roleName;
  String name;
  StudentPerformanceResultPage({this.student,this.roleName,this.name});
  
  @override
  _StudentPerformanceResultPageState createState() => _StudentPerformanceResultPageState();
}

class _StudentPerformanceResultPageState extends State<StudentPerformanceResultPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  CollectionReference student = FirebaseFirestore.instance.collection('student');

  TextEditingController commentController = new TextEditingController();
  bool noError;
  bool isLoading;
  
  @override
  void initState() {
    // TODO: implement initState
    noError=true;
    isLoading=false;
    commentController.text=widget.student.performance['comment'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiPage(
          scaffoldKey: _scaffoldKey,
          color: ThemeColor.whiteColor,
          appBarType: AppBarType.backButton,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.medium),
            child: Column(
              children: <Widget>[
                Text('${widget.student.firstName} ${widget.student.lastName}',style: smalllTextStyle(color: ThemeColor.themeBlueColor),),
                SizeConfig.ultraSmallVerticalBox,
                Text('Performance & Behaviour Analysis Result',style: smalllTextStyle(color: ThemeColor.themeBlueColor),),
                SizeConfig.largeVerticalBox,
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.safeBlockVertical,
                      horizontal: SizeConfig.extraSmall),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: ThemeColor.lightBlueGreyColor, width: 1.0)),
                  child: Text(widget.student.performance['result'], style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                ),
                SizeConfig.smallVerticalBox,
                Form(
                    key: _formKey,
                    child: KiTextField.borderedTextFormField(
                        activeBorderColor: ThemeColor.blueColor,
                        borderColor: ThemeColor.themeBlueColor,
                        controller: commentController,
                        titleText: 'Comment',
                        maxLines: 3,
                        hintText: 'Enter your comment',
                        onSaved: (value) {
                          setState(() {
                            noError = Validators.compulsoryValidator(value);
                          });
                        },
                        noError: noError,
                        errorText: 'Comment cannot be empty',
                        hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                        textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                        errorStyle:
                        extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                        labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor))),
                SizeConfig.extraLargeVerticalBox,
                KiButton.rectButton(
                  color: ThemeColor.blueColor,
                  child: Text('Submit',style: smallerTextStyle(color: ThemeColor.whiteColor),),
                  onPressed: ()async{
                    setState(() {
                      isLoading=true;
                    });
                    _formKey.currentState.save();
                    if(noError) {
                      Map performance = widget.student.performance;
                      performance['comment'] = commentController.text.toString();
                      performance['datetime']=Timestamp.fromDate(DateTime.now());
                      performance['byRole']=widget.roleName;
                      performance['byName']=widget.name;
                      await student.doc(widget.student.uid).update({
                        'performance': performance
                      });

                      Navigator.pop(context);
                    }
                    else{
                      Fluttertoast.showToast(msg: 'Please fill in your comment',
                          fontSize: SizeConfig.smaller,
                          backgroundColor: ThemeColor.themeBlueColor,
                          textColor: ThemeColor.whiteColor);
                    }

                    setState(() {
                      isLoading=false;
                    });
                  }
                )
              ],
            ),
          ),
        ),
        isLoading?Center(
          child: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            width: SizeConfig.safeBlockVertical * 5,
            child: CircularProgressIndicator(
              backgroundColor: ThemeColor.whiteColor,
            ),
          ),
        )
            : Container()
      ],
    );
  }
}
