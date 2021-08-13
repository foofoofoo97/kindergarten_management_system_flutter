import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/chat_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/owner_function_pages/manage_employee_accounts/manage_pending_employees_page.dart';
import 'package:kiki/owner_function_pages/manage_employee_accounts/manage_selected_employee_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/action_alert_dialog.dart';

class ManageEmployeeAccountsPage extends StatefulWidget {
  @override
  _ManageEmployeeAccountsPageState createState() =>
      _ManageEmployeeAccountsPageState();
}

class _ManageEmployeeAccountsPageState
    extends State<ManageEmployeeAccountsPage> {
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  OwnerProfile ownerProfile = new OwnerProfile();

  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference employee =
      FirebaseFirestore.instance.collection('employee');

  TextEditingController searchController = new TextEditingController();

  List<EmployeeAccounts> employeeAccs = new List.from([]);
  List<EmployeeAccounts> items = new List.from([]);
  List<String> selected = new List.from([]);
  int open;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading;
  bool isDeleting;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    isDeleting = false;
    open=0;
    init();
    super.initState();
  }

  void init() {
    for (int x = 0; x < kindergartenProfile.employeeUID.length; x++) {
      EmployeeAccounts accounts = new EmployeeAccounts();
      accounts.firstName = kindergartenProfile.employeeFirstName[x];
      accounts.lastName = kindergartenProfile.employeeLastName[x];
      accounts.uid = kindergartenProfile.employeeUID[x];
      accounts.jobTitle = kindergartenProfile.employeeJobTitle[x];
      accounts.canAttendance = kindergartenProfile.canAttendance[x];
      accounts.canPosts = kindergartenProfile.canPosts[x];
      accounts.canPerformance = kindergartenProfile.canPerformance[x];
      accounts.canResults = kindergartenProfile.canResults[x];
      employeeAccs.add(accounts);
    }

    items.addAll(employeeAccs);

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
                  employeeAccs.clear();
                  setState(() {
                    init();
                  });
                },
                child: Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    backgroundColor: ThemeColor.whiteColor,
                    elevation: 0,
                    leading: KiButton.smallButton(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.blueGreyColor,
                          size: SizeConfig.large,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    actions: <Widget>[
                      KiButton.smallButton(
                          child: Row(children: <Widget>[
                            Icon(Icons.add_circle,color: ThemeColor.themeBlueColor,size: SizeConfig.medium,),
                            SizeConfig.smallHorizontalBox,
                            Text('Pending',style: smalllTextStyle(color: ThemeColor.themeBlueColor),),
                          ],),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>ManagePendingEmployeesPage()
                            ));
                          }
                      ),
                      SizeConfig.largeHorizontalBox
                    ],
                  ),
                  backgroundColor: ThemeColor.whiteColor,
                  body: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.small,
                          right: SizeConfig.small,
                          top: SizeConfig.extraSmall
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Employee Accounts',
                                style:
                                mediumSTextStyle(color: ThemeColor.themeBlueColor),
                              ),
                            ],
                          ),
                          SizeConfig.extraSmallVerticalBox,
                          Padding(
                            padding: EdgeInsets.all(SizeConfig.extraSmall),
                            child: KiTextField.borderedTextFormField(
                                controller: searchController,
                                titleText: 'Search',
                                hintText: 'Search employee name, job',
                                maxLines: 1,
                                onChanged: (value) {
                                  open=null;
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
                          SizeConfig.ultraSmallVerticalBox,
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            shrinkWrap: true,
                            itemBuilder: (context, x) {
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
                                  leading: Wrap(
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(
                                            Icons.message,
                                            color: ThemeColor.lightBlueColor2,
                                          ),
                                          iconSize: SizeConfig.large,
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Chat(
                                                          uid: ownerProfile.uid,
                                                          peerId: items[x].uid,
                                                          peerName:
                                                              '${items[x].firstName} ${items[x].lastName}',
                                                          peerType: 'guardian',
                                                          type: 'owner',
                                                        )));
                                          }),
                                      IconButton(
                                        icon: Icon(open==x?Icons.expand_less:Icons.expand_more,size: SizeConfig.extraLarge,color: ThemeColor.lightBlueColor2,),
                                        onPressed: (){
                                          setState(() {
                                            open==x? open=null:open=x;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  onLongPress: (){
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context)=>ManageSelectedEmployeePage(
                                        employeeAccounts: items[x],
                                        index: x,
                                      )
                                    ));
                                  },
                                  onTap: () {
                                    setState(() {
                                      if(selected.contains(items[x].uid))
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
                                  onPressed:(){
                              showDialog(context: context,
                              builder: (context) =>
                              ActionAlertDialog(
                              title: 'Delete ${items[x].firstName} ${items[x].lastName}',
                              msg: 'Are you confirm to delete ${items[x].firstName} ${items[x].lastName} from the list?',
                              onPressed: () async {
                                      setState(() {
                                        isDeleting = true;
                                      });
                                      try {
                                        DocumentSnapshot document = await employee.doc(items[x].uid).collection('attendance').doc('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}').get();
                                        String status = document.data()['status'];
                                        status=='present'? kindergartenProfile.employeePresent=kindergartenProfile.employeePresent-1:
                                        status=='absent'? kindergartenProfile.employeeAbsent=kindergartenProfile.employeeAbsent-1:
                                        status=='leave'?kindergartenProfile.employeeLeave=kindergartenProfile.employeeLeave-1:
                                        kindergartenProfile.employeeLate=kindergartenProfile.employeeLate-1;
                                         await employee.doc(items[x].uid).update({' status': -1});
                                          int index = kindergartenProfile.employeeUID.indexOf(items[x].uid);
                                          kindergartenProfile.employeeUID.removeAt(index);
                                          kindergartenProfile.employeeJobTitle
                                              .removeAt(index);
                                          kindergartenProfile.employeeLastName
                                              .removeAt(index);
                                          kindergartenProfile.employeeFirstName
                                              .removeAt(index);
                                          kindergartenProfile.canAttendance
                                              .removeAt(index);
                                          kindergartenProfile.canPerformance
                                              .removeAt(index);
                                          kindergartenProfile.canPosts.removeAt(index);
                                          kindergartenProfile.canResults.removeAt(index);
                                        await kindergarten
                                            .doc(kindergartenProfile.name)
                                            .update({
                                          'employee first name':
                                          kindergartenProfile.employeeFirstName,
                                          'employee last name':
                                          kindergartenProfile.employeeLastName,
                                          'employee uid': kindergartenProfile.employeeUID,
                                          'employee job title':
                                          kindergartenProfile.employeeJobTitle,
                                          'can attendance':
                                          kindergartenProfile.canAttendance,
                                          'can posts': kindergartenProfile.canPosts,
                                          'can performance':
                                          kindergartenProfile.canPerformance,
                                          'can results': kindergartenProfile.canResults,
                                          'employee present':kindergartenProfile.employeePresent,
                                          'employee late': kindergartenProfile.employeeLate,
                                          'employee leave':kindergartenProfile.employeeLeave,
                                          'employee absent':kindergartenProfile.employeeAbsent
                                        });

                                        setState(() {
                                          items.clear();
                                          employeeAccs.clear();
                                          init();
                                        });

                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg: 'Employee is removed',
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
                                        isDeleting = false;
                                      });
                                    }));
                                  }),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${items[x].firstName} ${items[x].lastName}',
                                        style: smallerTextStyle(
                                            color: ThemeColor.themeBlueColor),
                                      ),
                                      SizeConfig.ultraSmallVerticalBox,
                                      Text(
                                        '${items[x].jobTitle}',
                                        style: smallerTextStyle(
                                            color: open==x?ThemeColor.blueColor:ThemeColor.blueGreyColor),
                                      ),
                                    ],
                                  ),
                                  subtitle: open==x? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizeConfig.extraSmallVerticalBox,
                                      Text('Accessibility',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                                      SizeConfig.ultraSmallVerticalBox,
                                      getChildren(items[x])
                                    ],
                                  ): Container()
                                ),
                              );
                            },
                          ),
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
                                isDeleting = true;
                              });
                              try {
                                for (String x in selected) {
                                  DocumentSnapshot document = await employee.doc(x).collection('attendance').doc('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}').get();
                                  String status = document.data()['status'];
                                  status=='present'? kindergartenProfile.employeePresent=kindergartenProfile.employeePresent-1:
                                  status=='absent'? kindergartenProfile.employeeAbsent=kindergartenProfile.employeeAbsent-1:
                                  status=='leave'?kindergartenProfile.employeeLeave=kindergartenProfile.employeeLeave-1:
                                      kindergartenProfile.employeeLate=kindergartenProfile.employeeLate-1;
                                  await employee.doc(x).update({' status': -1});
                                  int index =
                                      kindergartenProfile.employeeUID.indexOf(x);
                                  kindergartenProfile.employeeUID.removeAt(index);
                                  kindergartenProfile.employeeJobTitle
                                      .removeAt(index);
                                  kindergartenProfile.employeeLastName
                                      .removeAt(index);
                                  kindergartenProfile.employeeFirstName
                                      .removeAt(index);
                                  kindergartenProfile.canAttendance
                                      .removeAt(index);
                                  kindergartenProfile.canPerformance
                                      .removeAt(index);
                                  kindergartenProfile.canPosts.removeAt(index);
                                  kindergartenProfile.canResults.removeAt(index);
                                }
                                await kindergarten
                                    .doc(kindergartenProfile.name)
                                    .update({
                                  'employee first name':
                                      kindergartenProfile.employeeFirstName,
                                  'employee last name':
                                      kindergartenProfile.employeeLastName,
                                  'employee uid': kindergartenProfile.employeeUID,
                                  'employee job title':
                                      kindergartenProfile.employeeJobTitle,
                                  'can attendance':
                                      kindergartenProfile.canAttendance,
                                  'can posts': kindergartenProfile.canPosts,
                                  'can performance':
                                      kindergartenProfile.canPerformance,
                                  'can results': kindergartenProfile.canResults,
                                  'employee present':kindergartenProfile.employeePresent,
                                  'employee late': kindergartenProfile.employeeLate,
                                  'employee leave':kindergartenProfile.employeeLeave,
                                  'employee absent':kindergartenProfile.employeeAbsent
                                });

                                setState(() {
                                  items.clear();
                                  employeeAccs.clear();
                                  selected.clear();
                                  init();
                                });

                                Navigator.pop(context);
                                Fluttertoast.showToast(
                                    msg: 'Employees is removed',
                                    fontSize: SizeConfig.smaller,
                                    backgroundColor: ThemeColor.themeBlueColor,
                                    textColor: ThemeColor.whiteColor);
                              } catch (e) {
                                print(e);
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
                                isDeleting = false;
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
                        )
                      : null,
                ),
              ),
              isDeleting
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

  Widget getChildren(EmployeeAccounts employeeAccounts){
    List<Widget> list = new List.from([]);
    int index=0;
    if(employeeAccounts.canResults==1){
      index++;
      list.add(Text('Student Results',style: smallererTextStyle(color: ThemeColor.blackColor),));
    }
    if(employeeAccounts.canPerformance==1){
      index++;
      list.add(Text('Performance Analysis',style: smallererTextStyle(color: ThemeColor.blackColor),));
    }
    if(employeeAccounts.canAttendance==1){
      index++;
      list.add(Text('Student Attendance',style: smallererTextStyle(color: ThemeColor.blackColor),));
    }
    if(employeeAccounts.canPosts==1){
      index++;
      list.add(Text('Posts',style: smallererTextStyle(color: ThemeColor.blackColor),));
    }
    if(index==0){
      list.add(Text('No Feature Is Allowed',style: smallererTextStyle(color: ThemeColor.blackColor),));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }
  void filterSearchResults(String query) {
    List<EmployeeAccounts> dummySearchList = new List.from([]);
    dummySearchList.addAll(employeeAccs);
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
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(employeeAccs);
      });
    }
  }
}
