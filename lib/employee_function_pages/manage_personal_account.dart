import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/Kindergarten.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ManageEmployeePersonalAccount extends StatefulWidget {
  @override
  _ManageEmployeePersonalAccountState createState() => _ManageEmployeePersonalAccountState();
}

class _ManageEmployeePersonalAccountState extends State<ManageEmployeePersonalAccount> {
  
  //General Information
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController= new TextEditingController();
  TextEditingController contactNoController= new TextEditingController();
  TextEditingController homeAddressController= new TextEditingController();

  //Working Information
  Kindergarten selectedKindergarten;
  TextEditingController jobTitleController = new TextEditingController();

  bool isLoading;
  List<Kindergarten> kindergartenList;
  List<String> employeeUidList;
  List<String> employeeFirstName;
  List<String> employeeLastName;
  List<String> jobTitleList;

  String iniKindergarten;
  String iniFirstName;
  String iniLastName;
  String iniJobTitle;
  bool noFirstNameError;
  bool noLastNameError;
  bool noContactNoError;
  bool noHomeAddressError;
  bool noJobTitleError;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference employee = FirebaseFirestore.instance.collection('employee');
  EmployeeProfile employeeProfile = new EmployeeProfile();

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

    iniKindergarten = employeeProfile.kindergarten;
    iniJobTitle =employeeProfile.jobTitle;
    iniLastName =employeeProfile.lastName;
    iniFirstName =employeeProfile.firstName;
    firstNameController.text = employeeProfile.firstName;
    lastNameController.text = employeeProfile.lastName;
    contactNoController.text = employeeProfile.contactNo;
    homeAddressController.text = employeeProfile.homeAddress;
    jobTitleController.text = employeeProfile.jobTitle;

