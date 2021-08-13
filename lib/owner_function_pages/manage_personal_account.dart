import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ManageOwnerPersonalAccount extends StatefulWidget {
  @override
  _ManageOwnerPersonalAccountState createState() => _ManageOwnerPersonalAccountState();
}

class _ManageOwnerPersonalAccountState extends State<ManageOwnerPersonalAccount> {

  //General Information
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController= new TextEditingController();
  TextEditingController contactNoController= new TextEditingController();

  //Kindergarten Information
  TextEditingController kindergartenNameController= new TextEditingController();
  TextEditingController kindergartenAddressController= new TextEditingController();
  TextEditingController kindergartenContactNoController= new TextEditingController();

  bool noFirstNameError;
  bool noLastNameError;
  bool noContactNoError;
  bool noKindergartenNameError;
  bool noKindergartenAddressError;
  bool noKindergartenContactNoError;

  bool isLoading;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  CollectionReference owner = FirebaseFirestore.instance.collection('owner');
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  OwnerProfile ownerProfile = new OwnerProfile();

  @override
  void initState() {
    // TODO: implement initState
    isLoading=false;
    noFirstNameError =true;
    noLastNameError = true;
    noContactNoError =true;
    noKindergartenAddressError = true;
    noKindergartenContactNoError = true;
    noKindergartenNameError =true;

    firstNameController.text = ownerProfile.firstName;
    lastNameController.text = ownerProfile.lastName;
    contactNoController.text = ownerProfile.contactNo;
    kindergartenNameController.text = ownerProfile.kindergarten;
    kindergartenAddressController.text = kindergartenProfile.address;
    kindergartenContactNoController.text = kindergartenProfile.contactNo;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiPage(
          scaffoldKey: _scaffoldKey,
          appBarType: AppBarType.backButton,
          color: ThemeColor.whiteColor,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset('assets/user.png',height: SizeConfig.safeBlockVertical*6,),
                ),
                SizeConfig.extraSmallVerticalBox,
                Center(
                  child:Text('Personal Owner Profile',style:smalllTextStyle(color: ThemeColor.themeBlueColor),),
                ),
                SizeConfig.ultraSmallVerticalBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Text('Please update profile with your latest information.',
                    style: smallererTextStyle(color: ThemeColor.blueGreyColor),textAlign: TextAlign.center,),
                ],),
                SizeConfig.mediumVerticalBox,
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.medium,
                      horizontal: SizeConfig.extraSmall),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: ThemeColor.lightestBlueGreyColor, width: 1.0)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                            enabled:false,
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
                        child: Text('Update', style: smallerTextStyle(color: ThemeColor.whiteColor)),
                        onPressed: () async {
                          setState(() {
                            isLoading=true;
                          });
                          _formKey.currentState.save();
                          if(noFirstNameError&&noLastNameError&&noContactNoError&&noKindergartenAddressError&&noKindergartenContactNoError&&noKindergartenNameError){
                            try {
                              owner.doc(ownerProfile.uid).update({
                                'first name' :firstNameController.text.toString(),
                                'last name': lastNameController.text.toString(),
                                'contact no': contactNoController.text.toString(),
                              });

                              //KIUPDATE : MULTIPLE OWNERS MODE
                              kindergarten.doc(kindergartenNameController.text.toString()).update({
                                'address': kindergartenAddressController.text.toString(),
                                'contact no': kindergartenContactNoController.text.toString(),
                              });

                              setState(() {
                                ownerProfile.firstName = firstNameController.text.toString();
                                ownerProfile.lastName = lastNameController.text.toString();
                                ownerProfile.contactNo = contactNoController.text.toString();
                                kindergartenProfile.address = kindergartenAddressController.text.toString();
                                kindergartenProfile.contactNo = kindergartenContactNoController.text.toString();
                              });


                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                backgroundColor: ThemeColor.themeBlueColor
                                    .withOpacity(0.8),
                                content: Text(
                                  'Your information is updated successfully',
                                  style: smallerTextStyle(
                                      color: ThemeColor.whiteColor),),
                              ));
                              setState(() {
                                isLoading=false;
                              });
                            }
                            catch(e) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                backgroundColor: ThemeColor.themeBlueColor
                                    .withOpacity(0.8),
                                content: Text(
                                  'System error. Please check your internet connection.',
                                  style: smallerTextStyle(
                                      color: ThemeColor.whiteColor),),
                              ));

                              setState(() {
                                isLoading=false;
                              });
                            }
                          }
                        }
                    ),
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
