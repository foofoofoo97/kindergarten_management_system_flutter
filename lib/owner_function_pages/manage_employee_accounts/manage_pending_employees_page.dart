import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:kiki/ui_widgets/action_alert_dialog.dart';

class ManagePendingEmployeesPage extends StatefulWidget {
  @override
  _ManagePendingEmployeesPageState createState() =>
      _ManagePendingEmployeesPageState();
}

class _ManagePendingEmployeesPageState
    extends State<ManagePendingEmployeesPage> {
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference employee =
      FirebaseFirestore.instance.collection('employee');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  List<EmployeeAccounts> employeeAccountss = new List.from([]);
  List<EmployeeAccounts> items = new List.from([]);
  List<String> selected = new List.from([]);

  TextEditingController searchController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading;
  bool isManaging;
  int open;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    isManaging = false;
    open=0;
    init();
    super.initState();
  }

  Future<void> init() async {
    for (String uid in kindergartenProfile.pendingEmployeeUID) {
      DocumentSnapshot documentSnapshot = await employee.doc(uid).get();
      Map data = documentSnapshot.data();
      EmployeeAccounts employeeAccounts = new EmployeeAccounts();
      employeeAccounts.firstName = data['first name'];
      employeeAccounts.lastName = data['last name'];
      employeeAccounts.uid = uid;
      employeeAccounts.jobTitle = data['job title'];
      employeeAccounts.contactNo = data['contact no'];
      employeeAccounts.homeAddress = data['home address'];
      employeeAccountss.add(employeeAccounts);
    }
    items.addAll(employeeAccountss);

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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ThemeColor.blueColor)),
              ),
            ))
        : Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: ()async{
                  items.clear();
                  employeeAccountss.clear();
                  await init();
                },
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: ThemeColor.whiteColor,
                  appBar: kiAppBar(AppBarType.backButton, context),
                  body: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.small,
                          right: SizeConfig.small,
                          top: SizeConfig.extraSmall),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Pending Employees',
                              style: mediumSTextStyle(
                                  color: ThemeColor.themeBlueColor),
                            ),
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          Padding(
                            padding: EdgeInsets.all(SizeConfig.extraSmall),
                            child: KiTextField.borderedTextFormField(
                                controller: searchController,
                                titleText: 'Search',
                                hintText: 'Search pending employee name, job',
                                maxLines: 1,
                                onChanged: (value) {
                                  open=0;
                                 filterSearchResults(value);
                                },
                                hintStyle: smallerTextStyle(
                                    color: ThemeColor.blueGreyColor),
                                activeBorderColor: ThemeColor.themeBlueColor,
                                borderColor: ThemeColor.blueGreyColor,
                                radius: 25.0,
                                textStyle: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                                labelStyle: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor)),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            shrinkWrap: true,
                            itemBuilder: (context,x) {
                              return Card(
                                color: selected.contains(items[x].uid)
                                    ? ThemeColor.lightestBlueGreyColor
                                    : ThemeColor.whiteColor,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.all(
                                        SizeConfig.safeBlockVertical),
                                    leading:
                                        Wrap(
                                          children:<Widget>[
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                size: SizeConfig.extraLarge,
                                                color: ThemeColor.lightBlueColor2,),
                                              onPressed: () async{
                                                setState(() {
                                                  isManaging=true;
                                                });
                                                await updateKindergartenDatabase(items[x]);
                                                items.clear();
                                                employeeAccountss.clear();
                                                selected.clear();
                                                await init();
                                                setState(() {
                                                  open=0;
                                                  isManaging=false;
                                                });
                                              },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              open == x ? Icons.expand_less : Icons
                                                  .expand_more,
                                              size: SizeConfig.extraLarge,
                                              color: ThemeColor.lightBlueColor2,),
                                            onPressed: () {
                                              setState(() {
                                                open == x ? open = null : open = x;
                                              });
                                            },
                                          )
                                     ]),
                                    onTap: () {
                                      setState(() {
                                        if (selected.contains(items[x].uid))
                                          selected.remove(items[x].uid);
                                        else
                                          selected.add(items[x].uid);
                                      });
                                    },
                                    trailing: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: ThemeColor.redColor,
                                        ),
                                        iconSize: SizeConfig.medium,
                                        onPressed: () {
                                          showDialog(context: context,
                                              builder: (context) =>
                                                  ActionAlertDialog(
                                                      title: 'Delete ${items[x]
                                                          .firstName} ${items[x]
                                                          .lastName}',
                                                      msg: 'Are you confirm to delete ${items[x]
                                                          .firstName} ${items[x]
                                                          .lastName} from the list?',
                                                      onPressed: () async {
                                                        setState(() {
                                                          isManaging = true;
                                                        });

                                                        try {
                                                          await employee.doc(
                                                              items[x].uid).update(
                                                              {'status': -1});
                                                          kindergartenProfile.pendingEmployeeUID.remove(items[x].uid);
                                                          await kindergarten
                                                              .doc(
                                                              kindergartenProfile
                                                                  .name)
                                                              .update({
                                                            'pending employee uid':kindergartenProfile.pendingEmployeeUID
                                                          });

                                                          items.clear();
                                                          employeeAccountss
                                                              .clear();
                                                          selected.clear();
                                                          await init();
                                                          setState(() {
                                                            open=0;
                                                          });

                                                          Navigator.pop(context);

                                                          Fluttertoast.showToast(
                                                              msg: 'Selected employee is removed',
                                                              fontSize: SizeConfig
                                                                  .smaller,
                                                              backgroundColor: ThemeColor
                                                                  .themeBlueColor,
                                                              textColor: ThemeColor
                                                                  .whiteColor);
                                                        } catch (e) {
                                                          _scaffoldKey.currentState
                                                              .showSnackBar(
                                                              SnackBar(
                                                                backgroundColor:
                                                                ThemeColor
                                                                    .themeBlueColor
                                                                    .withOpacity(
                                                                    0.8),
                                                                content: Text(
                                                                  'Connection failed. Please check your connection',
                                                                  style: extraSmallTextStyle(
                                                                      color: ThemeColor
                                                                          .whiteColor),
                                                                ),
                                                              ));
                                                        }
                                                        setState(() {
                                                          isManaging = false;
                                                        });
                                                      }));
                                        }),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${items[x].firstName} ${items[x]
                                              .lastName}',
                                          style: smallerTextStyle(
                                              color: ThemeColor.themeBlueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          '${items[x].jobTitle}',
                                          style: smallerTextStyle(
                                              color: open == x ? ThemeColor
                                                  .blueColor : ThemeColor
                                                  .blueGreyColor),
                                        ),
                                      ],
                                    ),
                                    subtitle: open == x ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizeConfig.extraSmallVerticalBox,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text('Contact No',style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                                            Text(items[x].contactNo,style: smallererTextStyle(color: ThemeColor.blackColor),)
                                          ],
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text('Home Address',style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                                            Text(items[x].homeAddress,style: smallererTextStyle(color: ThemeColor.blackColor),)
                                          ],
                                        ),
                                      ],
                                    ) : Container()
                                ),
                              );
                            }),
                          SizeConfig.mediumVerticalBox
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: selected.length > 0
                      ? BottomAppBar(
                    elevation: 0.0,
                    color: ThemeColor.lightestBlueGreyColor,
                    child: KiButton.smallButton(
                      onPressed: (){
                        showDialog(context: context,
                            builder: (context) =>
                                ActionAlertDialog(
                                    title: 'Delete Employee',
                                    msg: 'Are you confirm to delete ${selected.length} employees from the list?',
                                    onPressed: () async {
                                      setState(() {
                                        isManaging = true;
                                      });
                                      try {
                                        for (String x in selected) {
                                          await employee.doc(x).update({'status': -1});
                                          kindergartenProfile.pendingEmployeeUID.remove(x);
                                        }

                                        await kindergarten
                                            .doc(kindergartenProfile.name)
                                            .update({
                                          'pending employee uid':kindergartenProfile.pendingEmployeeUID
                                            });

                                        items.clear();
                                        employeeAccountss.clear();
                                        selected.clear();
                                        await init();

                                        setState(() {
                                          open=0;
                                        });

                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg: 'Employees is removed',
                                            fontSize: SizeConfig.smaller,
                                            backgroundColor: ThemeColor.themeBlueColor,
                                            textColor: ThemeColor.whiteColor);
                                      } catch (e) {
                                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                                          backgroundColor:
                                          ThemeColor.themeBlueColor.withOpacity(0.8),
                                          content: Text(
                                            'Connection failed. Please check your connection',
                                            style: extraSmallTextStyle(
                                                color: ThemeColor.whiteColor),
                                          ),
                                        ));
                                      }
                                      setState(() {
                                        isManaging = false;
                                      });
                                    }));},
                      child: Container(
                          height: SizeConfig.safeBlockVertical * 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Remove ${selected.length == kindergartenProfile.employeeUID.length ? 'All' : selected.length} Employees',
                                style: smalllTextStyle(
                                    color: ThemeColor.redColor),
                              ),
                              SizeConfig.smallHorizontalBox,
                              Icon(
                                Icons.delete,
                                color: ThemeColor.redColor,
                                size: SizeConfig.medium,
                              )
                            ],
                          )),
                    ),
                  ) : null,
                ),
              ),
              isManaging
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

  Future<void> updateKindergartenDatabase(
      EmployeeAccounts employeeAccount) async {
    try {
      kindergartenProfile.pendingEmployeeUID.remove(employeeAccount.uid);
      kindergartenProfile.employeeUID.add(employeeAccount.uid);
      kindergartenProfile.employeeFirstName.add(employeeAccount.firstName);
      kindergartenProfile.employeeLastName.add(employeeAccount.lastName);
      kindergartenProfile.employeeJobTitle.add(employeeAccount.jobTitle);
      kindergartenProfile.canPosts.add(0);
      kindergartenProfile.canPerformance.add(0);
      kindergartenProfile.canAttendance.add(0);
      kindergartenProfile.canResults.add(0);
      kindergartenProfile.employeeAbsent = kindergartenProfile.employeeAbsent+1;

      await kindergarten.doc(kindergartenProfile.name).set({
        'employee uid': kindergartenProfile.employeeUID,
        'employee first name': kindergartenProfile.employeeFirstName,
        'employee last name': kindergartenProfile.employeeLastName,
        'employee job title': kindergartenProfile.employeeJobTitle,
        'can posts': kindergartenProfile.canPosts,
        'can results': kindergartenProfile.canResults,
        'can attendance': kindergartenProfile.canAttendance,
        'can performance': kindergartenProfile.canPerformance,
        'pending employee uid': kindergartenProfile.pendingEmployeeUID,
        'employee absent': kindergartenProfile.employeeAbsent,
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });

      await employee.doc(employeeAccount.uid).update({
        'status':1
      });

      await employee.doc(employeeAccount.uid).collection('attendance').doc('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}').
      set({
        'status':'absent',
        'datetime':DateTime.now()
      });

      Fluttertoast.showToast(
          msg: 'New employee is added',
          fontSize: SizeConfig.smaller,
          textColor: ThemeColor.whiteColor,
          backgroundColor: ThemeColor.themeBlueColor);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'New employee is added successfully',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Server Failure',
          fontSize: SizeConfig.smaller,
          textColor: ThemeColor.whiteColor,
          backgroundColor: ThemeColor.themeBlueColor);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Kindergarten Database Error. Please check your internet connection.',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }

  void filterSearchResults(String query) {
    List<EmployeeAccounts> dummySearchList = new List.from([]);
    dummySearchList.addAll(employeeAccountss);
    if (query.isNotEmpty) {
      List<EmployeeAccounts> dummyListData = new List.from([]);
      dummySearchList.forEach((item) {
        if (('${item.firstName} ${item.lastName}')
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if (item.jobTitle.toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        open=0;
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        open=0;
        items.clear();
        items.addAll(employeeAccountss);
      });
    }
  }
}
