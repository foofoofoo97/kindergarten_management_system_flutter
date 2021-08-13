import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/Kindergarten.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class EmployeeFillInfoPage extends StatefulWidget {
  bool showLogout;
  String uid;
  VoidCallback logoutCallback;
  VoidCallback newEmployeeCallback;
  EmployeeFillInfoPage({this.uid, this.showLogout = true, this.logoutCallback,this.newEmployeeCallback});

  @override
  _EmployeeFillInfoPageState createState() => _EmployeeFillInfoPageState();
}

class _EmployeeFillInfoPageState extends State<EmployeeFillInfoPage> {
  //General Information
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController contactNoController = new TextEditingController();
  TextEditingController homeAddressController = new TextEditingController();

  //Working Information
  Kindergarten selectedKindergarten;
  TextEditingController jobTitleController = new TextEditingController();

  bool isLoading;

  List<String> pendingEmployeeUID = new List.from([]);

  List<Kindergarten> kindergartenList;

  bool noFirstNameError;
  bool noLastNameError;
  bool noContactNoError;
  bool noHomeAddressError;
  bool noJobTitleError;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference employee =
      FirebaseFirestore.instance.collection('employee');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noFirstNameError = true;
    noLastNameError = true;
    noContactNoError = true;
    noHomeAddressError = true;
    noJobTitleError = true;
    isLoading = true;
    init();
  }

  Future<void> init() async {
    kindergartenList = new List.from([]);
    QuerySnapshot querySnapshot = await kindergarten.get();
    querySnapshot.docs.forEach((doc) {
      kindergartenList.add(new Kindergarten(
          name: doc.data()['name'], address: doc.data()['address']));
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
          color: ThemeColor.whiteColor,
          child: Center(
              child: SizedBox(
                height: SizeConfig.safeBlockVertical * 5,
                width: SizeConfig.safeBlockVertical * 5,
                child: CircularProgressIndicator(
                  backgroundColor: ThemeColor.whiteColor,
                ),
              ),
            ),
        )
        : KiCenterPage(
            scaffoldKey: _scaffoldKey,
            appBarType: widget.showLogout ? null : AppBarType.backButton,
            color: ThemeColor.whiteColor,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.small),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizeConfig.extraSmallVerticalBox,
                  widget.showLogout
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            KiButton.smallButton(
                                child: Text(
                                  'Sign Out',
                                  style: smallerTextStyle(
                                      color: ThemeColor.redColor),
                                ),
                                onPressed: () {
                                  widget.logoutCallback();
                                })
                          ],
                        )
                      : SizeConfig.extraSmallVerticalBox,
                  SizeConfig.extraLargeVerticalBox,
                  Text('New Employee',style: largeTextStyle(color: ThemeColor.themeBlueColor),),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.small,
                        horizontal: SizeConfig.ultraSmall),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizeConfig.ultraSmallVerticalBox,
                          Text('Please fill in below information first',
                              style: smallererTextStyle(color: ThemeColor.blueGreyColor)),
                          SizeConfig.smallVerticalBox,
                          Text('Personal Information',
                              style: smallerTextStyle(
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
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
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
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
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
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
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
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
                          SizeConfig.mediumVerticalBox,
                          Text('Working Information',
                              style: smallerTextStyle(
                                  color: ThemeColor.themeBlueColor)),
                          SizeConfig.smallVerticalBox,
                          Container(
                            padding: EdgeInsets.all(SizeConfig.extraSmall),
                            color: ThemeColor.blueGreyColor.withOpacity(0.16),
                            child: DropdownButton<Kindergarten>(
                              isExpanded: true,
                              underline: Container(),
                              hint: Text(
                                  "Select kindergarten which you working in"),
                              style: smallerTextStyle(color: ThemeColor.blackColor),
                              value: selectedKindergarten,
                              onChanged: (Kindergarten value) {
                                setState(() {
                                  selectedKindergarten = value;
                                });
                              },
                             itemHeight: selectedKindergarten==null?null:SizeConfig.safeBlockVertical*7,
                              items: kindergartenList.map((Kindergarten school) {
                                return DropdownMenuItem<Kindergarten>(
                                  value: school,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(school.name,
                                          style: smallerTextStyle(
                                              color: ThemeColor.blackColor)),
                                      Text(school.address,
                                          style: smallerTextStyle(
                                              color: ThemeColor.blueGreyColor)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          KiTextField.borderlessTextFormField(
                              controller: jobTitleController,
                              titleText: 'Job Title',
                              hintText: 'Enter your job title',
                              onSaved: (value) {
                                setState(() {
                                  noJobTitleError =
                                      Validators.compulsoryValidator(value);
                                });
                              },
                              noError: noJobTitleError,
                              errorText: 'Job title cannot be empty',
                              errorStyle: extraSmallTextStyle(
                                  color: ThemeColor.blueGreyColor),
                            labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                            textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          )                     ,
                        SizeConfig.smallVerticalBox],
                      ),
                    ),
                  ),
                  SizeConfig.largeVerticalBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      KiButton.rectButton(
                          color: ThemeColor.themeBlueColor,
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeVertical,
                              horizontal: SizeConfig.medium),
                          child: Text('Done',
                              style: smallerTextStyle(
                                  color: ThemeColor.whiteColor)),
                          onPressed: () async {
                            _formKey.currentState.save();
                            if (selectedKindergarten != null &&
                                noFirstNameError &&
                                noLastNameError &&
                                noJobTitleError &&
                                noContactNoError &&
                                noHomeAddressError) {
                              await updateDatabase();
                            }
                          }),
                    ],
                  )
                ],
              ),
            ),
          );
  }


  Future<void> updateDatabase() async {

    pendingEmployeeUID = new List.from([]);

    try {
      await employee.doc(widget.uid).set({
        'last name': lastNameController.text.toString(),
        'first name': firstNameController.text.toString(),
        'contact no': contactNoController.text.toString(),
        'kindergarten': selectedKindergarten.name,
        'job title': jobTitleController.text.toString(),
        'home address': homeAddressController.text.toString(),
        'chat with':null,
        'status':0
      });

      DocumentSnapshot snapshot =
          await kindergarten.doc(selectedKindergarten.name).get();
      pendingEmployeeUID = List.from(snapshot.data()['pending employee uid']?? new List.from([]));
      pendingEmployeeUID.add(widget.uid);

      await kindergarten.doc(selectedKindergarten.name).set({
        'pending employee uid': pendingEmployeeUID
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });


      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.blueGreyColor.withOpacity(0.8),
        content: Text(
          'Your information is updated successfully',
          style: smallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
      if (widget.showLogout) {
        widget.newEmployeeCallback();
      }
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.blueGreyColor.withOpacity(0.8),
        content: Text(
          'Database Error. Please check your internet connection.',
          style: smallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }
}
