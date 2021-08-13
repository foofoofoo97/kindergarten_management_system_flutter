import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/models/Kindergarten.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class GuardianManageChildrenAccountsPage extends StatefulWidget {
  @override
  _GuardianManageChildrenAccountsPageState createState() => _GuardianManageChildrenAccountsPageState();
}

class _GuardianManageChildrenAccountsPageState extends State<GuardianManageChildrenAccountsPage> {

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');
  CollectionReference student = FirebaseFirestore.instance.collection('student');

  List<TextEditingController> firstNameController = new List.from([]);
  List<TextEditingController> lastNameController = new List.from([]);
  List<TextEditingController> ageController = new List.from([]);
  List<Kindergarten> selectedKindergarten = new List.from([]);

  Map<String,Kindergarten> kindergartenMap = new Map();

  // List<bool> noFirstNameError = new List();
  // List<bool> noLastNameError = new List();
  // List<bool> noAgeError = new List();
  // List<bool> noKindergartenError = new List();

  int noOfChildren;
  List<Widget> widgetList = new List.from([]);
  bool isLoading;
  bool isReading;
  List<Kindergarten> kindergartenList = new List.from([]);
  GuardianProfile guardianProfile = new GuardianProfile();

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    isReading=true;
    noOfChildren = int.parse(guardianProfile.noOfChildren);

