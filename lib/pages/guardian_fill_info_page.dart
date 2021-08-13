import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/Kindergarten.dart';
import 'package:kiki/pages/guardian_fill_children_info_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class GuardianFillInfoPage extends StatefulWidget {
  bool showLogout;
  String uid;
  VoidCallback logoutCallback;
  VoidCallback newGuardianCallback;

  GuardianFillInfoPage({this.uid,this.newGuardianCallback,this.showLogout=true,this.logoutCallback});

  @override
  _GuardianFillInfoPageState createState() => _GuardianFillInfoPageState();
}

class _GuardianFillInfoPageState extends State<GuardianFillInfoPage> {

  //General Information
  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController contactNoController;
  TextEditingController homeAddressController;
  TextEditingController childrenNoController;

  bool noFirstNameError;
  bool noLastNameError;
  bool noContactNoError;
  bool noHomeAddressError;
  bool noChildrenNoError;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noFirstNameError =true;
    noLastNameError = true;
    noContactNoError =true;
    noHomeAddressError= true;
    noChildrenNoError =true;

    firstNameController = new TextEditingController();
    lastNameController = new TextEditingController();
    contactNoController = new TextEditingController();
    homeAddressController = new TextEditingController();
    childrenNoController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return KiCenterPage(
      scaffoldKey: _scaffoldKey,
      appBarType: widget.showLogout? null: AppBarType.backButton,
      color: ThemeColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizeConfig.extraSmallVerticalBox,
            widget.showLogout? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                KiButton.smallButton(
                    child: Text('Sign Out',style: smallerTextStyle(color: ThemeColor.redColor),),
                    onPressed: (){
                      widget.logoutCallback();
                    }
                )
              ],
            ):SizeConfig.extraSmallVerticalBox,
            SizeConfig.largeVerticalBox,
            Text('New Guardian',style: largeTextStyle(color: ThemeColor.themeBlueColor),),
            SizeConfig.ultraSmallVerticalBox,
            Text('Please fill in below information first',
                style:smallerTextStyle(color: ThemeColor.blackColor)),
            SizeConfig.mediumVerticalBox,
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Personal Information',style:smallTextStyle(color: ThemeColor.themeBlueColor)),
                  SizeConfig.smallVerticalBox,
                  KiTextField.borderlessTextFormField(
                      controller: firstNameController,
                      titleText: 'First Name',
                      hintText: 'Enter your first name',
                      onSaved: (value){
                        setState(() {
                          noFirstNameError = Validators.compulsoryValidator(value);
                        });
                      },
                      noError: noFirstNameError,
                      errorText: 'First name cannot be empty',
                      errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                      textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  ),
                  SizeConfig.extraSmallVerticalBox,
                  KiTextField.borderlessTextFormField(
                      controller: lastNameController,
                      titleText: 'Last Name',
                      hintText: 'Enter your last name',
                      onSaved: (value){
                        setState(() {
                          noLastNameError = Validators.compulsoryValidator(value);
                        });
                      },
                      noError: noLastNameError,
                      errorText: 'Last name cannot be empty',
                      errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                      textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  ),
                  SizeConfig.extraSmallVerticalBox,
                  KiTextField.borderlessTextFormField(
                      controller: contactNoController,
                      textInputType: TextInputType.number,
                      titleText: 'Contact No',
                      hintText: 'Enter your contact no.',
                      onSaved: (value){
                        setState(() {
                          noContactNoError = Validators.compulsoryValidator(value);
                        });
                      },
                      noError: noContactNoError,
                      errorText: 'Contact no. cannot be empty',
                      errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                      textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  ),
                  SizeConfig.extraSmallVerticalBox,
                  KiTextField.borderlessTextFormField(
                      controller: homeAddressController,
                      titleText: 'Home Address',
                      hintText: 'Enter your home address',
                      onSaved: (value){
                        setState(() {
                          noHomeAddressError = Validators.compulsoryValidator(value);
                        });
                      },
                      noError: noHomeAddressError,
                      errorText: 'Home address cannot be empty',
                      errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                      textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  ),
                  SizeConfig.mediumVerticalBox,
                  Row(
                      children:<Widget>[
                        Text('Children Information',style:smallTextStyle(color: ThemeColor.themeBlueColor))]),
                  SizeConfig.smallVerticalBox,
                  KiTextField.borderlessTextFormField(
                      controller: childrenNoController,
                      textInputType: TextInputType.number,
                      titleText: 'Number of Children',
                      hintText: 'Enter number of your children',
                      onSaved: (value){
                        setState(() {
                          noChildrenNoError = Validators.numberValidator(value);
                        });
                      },
                      noError: noChildrenNoError,
                      errorText: 'Number of children cannot be empty',
                      errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                      textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  ),
                  ],
              ),
            ),
            SizeConfig.extraLargeVerticalBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                KiButton.rectButton(
                    color: ThemeColor.themeBlueColor,
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical, horizontal: SizeConfig.medium),
                    child: Text('Next', style: smallerTextStyle(color: ThemeColor.whiteColor)),
                    onPressed: () async {
                      _formKey.currentState.save();
                      if(noChildrenNoError&&noFirstNameError&&noLastNameError&&noContactNoError&&noHomeAddressError){
                        try {
                          await guardian.doc(widget.uid).set({
                            'last name': lastNameController.text.toString(),
                            'first name': firstNameController.text.toString(),
                            'contact no': contactNoController.text.toString(),
                            'home address': homeAddressController.text.toString(),
                            'no of children': childrenNoController.text.toString(),
                            'chat with':null
                          });
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor: ThemeColor.blueGreyColor
                                .withOpacity(0.8),
                            content: Text(
                              'Your information is updated successfully',
                              style: smallTextStyle(
                                  color: ThemeColor.whiteColor),),
                          ));
                          if(widget.showLogout){
                            Navigator.push(context, MaterialPageRoute(builder:(context)=>
                                GuardianFillChildrenInfoPage(
                                  logoutCallback: widget.logoutCallback,
                                  noOfChildren: childrenNoController.text.toString(),
                                  uid: widget.uid,
                                  showLogout: widget.showLogout,
                                  newGuardianCallback: widget.newGuardianCallback,
                                ) ));
                          }
                        }
                        catch(e) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor: ThemeColor.blueGreyColor
                                .withOpacity(0.8),
                            content: Text(
                              'System error. Please check your internet connection.',
                              style: smallTextStyle(
                                  color: ThemeColor.whiteColor),),
                          ));
                        }
                      }
                    }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