    init();
  }

  Future<void> init() async {
    kindergartenList = new List.from([]);
    QuerySnapshot querySnapshot = await kindergarten.get();
    querySnapshot.docs.forEach((doc) {
      Kindergarten temp = new Kindergarten(
          name: doc.data()['name'], address: doc.data()['address']);
      kindergartenList.add(temp);
      if(iniKindergarten==temp.name){
        selectedKindergarten=temp;
      }
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
        : KiPage(
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
              child:Text('Personal Employee Profile',style:smalllTextStyle(color: ThemeColor.themeBlueColor),),
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
                  vertical: SizeConfig.small,
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
                        itemHeight: selectedKindergarten==null?null:SizeConfig.safeBlockVertical*7,
                        isExpanded: true,
                        underline: Container(),
                        hint: Text(
                            "Select kindergarten which you working in"),
                        style: smallerTextStyle(color: ThemeColor.blackColor),
                        value: selectedKindergarten,
                        onChanged: (Kindergarten value) {
                          // setState(() {
                          //   selectedKindergarten = value;
                          // });
                        },
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
                    )          ,
                  SizeConfig.smallVerticalBox],
                ),
              ),
            ),
            SizeConfig.smallVerticalBox,
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
                      if (selectedKindergarten != null &&
                          noFirstNameError &&
                          noLastNameError &&
                          noJobTitleError &&
                          noContactNoError &&
                          noHomeAddressError) {
                        await updateEmployeeDatabase();
                        await updateKindergartenDatabase();
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateEmployeeDatabase() async {
    try {
      await employee.doc(employeeProfile.uid).update({
        'last name': lastNameController.text.toString(),
        'first name': firstNameController.text.toString(),
        'contact no': contactNoController.text.toString(),
        'kindergarten': selectedKindergarten.name,
        'job title': jobTitleController.text.toString(),
        'home address': homeAddressController.text.toString(),
      });

      employeeProfile.lastName = lastNameController.text.toString();
      employeeProfile.firstName = firstNameController.text.toString();
      employeeProfile.contactNo = contactNoController.text.toString();
      employeeProfile.kindergarten = selectedKindergarten.name;
      employeeProfile.jobTitle = jobTitleController.text.toString();
      employeeProfile.homeAddress = homeAddressController.text.toString();

    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Employee Database Error. Please check your internet connection.',
          style: smallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }

  Future<void> updateKindergartenDatabase() async {

    employeeUidList = new List.from([]);
    employeeFirstName = new List.from([]);
    employeeLastName = new List.from([]);
    jobTitleList = new List.from([]);
    
    List<String> tempUid = new List.from([]);
    List<String> tempFName = new List.from([]);
    List<String> tempLName = new List.from([]);
    List<String> jobTitles = new List.from([]);

    try {
      if(iniKindergarten!=selectedKindergarten.name){
        DocumentSnapshot snapshot = await kindergarten.doc(selectedKindergarten.name).get();
      if (snapshot.data().containsKey('employee uid')) {
        employeeUidList = List.from(snapshot.data()['employee uid']);
        employeeFirstName = List.from(snapshot.data()['employee first name']);
        employeeLastName = List.from(snapshot.data()['employee last name']);
        jobTitleList = List.from(snapshot.data()['employee job title']);
      }

        employeeUidList.add(employeeProfile.uid);
        employeeFirstName.add(firstNameController.text.toString());
        employeeLastName.add(lastNameController.text.toString());
        jobTitleList.add(jobTitleController.text.toString());

        await kindergarten.doc(selectedKindergarten.name).set({
          'employee uid': employeeUidList,
          'employee first name': employeeFirstName,
          'employee last name': employeeLastName,
          'employee job title': jobTitleList
        }, SetOptions(merge: true)).then((_) {
          print("success!");
        });
        
        employee.doc(employeeProfile.uid).collection('attendance').get().then((value){ for(DocumentSnapshot doc in value.docs){
          doc.reference.delete();
        }});

        DocumentSnapshot snapshot2 = await kindergarten.doc(iniKindergarten).get();
        if (snapshot.data().containsKey('employee uid')) {
          tempUid = List.from(snapshot.data()['employee uid']);
          tempFName = List.from(snapshot.data()['employee first name']);
          tempLName = List.from(snapshot.data()['employee last name']);
          jobTitles = List.from(snapshot.data()['employee job title']);

          int index =tempUid.indexOf(employeeProfile.uid);
          tempUid.removeAt(index);
          tempFName.removeAt(index);
          tempLName.removeAt(index);
          jobTitles.removeAt(index);
        }

        await kindergarten.doc(selectedKindergarten.name).set({
          'employee uid': employeeUidList,
          'employee first name': employeeFirstName,
          'employee last name': employeeLastName,
          'employee job title': jobTitleList
        }, SetOptions(merge: true)).then((_) {
          print("success!");
        });
      }
      else if(iniFirstName!=firstNameController.text.toString()||iniLastName!=lastNameController.text.toString()||iniJobTitle!=jobTitleController.text.toString()){
        DocumentSnapshot snapshot = await kindergarten.doc(selectedKindergarten.name).get();
        if (snapshot.data().containsKey('employee uid')) {
          employeeUidList = List.from(snapshot.data()['employee uid']);
          employeeFirstName = List.from(snapshot.data()['employee first name']);
          employeeLastName = List.from(snapshot.data()['employee last name']);
          jobTitleList = List.from(snapshot.data()['employee job title']);

          int index= employeeUidList.indexOf(employeeProfile.uid);
          employeeFirstName[index]=firstNameController.text.toString();
          employeeLastName[index]=lastNameController.text.toString();
          jobTitleList[index]=jobTitleController.text.toString();
        }
        await kindergarten.doc(selectedKindergarten.name).set({
          'employee uid': employeeUidList,
          'employee first name': employeeFirstName,
          'employee last name': employeeLastName,
          'employee job title': jobTitleList
        }, SetOptions(merge: true)).then((_) {
          print("success!");
        });

      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Your information is updated successfully',
          style: smallerTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Kindergarten Database Error. Please check your internet connection.',
          style: smallerTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }
  
}
