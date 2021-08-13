import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class OwnerFillInfoPage extends StatefulWidget {
  bool showLogout;
  VoidCallback logoutCallback;
  VoidCallback newOwnerCallback;
  String uid;
  OwnerFillInfoPage({this.uid,this.newOwnerCallback,this.showLogout=true,this.logoutCallback});

  @override
  _OwnerFillInfoPageState createState() => _OwnerFillInfoPageState();
}

class _OwnerFillInfoPageState extends State<OwnerFillInfoPage> {

  //General Information
  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController contactNoController;

  //Kindergarten Information
  TextEditingController kindergartenNameController;
  TextEditingController kindergartenAddressController;
  TextEditingController kindergartenContactNoController;

  bool noFirstNameError;
  bool noLastNameError;
  bool noContactNoError;
  bool noKindergartenNameError;
  bool noKindergartenAddressError;
  bool noKindergartenContactNoError;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CollectionReference owner = FirebaseFirestore.instance.collection('owner');
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');


  @override
  void initState() {
    // TODO: implement initState
    noFirstNameError =true;
    noLastNameError = true;
    noContactNoError =true;
    noKindergartenAddressError = true;
    noKindergartenContactNoError = true;
    noKindergartenNameError =true;

    firstNameController = new TextEditingController();
    lastNameController = new TextEditingController();
    contactNoController = new TextEditingController();
    kindergartenAddressController = new TextEditingController();
    kindergartenContactNoController = new TextEditingController();
    kindergartenNameController = new TextEditingController();

    super.initState();
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
            SizeConfig.extraLargeVerticalBox,
             Text('New Owner',style: largeTextStyle(color: ThemeColor.themeBlueColor),),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.extraSmall,
                  horizontal: SizeConfig.ultraSmall),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizeConfig.ultraSmallVerticalBox,
                    Text('Please fill in below information first',
                        style:smallererTextStyle(color: ThemeColor.blueGreyColor)),
                    SizeConfig.smallVerticalBox,
                    Text('Personal Information',style:smallerTextStyle(color: ThemeColor.themeBlueColor)),
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
                    SizeConfig.mediumVerticalBox,
                    Text('Kindergarten Information',style:smallerTextStyle(color: ThemeColor.themeBlueColor)),
                    SizeConfig.smallVerticalBox,
                    KiTextField.borderlessTextFormField(
                        controller: kindergartenNameController,
                        titleText: 'Kindergarten Name',
                        hintText: 'Enter your kindergarten name',
                        onSaved: (value){
                          setState(() {
                            noKindergartenNameError = Validators.compulsoryValidator(value);
                          });
                        },
                        noError: noKindergartenNameError,
                        errorText: 'Kindergarten name cannot be empty',
                        errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                        labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                        textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    KiTextField.borderlessTextFormField(
                        controller: kindergartenContactNoController,
                        textInputType: TextInputType.number,
                        titleText: 'Kindergarten Contact No',
                        hintText: 'Enter your kindergarten contact no.',
                        onSaved: (value){
                          setState(() {
                            noKindergartenContactNoError = Validators.compulsoryValidator(value);
                          });
                        },
                        noError: noKindergartenContactNoError,
                        errorText: 'Kindergarten contact no. cannot be empty',
                        errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                        labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                        textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                    ),
                    SizeConfig.extraSmallVerticalBox,
                    KiTextField.borderlessTextFormField(
                        controller: kindergartenAddressController,
                        titleText: 'Kindergarten Address',
                        hintText: 'Enter your kindergarten address',
                        onSaved: (value){
                          setState(() {
                            noKindergartenAddressError = Validators.compulsoryValidator(value);
                          });
                        },
                        noError: noKindergartenAddressError,
                        errorText: 'Kindergarten address cannot be empty',
                        errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                        labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                        textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                    ),
                    SizeConfig.smallVerticalBox
                  ],
                ),
              ),
            ),
            SizeConfig.mediumVerticalBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                KiButton.rectButton(
                    color: ThemeColor.themeBlueColor,
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical, horizontal: SizeConfig.medium),
                    child: Text('Done', style: smallerTextStyle(color: ThemeColor.whiteColor)),
                    onPressed: () async {
                      _formKey.currentState.save();
                      if(noFirstNameError&&noLastNameError&&noContactNoError&&noKindergartenAddressError&&noKindergartenContactNoError&&noKindergartenNameError){
                        try {
                          DocumentSnapshot documentSnapshot = await kindergarten.doc(kindergartenNameController.text.toString()).get();
                          List<String> ownerUID = new List.from([]);
                          if(documentSnapshot.exists){
                            ownerUID = List.from(documentSnapshot.data()['owner uid']);
                          }
                          ownerUID.add(widget.uid);

                          owner.doc(widget.uid).set({
                            'first name' :firstNameController.text.toString(),
                            'last name': lastNameController.text.toString(),
                            'contact no': contactNoController.text.toString(),
                            'kindergarten name': kindergartenNameController.text.toString(),
                            'chat with': null,
                          });

                          //KIUPDATE : MULTIPLE OWNERS MODE
                          kindergarten.doc(kindergartenNameController.text.toString()).set({
                            'name': kindergartenNameController.text.toString(),
                            'address': kindergartenAddressController.text.toString(),
                            'contact no': kindergartenContactNoController.text.toString(),
                            'student courses': new Map(),
                            'employee uid': new List.from([]),
                            'employee first name': new List.from([]),
                            'employee last name': new List.from([]),
                            'employee job title': new List.from([]),
                            'student uid': new List.from([]),
                            'student first name': new List.from([]),
                            'student last name': new List.from([]),
                            'student age': new List.from([]),
                            'owner uid':ownerUID,
                            'start work hrs': null,
                            'start work min': null,
                            'start study hrs':null,
                            'start study min': null,
                            'fees type': new Map(),
                            'employee absent': 0,
                            'employee present':0,
                            'employee late':0,
                            'employee leave':0,
                            'student absent': 0,
                            'student present':0,
                            'student late':0,
                            'student leave':0,
                            'pending employee uid': new List.from([]),
                            'pending student uid': new List.from([])
                          });

                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor: ThemeColor.blueGreyColor
                                .withOpacity(0.8),
                            content: Text(
                              'Your information is updated successfully',
                              style: smallTextStyle(
                                  color: ThemeColor.whiteColor),),
                          ));
                          if(widget.showLogout)
                            widget.newOwnerCallback();
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
