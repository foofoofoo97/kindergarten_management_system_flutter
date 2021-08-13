import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class GuardianManagePersonalAccount extends StatefulWidget {
  @override
  _GuardianManagePersonalAccountState createState() =>
      _GuardianManagePersonalAccountState();
}

class _GuardianManagePersonalAccountState
    extends State<GuardianManagePersonalAccount> {

  //General Information
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController contactNoController = new TextEditingController();
  TextEditingController homeAddressController = new TextEditingController();
  TextEditingController childrenNoController = new TextEditingController();

  bool noFirstNameError;
  bool noLastNameError;
  bool noContactNoError;
  bool noHomeAddressError;

  bool isLoading;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference guardian =
      FirebaseFirestore.instance.collection('guardian');
  GuardianProfile guardianProfile = new GuardianProfile();

  @override
  void initState() {
    // TODO: implement initState
    isLoading=false;
    noFirstNameError = true;
    noLastNameError = true;
    noContactNoError = true;
    noHomeAddressError = true;

    firstNameController.text = guardianProfile.firstName;
    lastNameController.text = guardianProfile.lastName;
    contactNoController.text = guardianProfile.contactNo;
    homeAddressController.text = guardianProfile.homeAddress;
    childrenNoController.text =guardianProfile.noOfChildren;

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
                  padding: EdgeInsets.all(SizeConfig.small),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          'assets/user.png',
                          height: SizeConfig.safeBlockVertical * 6,
                        ),
                      ),
                      SizeConfig.extraSmallVerticalBox,
                      Center(
                        child: Text(
                          'Personal Guardian Profile',
                          style: smalllTextStyle(color: ThemeColor.themeBlueColor),
                        ),
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Please update profile with your latest information.',
                            style:
                                smallererTextStyle(color: ThemeColor.blueGreyColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizeConfig.mediumVerticalBox,
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.small,
                            horizontal: SizeConfig.extraSmall),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: ThemeColor.lightestBlueGreyColor,
                                width: 1.0)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Personal Information',
                                  style: smallTextStyle(
                                      color: ThemeColor.themeBlueColor)),
                              SizeConfig.smallVerticalBox,
                              KiTextField.borderlessTextFormField(
                                  controller: firstNameController,
                                  titleText: 'First Name',
                                  hintText: 'Enter your first name',
                                  onSaved: (value) {
                                    setState(() {
                                      noFirstNameError =
                                          Validators.compulsoryValidator(value);
                                    });
                                  },
                                  noError: noFirstNameError,
                                  errorText: 'First name cannot be empty',
                                  errorStyle: extraSmallTextStyle(
                                      color: ThemeColor.blueGreyColor),
                                  labelStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor),
                                  textStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor)),
                              SizeConfig.extraSmallVerticalBox,
                              KiTextField.borderlessTextFormField(
                                  controller: lastNameController,
                                  titleText: 'Last Name',
                                  hintText: 'Enter your last name',
                                  onSaved: (value) {
                                    setState(() {
                                      noLastNameError =
                                          Validators.compulsoryValidator(value);
                                    });
                                  },
                                  noError: noLastNameError,
                                  errorText: 'Last name cannot be empty',
                                  errorStyle: extraSmallTextStyle(
                                      color: ThemeColor.blueGreyColor),
                                  labelStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor),
                                  textStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor)),
                              SizeConfig.extraSmallVerticalBox,
                              KiTextField.borderlessTextFormField(
                                  controller: contactNoController,
                                  textInputType: TextInputType.number,
                                  titleText: 'Contact No',
                                  hintText: 'Enter your contact no.',
                                  onSaved: (value) {
                                    setState(() {
                                      noContactNoError =
                                          Validators.compulsoryValidator(value);
                                    });
                                  },
                                  noError: noContactNoError,
                                  errorText: 'Contact no. cannot be empty',
                                  errorStyle: extraSmallTextStyle(
                                      color: ThemeColor.blueGreyColor),
                                  labelStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor),
                                  textStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor)),
                              SizeConfig.extraSmallVerticalBox,
                              KiTextField.borderlessTextFormField(
                                  controller: homeAddressController,
                                  titleText: 'Home Address',
                                  hintText: 'Enter your home address',
                                  onSaved: (value) {
                                    setState(() {
                                      noHomeAddressError =
                                          Validators.compulsoryValidator(value);
                                    });
                                  },
                                  noError: noHomeAddressError,
                                  errorText: 'Home address cannot be empty',
                                  errorStyle: extraSmallTextStyle(
                                      color: ThemeColor.blueGreyColor),
                                  labelStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor),
                                  textStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor)),
                              SizeConfig.mediumVerticalBox,
                              Row(children: <Widget>[
                                Text('Children Information',
                                    style: smallTextStyle(
                                        color: ThemeColor.themeBlueColor))
                              ]),
                              SizeConfig.smallVerticalBox,
                              KiTextField.borderlessTextFormField(
                                  enabled: false,
                                  noError: true,
                                  controller: childrenNoController,
                                  textInputType: TextInputType.number,
                                  titleText: 'Number of Children',
                                  hintText: 'Enter number of your children',
                                  errorText: 'Number of children cannot be empty',
                                  errorStyle: extraSmallTextStyle(
                                      color: ThemeColor.blueGreyColor),
                                  labelStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor),
                                  textStyle: smallerTextStyle(
                                      color: ThemeColor.blackColor)),
                            ],
                          ),
                        ),
                      ),
                      SizeConfig.extraLargeVerticalBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          KiButton.rectButton(
                              color: ThemeColor.themeBlueColor,
                              padding: EdgeInsets.symmetric(
                                  vertical: SizeConfig.blockSizeVertical,
                                  horizontal: SizeConfig.medium),
                              child: Text('Update',
                                  style: smallerTextStyle(
                                      color: ThemeColor.whiteColor)),
                              onPressed: () async {
                                _formKey.currentState.save();
                                if (noFirstNameError &&
                                    noLastNameError &&
                                    noContactNoError &&
                                    noHomeAddressError) {
                                  setState(() {
                                    isLoading=true;
                                  });
                                  try {
                                    await guardian.doc(guardianProfile.uid).update({
                                      'last name':
                                          lastNameController.text.toString(),
                                      'first name':
                                          firstNameController.text.toString(),
                                      'contact no':
                                          contactNoController.text.toString(),
                                      'home address':
                                          homeAddressController.text.toString(),
                                    });
                                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      backgroundColor:
                                          ThemeColor.themeBlueColor.withOpacity(0.8),
                                      content: Text(
                                        'Your information is updated successfully',
                                        style: smallerTextStyle(
                                            color: ThemeColor.whiteColor),
                                      ),
                                    ));
                                    setState(() {
                                      guardianProfile.firstName=firstNameController.text.toString();
                                      guardianProfile.lastName=lastNameController.text.toString();
                                      guardianProfile.homeAddress=homeAddressController.text.toString();
                                      guardianProfile.contactNo = contactNoController.text.toString();
                                    });
                                  } catch (e) {
                                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      backgroundColor:
                                          ThemeColor.themeBlueColor.withOpacity(0.8),
                                      content: Text(
                                        'System error. Please check your internet connection.',
                                        style: smallerTextStyle(
                                            color: ThemeColor.whiteColor),
                                      ),
                                    ));
                                  }
                                }
                                setState(() {
                                  isLoading=false;
                                });
                              }),
                        ],
                      )
                    ],
                  ),
                ),
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
            )
                : Container()
          ],
        );
  }
}