    init();
    super.initState();
  }

  Future<void> init()async{
    kindergartenList = new List.from([]);
    QuerySnapshot querySnapshot = await kindergarten.get();
    querySnapshot.docs.forEach((doc) {
      Kindergarten kindergartenA = new Kindergarten(
          name: doc.data()['name'], address: doc.data()['address']);
      kindergartenMap.putIfAbsent(doc.data()['name'], () =>kindergartenA);
      kindergartenList.add(kindergartenA);
    });

    for (int x = 0; x < noOfChildren; x++) {
      firstNameController.add(new TextEditingController(text: guardianProfile.childrenFirstName[x]));
      lastNameController.add(new TextEditingController(text: guardianProfile.childrenLastName[x]));
      ageController.add(new TextEditingController(text: guardianProfile.childrenAge[x]));
      selectedKindergarten.add(kindergartenMap[guardianProfile.childrenKindergarten[x]]);

      // noFirstNameError.add(true);
      // noLastNameError.add(true);
      // noAgeError.add(true);
      // noKindergartenError.add(true);
    }

    setState(() {
      isLoading =false;
      isReading=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return isReading
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
    ):Stack(
      children: <Widget>[
        KiPage(
          color: ThemeColor.whiteColor,
          scaffoldKey: _scaffoldKey,
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
              'Children Profiles',
              style: smalllTextStyle(color: ThemeColor.themeBlueColor),
            ),
          ),
          SizeConfig.ultraSmallVerticalBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Please contact admin to update children information',
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
              child: Container(
                height: SizeConfig.safeBlockVertical * 78,
                child: ListView.builder(
                    itemCount: noOfChildren,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemBuilder: (context, x) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Child ${x + 1}',
                            style: smallTextStyle(
                                color: ThemeColor.blueGreyColor),
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          KiTextField.borderlessTextFormField(
                              enabled: false,
                              noError: true,
                              controller: firstNameController[x],
                              titleText: 'First Name',
                              hintText: 'Enter child\'s first name',
                              // onSaved: (value) {
                              //   setState(() {
                              //     noFirstNameError[x] =
                              //         Validators.compulsoryValidator(
                              //             value);
                              //   });
                              // },
                              // noError: noFirstNameError[x],
                              errorText:
                              'Child\'s first name cannot be empty',
                              errorStyle: extraSmallTextStyle(
                                  color: ThemeColor.blueGreyColor),
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          KiTextField.borderlessTextFormField(
                              enabled: false,
                              noError: true,
                              controller: lastNameController[x],
                              titleText: 'Last Name',
                              hintText: 'Enter child\'s last name',
                              // onSaved: (value) {
                              //   setState(() {
                              //     noLastNameError[x] =
                              //         Validators.compulsoryValidator(
                              //             value);
                              //   });
                              // },
                              // noError: noLastNameError[x],
                              errorText:
                              'Child\'s last name cannot be empty',
                              errorStyle: extraSmallTextStyle(
                                  color: ThemeColor.blueGreyColor),
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          KiTextField.borderlessTextFormField(
                              controller: ageController[x],
                              enabled: false,
                              noError: true,
                              textInputType: TextInputType.number,
                              titleText: 'Age',
                              hintText: 'Enter child\'s age',
                              // onSaved: (value) {
                              //   setState(() {
                              //     noAgeError[x] =
                              //         Validators.compulsoryValidator(
                              //             value);
                              //   });
                              // },
                              // noError: noAgeError[x],
                              errorText: 'child\'s age cannot be empty',
                              errorStyle: extraSmallTextStyle(
                                  color: ThemeColor.blueGreyColor),
                              labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                              textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          Container(
                            padding:
                            EdgeInsets.all(SizeConfig.extraSmall),
                            color: ThemeColor.blueGreyColor
                                .withOpacity(0.16),
                            child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(selectedKindergarten[x].name,
                                          style: smallerTextStyle(
                                              color:
                                              ThemeColor.blackColor)),
                                      Text(selectedKindergarten[x].address,
                                          style: smallerTextStyle(
                                              color: ThemeColor
                                                  .blueGreyColor)),
                                    ],
                                  ),
                          ),
                          SizeConfig.mediumVerticalBox,
                        ],
                      );
                    }),
              ),
            )),
                // SizeConfig.ultraSmallVerticalBox,
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     KiButton.rectButton(
                //         color: ThemeColor.themeBlueColor,
                //         padding: EdgeInsets.symmetric(
                //             vertical: SizeConfig.blockSizeVertical,
                //             horizontal: SizeConfig.medium),
                //         child: Text('Done',
                //             style:
                //             smallTextStyle(color: ThemeColor.whiteColor)),
                //         onPressed: () async {
                //           setState(() {
                //             isLoading = true;
                //           });
                          // _formKey.currentState.save();
                          // if (noAgeError[0] &&
                          //     noFirstNameError[0] &&
                          //     noLastNameError[0] &&
                          //     selectedKindergarten[0] != null) {
                          //   await updateDatabase();
                          // }
                          // setState(() {
                          //   isLoading = false;
                          // });
                        // }),
                  // ],
                // )
              ])
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

  // Future<void> updateDatabase()async{
  //   try {
  //     List<String> firstName = new List();
  //     List<String> lastName = new List();
  //     List<String> age = new List();
  //     List<int> status =new List();
  //     List<String> uid = new List();
  //     List<String> kindergartenList = new List();
  //
  //     for (int x = 0; x < noOfChildren; x++) {
  //       firstName.add(
  //           firstNameController[x].text.toString());
  //       lastName
  //           .add(lastNameController[x].text.toString());
  //       age.add(ageController[x].text.toString());
  //       kindergartenList
  //           .add(selectedKindergarten[x].name);
  //       uid.add('${guardianProfile.uid}+$x');
  //       status.add(0);
  //
  //       await student.doc('${guardianProfile.uid}+$x').set({
  //         'first name': firstName[x],
  //         'last name': lastName[x],
  //         'age': age[x],
  //         'kindergarten': kindergartenList[x],
  //         'guardian': guardianProfile.uid,
  //         'latest grade':null
  //       });
  //
  //       List<String> pendingStudentUID = new List();
  //
  //       DocumentSnapshot snapshot = await kindergarten.doc(kindergartenList[x]).get();
  //       pendingStudentUID =List.from(snapshot.data()['pending student uid']??new List());
  //       pendingStudentUID.add('${guardianProfile.uid}+$x');
  //       await kindergarten
  //           .doc(kindergartenList[x])
  //           .set({
  //         'pending student uid':pendingStudentUID
  //       }, SetOptions(merge: true)).then((_) {
  //         print("success!");
  //       });
  //     }
  //
  //     await guardian.doc(guardianProfile.uid).set({
  //       'children first name': firstName,
  //       'children last name': lastName,
  //       'children age': age,
  //       'children uid':uid,
  //       'children status':status,
  //       'children kindergarten': kindergartenList,
  //     }, SetOptions(merge: true)).then((_) {
  //       print("success!");
  //     });
  //
  //
  //     _scaffoldKey.currentState.showSnackBar(SnackBar(
  //       backgroundColor:
  //       ThemeColor.blueGreyColor.withOpacity(0.8),
  //       content: Text(
  //         'Your information is updated successfully',
  //         style: smallTextStyle(
  //             color: ThemeColor.whiteColor),
  //       ),
  //     ));
  //
  //   } catch (e) {
  //     print(e);
  //     _scaffoldKey.currentState.showSnackBar(SnackBar(
  //       backgroundColor:
  //       ThemeColor.blueGreyColor.withOpacity(0.8),
  //       content: Text(
  //         'System error. Please check your internet connection.',
  //         style: smallTextStyle(
  //             color: ThemeColor.whiteColor),
  //       ),
  //     ));
  //   }
  // }
}
