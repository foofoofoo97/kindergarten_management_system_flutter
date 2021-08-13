import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/Kindergarten.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class GuardianFillChildrenInfoPage extends StatefulWidget {
  String noOfChildren;
  bool showLogout;
  VoidCallback logoutCallback;
  VoidCallback newGuardianCallback;

  String uid;
  GuardianFillChildrenInfoPage(
      {this.uid,
      this.logoutCallback,
      this.showLogout,
       this.newGuardianCallback,
      this.noOfChildren});

  @override
  _GuardianFillChildrenInfoPageState createState() =>
      _GuardianFillChildrenInfoPageState();
}

class _GuardianFillChildrenInfoPageState
    extends State<GuardianFillChildrenInfoPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');
  CollectionReference student = FirebaseFirestore.instance.collection('student');

  List<TextEditingController> firstNameController = new List.from([]);
  List<TextEditingController> lastNameController = new List.from([]);
  List<TextEditingController> ageController = new List.from([]);
  List<Kindergarten> selectedKindergarten = new List.from([]);

  List<bool> noFirstNameError = new List.from([]);
  List<bool> noLastNameError = new List.from([]);
  List<bool> noAgeError = new List.from([]);
  List<bool> noKindergartenError = new List.from([]);
  int noOfChildren;
  List<Widget> widgetList = new List.from([]);
  bool isLoading;
  List<Kindergarten> kindergartenList = new List.from([]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    noOfChildren = int.parse(widget.noOfChildren);

    for (int x = 0; x < noOfChildren; x++) {
      firstNameController.add(new TextEditingController());
      lastNameController.add(new TextEditingController());
      ageController.add(new TextEditingController());
      selectedKindergarten.add(null);

      noFirstNameError.add(true);
      noLastNameError.add(true);
      noAgeError.add(true);
      noKindergartenError.add(true);
    }
    init();
  }



  Future<void> init()async{
    kindergartenList = new List.from([]);
    QuerySnapshot querySnapshot = await kindergarten.get();
    querySnapshot.docs.forEach((doc) {
      kindergartenList.add(new Kindergarten(
          name: doc.data()['name'], address: doc.data()['address']));
    });

    setState(() {
      isLoading =false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiCenterPage(
          color: ThemeColor.whiteColor,
          scaffoldKey: _scaffoldKey,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizeConfig.mediumVerticalBox,
                widget.showLogout
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          KiButton.smallButton(
                              child: Text(
                                'Sign Out',
                                style:
                                    smallerTextStyle(color: ThemeColor.redColor),
                              ),
                              onPressed: () {
                                widget.logoutCallback();
                              })
                        ],
                      )
                    : SizeConfig.extraSmallVerticalBox,
                SizeConfig.mediumVerticalBox,
                Text('Add Children',style: largeTextStyle(color: ThemeColor.themeBlueColor),),
                SizeConfig.ultraSmallVerticalBox,
                Text('Please fill in below information first',
                    style: smallerTextStyle(color: ThemeColor.blackColor)),
                SizeConfig.smallVerticalBox,
                Form(
                    key: _formKey,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 78,
                      child: ListView.builder(
                          itemCount: noOfChildren,
                          shrinkWrap: true,
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
                                    controller: firstNameController[x],
                                    titleText: 'First Name',
                                    hintText: 'Enter child\'s first name',
                                    onSaved: (value) {
                                      setState(() {
                                        noFirstNameError[x] =
                                            Validators.compulsoryValidator(
                                                value);
                                      });
                                    },
                                    noError: noFirstNameError[x],
                                    errorText:
                                        'Child\'s first name cannot be empty',
                                    errorStyle: extraSmallTextStyle(
                                        color: ThemeColor.blueGreyColor),
                                    labelStyle: smallerTextStyle(color: ThemeColor.blackColor),
                                    textStyle: smallerTextStyle(color: ThemeColor.blackColor)
                                ),
                                SizeConfig.extraSmallVerticalBox,
                                KiTextField.borderlessTextFormField(
                                    controller: lastNameController[x],
                                    titleText: 'Last Name',
                                    hintText: 'Enter child\'s last name',
                                    onSaved: (value) {
                                      setState(() {
                                        noLastNameError[x] =
                                            Validators.compulsoryValidator(
                                                value);
                                      });
                                    },
                                    noError: noLastNameError[x],
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
                                    textInputType: TextInputType.number,
                                    titleText: 'Age',
                                    hintText: 'Enter child\'s age',
                                    onSaved: (value) {
                                      setState(() {
                                        noAgeError[x] =
                                            Validators.compulsoryValidator(
                                                value);
                                      });
                                    },
                                    noError: noAgeError[x],
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
                                  child: DropdownButton<Kindergarten>(
                                    isExpanded: true,
                                    hint: Text(
                                        "Select kindergarten which you working in"),
                                    style: smallerTextStyle(
                                        color: ThemeColor.blackColor),
                                    itemHeight: selectedKindergarten[x]==null?null:SizeConfig.safeBlockVertical*7,
                                    underline: Container(),
                                    value: selectedKindergarten[x],
                                    onChanged: (Kindergarten value) {
                                      setState(() {
                                        selectedKindergarten[x] = value;
                                      });
                                    },
                                    items: kindergartenList
                                        .map((Kindergarten school) {
                                      return DropdownMenuItem<Kindergarten>(
                                        value: school,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(school.name,
                                                style: smallerTextStyle(
                                                    color:
                                                        ThemeColor.blackColor)),
                                            Text(school.address,
                                                style: smallerTextStyle(
                                                    color: ThemeColor
                                                        .blueGreyColor)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizeConfig.mediumVerticalBox,
                              ],
                            );
                          }),
                    )),
                SizeConfig.ultraSmallVerticalBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    KiButton.rectButton(
                        color: ThemeColor.themeBlueColor,
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.blockSizeVertical,
                            horizontal: SizeConfig.medium),
                        child: Text('Done',
                            style:
                                smallTextStyle(color: ThemeColor.whiteColor)),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          _formKey.currentState.save();
                          if (noAgeError[0] &&
                              noFirstNameError[0] &&
                              noLastNameError[0] &&
                              selectedKindergarten[0] != null) {
                           await updateDatabase();
                          }
                          setState(() {
                            isLoading = false;
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
  Future<void> updateDatabase()async{
    try {
      List<String> firstName = new List.from([]);
      List<String> lastName = new List.from([]);
      List<String> age = new List.from([]);
      List<int> status =new List.from([]);
      List<String> uid = new List.from([]);
      List<String> kindergartenList = new List.from([]);

      for (int x = 0; x < noOfChildren; x++) {
        firstName.add(
            firstNameController[x].text.toString());
        lastName
            .add(lastNameController[x].text.toString());
        age.add(ageController[x].text.toString());
        kindergartenList
            .add(selectedKindergarten[x].name);
        uid.add('${widget.uid}+$x');
        status.add(0);

        await student.doc('${widget.uid}+$x').set({
          'first name': firstName[x],
          'last name': lastName[x],
          'age': age[x],
          'kindergarten': kindergartenList[x],
          'guardian': widget.uid,
          'latest grade':null
        });

        List<String> pendingStudentUID = new List.from([]);

        DocumentSnapshot snapshot = await kindergarten.doc(kindergartenList[x]).get();
        pendingStudentUID =List.from(snapshot.data()['pending student uid']??new List.from([]));
        pendingStudentUID.add('${widget.uid}+$x');
        await kindergarten
            .doc(kindergartenList[x])
            .set({
          'pending student uid':pendingStudentUID
        }, SetOptions(merge: true)).then((_) {
          print("success!");
        });
      }

      await guardian.doc(widget.uid).set({
        'children first name': firstName,
        'children last name': lastName,
        'children age': age,
        'children uid':uid,
        'children status':status,
        'children kindergarten': kindergartenList,
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });


      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor:
        ThemeColor.blueGreyColor.withOpacity(0.8),
        content: Text(
          'Your information is updated successfully',
          style: smallTextStyle(
              color: ThemeColor.whiteColor),
        ),
      ));

      if (widget.showLogout) {
        widget.newGuardianCallback();
        Navigator.pop(context);
      }

    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor:
        ThemeColor.blueGreyColor.withOpacity(0.8),
        content: Text(
          'System error. Please check your internet connection.',
          style: smallTextStyle(
              color: ThemeColor.whiteColor),
        ),
      ));
    }
  }
}
