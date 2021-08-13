import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/design_ui.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:kiki/ui_widgets/search_students_dialog.dart';

class AddNewFeesPage extends StatefulWidget {
  String feeName;
  Map data;
  Map profile;

  Function onPressed;
  AddNewFeesPage({this.feeName,this.onPressed,this.data,this.profile});
  @override
  _AddNewFeesPageState createState() => _AddNewFeesPageState();
}

class _AddNewFeesPageState extends State<AddNewFeesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController nameController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();

  int _type;

  bool noNameError;
  bool noAmountError;

  bool appliedAll;

  List<Widget> tags = new List.from([]);
  List chosenUIDs = new List.from([]);
  List chosenFirstName = new List.from([]);
  List chosenLastName = new List.from([]);
  List initial = new List.from([]);

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference student =
      FirebaseFirestore.instance.collection('student');

  bool isLoading;
  bool isReading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = false;
    noNameError = true;
    noAmountError = true;
    isReading=false;
    appliedAll = true;
    _type = 0;
    if(widget.feeName!=null){
      isReading=true;
      init();
    }
    super.initState();
  }

  Future<void> init()async{
    nameController.text=widget.feeName;
    amountController.text=widget.data['amount'].toStringAsFixed(2);
    _type =widget.data['type'];
    initial.addAll(widget.data['selected students']);
    if(_type==0){
      appliedAll=true;
    }
    else{
      appliedAll=false;
      if(_type==1){
        chosenUIDs.addAll(widget.profile['student uid']);
        chosenFirstName.addAll(widget.profile['student first name']);
        chosenLastName.addAll(widget.profile['student last name']);
        for(String uid in widget.data['selected students']){
          int index = chosenUIDs.indexOf(uid);
          chosenUIDs.remove(uid);
          chosenFirstName.removeAt(index);
          chosenLastName.removeAt(index);
        }
      }
      else{
        chosenUIDs.addAll(widget.data['selected students']);
        chosenLastName.addAll(widget.data['selected students lname']);
        chosenFirstName.addAll(widget.data['selected students fname']);
      }
    }
    buildTags();
    setState(() {
      isReading=false;
    });
  }

  List<Widget> buildTags(){
    List<Widget> temp = new List.from([]);
    for (int x = 0; x < chosenUIDs.length; x++) {
        tags.add(Card(
            elevation: 8.0,
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius
                  .circular(
                  8.0),
            ),
            color: ThemeColor
                .whiteColor,
            child: Padding(
              padding: EdgeInsets
                  .all(SizeConfig
                  .safeBlockVertical),
              child: Text(
                '${chosenFirstName[x]} ${chosenLastName[x]}',
                style: smallerTextStyle(
                    color: ThemeColor
                        .themeBlueColor),
              ),
            )));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        isReading? Container(
            color: ThemeColor.whiteColor,
            child:Center(
              child: SizedBox(
                height: SizeConfig.safeBlockVertical * 5,
                width: SizeConfig.safeBlockVertical * 5,
                child: CircularProgressIndicator(
                  backgroundColor: ThemeColor.whiteColor,
                ),
              ),
            )):KiPage(
          color: ThemeColor.whiteColor,
          scaffoldKey: _scaffoldKey,
          appBarType: AppBarType.backButton,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.small),
            child: Column(
              children: <Widget>[
                Text(
                  'New Fee',
                  style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor),
                ),
                SizeConfig.mediumVerticalBox,
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      KiTextField.borderedTextFormField(
                          activeBorderColor: ThemeColor.blueColor,
                          borderColor: ThemeColor.themeBlueColor,
                          controller: nameController,
                          titleText: 'Fee Name',
                          maxLines: 1,
                          hintText: 'Enter fee name',
                          onSaved: (value) {
                            setState(() {
                              noNameError =
                                  Validators.compulsoryValidator(value);
                            });
                          },
                          noError: noNameError,
                          errorText: 'Fee name cannot be empty',
                          hintStyle:
                              smallerTextStyle(color: ThemeColor.blueGreyColor),
                          textStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor),
                          errorStyle: extraSmallTextStyle(
                              color: ThemeColor.blueGreyColor),
                          labelStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor)),
                      SizeConfig.smallVerticalBox,
                      KiTextField.borderedTextFormField(
                          activeBorderColor: ThemeColor.blueColor,
                          borderColor: ThemeColor.themeBlueColor,
                          controller: amountController,
                          titleText: 'Fee Amount',
                          textInputType: TextInputType.number,
                          maxLines: 1,
                          hintText: 'Enter fee amount (RM)',
                          onSaved: (value) {
                            setState(() {
                              noAmountError = Validators.numberValidator(value);
                            });
                          },
                          noError: noAmountError,
                          errorText: 'Fee amount cannot be empty',
                          hintStyle:
                              smallerTextStyle(color: ThemeColor.blueGreyColor),
                          textStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor),
                          errorStyle: extraSmallTextStyle(
                              color: ThemeColor.blueGreyColor),
                          labelStyle: smallerTextStyle(
                              color: ThemeColor.themeBlueColor)),
                      SizeConfig.smallVerticalBox,
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.safeBlockVertical,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: ThemeColor.themeBlueColor, width: 1.0)),
                        child: CheckboxListTile(
                          dense: true,
                          value: appliedAll,
                          onChanged: (choice) {
                            setState(() {
                              appliedAll = choice;
                              if (appliedAll)
                                _type = 0;
                              else
                                _type = 1;
                            });
                          },
                          title: Text(
                            'Fee Applied To All Students',
                            style: smallerTextStyle(
                                color: ThemeColor.themeBlueColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizeConfig.smallVerticalBox,
                !appliedAll
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.safeBlockVertical,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: ThemeColor.themeBlueColor, width: 1.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RadioListTile<int>(
                              value: 1,
                              dense: true,
                              groupValue: _type,
                              onChanged: (int type) {
                                setState(() {
                                  _type = type;
                                });
                              },
                              title: Text('Fee Excluded To Selected Students',
                                  style: smallerTextStyle(
                                      color: ThemeColor.themeBlueColor)),
                            ),
                            RadioListTile<int>(
                              value: 2,
                              dense: true,
                              groupValue: _type,
                              onChanged: (int type) {
                                setState(() {
                                  _type = type;
                                });
                              },
                              title: Text('Fee Applied To Selected Students',
                                  style: smallerTextStyle(
                                      color: ThemeColor.themeBlueColor)),
                            )
                          ],
                        ))
                    : Container(),
                SizeConfig.smallVerticalBox,
                _type == 0
                    ? Container()
                    : Container(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical,
                            horizontal: SizeConfig.extraSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: ThemeColor.themeBlueColor, width: 1.0),
                        ),
                        child: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                _type == 1
                                    ? 'Select Students To Be Excluded'
                                    : 'Select Students To Be Charged',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              KiButton.smallButton(
                                  child: Card(
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeVertical * 0.7),
                                        child: Icon(
                                          Icons.person_add,
                                          size: SizeConfig.large,
                                          color: ThemeColor.themeBlueColor,
                                        )),
                                    color: ThemeColor.whiteColor,
                                    elevation: 10.0,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            SearchStudentsDialog(
                                              uid: chosenUIDs,
                                              onPressed: (value) {
                                                chosenLastName.clear();
                                                chosenFirstName.clear();
                                                chosenUIDs.clear();
                                                setState(() {
                                                  tags.clear();
                                                  tags.add(blankContainer());
                                                });

                                                for (int x = 0;
                                                    x < value.length;
                                                    x++) {
                                                  if (value[x]) {
                                                    chosenUIDs.add(
                                                        kindergartenProfile
                                                            .studentUID[x]);
                                                    chosenFirstName.add(
                                                        kindergartenProfile
                                                            .studentFirstName[x]);
                                                    chosenLastName.add(
                                                        kindergartenProfile
                                                            .studentLastName[x]);
                                                  }
                                                }
                                                List<Widget> temp = new List.from([]);
                                                for (int x = 0;
                                                x < chosenUIDs.length;
                                                x++) {
                                                  setState(() {
                                                    tags.add(Card(
                                                        elevation: 8.0,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              8.0),
                                                        ),
                                                        color: ThemeColor
                                                            .whiteColor,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .all(SizeConfig
                                                              .safeBlockVertical),
                                                          child: Text(
                                                            '${chosenFirstName[x]} ${chosenLastName[x]}',
                                                            style: smallerTextStyle(
                                                                color: ThemeColor
                                                                    .themeBlueColor),
                                                          ),
                                                        )));
                                                  });
                                                }
                                                return temp;                                              },
                                            ));
                                  })
                            ],
                          ),
                          tags == null
                              ? Container()
                              : SizeConfig.extraSmallVerticalBox,
                          Wrap(
                            children: tags,
                          ),
                          tags == null
                              ? Container()
                              : SizeConfig.extraSmallVerticalBox,
                        ])),
                SizeConfig.smallVerticalBox,
                KiButton.rectButton(
                    child: Text(
                      'Add Fee',
                      style: smallerTextStyle(color: ThemeColor.whiteColor),
                    ),
                    color: ThemeColor.themeBlueColor,
                    onPressed: () async {
                      _formKey.currentState.save();

                      if(noAmountError&&noNameError) {
                        try {
                          setState(() {
                            isLoading = true;
                          });

                          List filteredUID = new List.from([]);
                          List filteredFirstName = new List.from([]);
                          List filteredLastName = new List.from([]);

                          print('delete');
                          if(widget.feeName!=null){
                            print(initial);
                            for(String uid in initial){
                              print(uid);
                              await student.doc(uid).collection('fees').doc(widget.feeName).delete();
                            }
                          }
                          if (_type == 1) {
                            filteredUID.addAll(kindergartenProfile.studentUID);
                            filteredFirstName.addAll(kindergartenProfile.studentFirstName);
                            filteredLastName.addAll(kindergartenProfile.studentLastName);

                            for (int x=0; x< chosenUIDs.length;x++) {
                              filteredUID.remove(chosenUIDs[x]);
                              filteredFirstName.remove(chosenFirstName[x]);
                              filteredLastName.remove(chosenLastName[x]);
                            }
                          }
                          else if (_type == 2) {
                              filteredUID.addAll(chosenUIDs);
                              filteredFirstName.addAll(chosenFirstName);
                              filteredLastName.addAll(chosenLastName);
                          }
                          else {
                            filteredUID.addAll(kindergartenProfile.studentUID);
                            filteredFirstName.addAll(kindergartenProfile.studentFirstName);
                            filteredLastName.addAll(kindergartenProfile.studentLastName);
                          }

                          print('add');
                          print(filteredUID);
                          for (String uid in filteredUID) {
                            print(uid);
                            await student.doc(uid).collection('fees').doc(nameController.text.toString()).set({
                              'name': nameController.text.toString(),
                              'amount': double.parse(amountController.text.toString())
                            });
                          }

                          Map<String, dynamic> temp = {
                            'type': _type,
                            'amount':
                            double.parse(amountController.text.toString()),
                            'selected students': filteredUID,
                            'selected students fname':filteredFirstName,
                            'selected students lname':filteredLastName
                          };
                          await widget.onPressed(nameController.text.toString(), temp);
                          Navigator.pop(context);
                        } catch (e) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor:
                            ThemeColor.themeBlueColor.withOpacity(0.8),
                            content: Text(
                              'Failed to connect server. Please try again later',
                              style: extraSmallTextStyle(
                                  color: ThemeColor.whiteColor),
                            ),
                          ));
                        }
                        setState(() {
                          isLoading = false;
                        });
                      }
                      else{
                        Fluttertoast.showToast(msg: 'Fields cannot be empty',textColor: ThemeColor.whiteColor,backgroundColor: ThemeColor.themeBlueColor,fontSize: SizeConfig.smaller);
                      }
                    }),
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
