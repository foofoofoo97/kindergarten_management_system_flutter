import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:kiki/ui_widgets/action_alert_dialog.dart';

class ManagePendingStudentsPage extends StatefulWidget {
  @override
  _ManagePendingStudentsPageState createState() => _ManagePendingStudentsPageState();
}

class _ManagePendingStudentsPageState extends State<ManagePendingStudentsPage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  List<Student> items = new List.from([]);
  List<Student> students = new List.from([]);
  List<String> selected = new List.from([]);

  TextEditingController searchController = new TextEditingController();

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference studentPath = FirebaseFirestore.instance.collection('student');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');

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

  Future<void> init()async{
    for(String uid in kindergartenProfile.pendingStudentUID){
      Student profile = new Student();
      profile.uid = uid;

      String guardianUid = uid.split('+')[0];
      int index = int.parse(uid.split('+')[1]);
      DocumentSnapshot documentSnapshot = await guardian.doc(guardianUid).get();
      Map data =documentSnapshot.data();
      profile.lastName =List.from(data['children last name'])[index];
      profile.firstName = List.from(data['children first name'])[index];
      profile.guardian = '${data['first name']} ${data['last name']}';
      profile.age =int.parse(List.from(data['children age'])[index]);
      profile.contact = data['contact no'];

      students.add(profile);
    }
    items.addAll(students);

    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading
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
            students.clear();
            selected.clear();
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
                        'Pending Students',
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
                          hintText: 'Search pending student name, age, guardian',
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
                                          await updateDatabase(items[x]);
                                          items.clear();
                                          students.clear();
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
                                                      DocumentSnapshot document = await guardian.doc(items[x].uid.split('+')[0]).get();
                                                      Map data =document.data();
                                                      int index =int.parse(items[x].uid.split('+')[1]);
                                                      List<int> statuses = List.from(data['children status']);
                                                      statuses[index]=-1;

                                                      await guardian.doc(items[x].uid.split('+')[0]).update({'children status': statuses});
                                                      kindergartenProfile.pendingStudentUID.remove(items[x].uid);

                                                      await kindergarten
                                                          .doc(
                                                          kindergartenProfile
                                                              .name)
                                                          .update({
                                                        'pending student uid':kindergartenProfile.pendingStudentUID
                                                      });

                                                      items.clear();
                                                      students.clear();
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
                                      '${items[x].age} Years Old',
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
                                        Text('Guardian',style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                                        Text(items[x].guardian,style: smallererTextStyle(color: ThemeColor.blackColor),)
                                      ],
                                    ),
                                    SizeConfig.ultraSmallVerticalBox,
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Contact No',style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                                        Text(items[x].contact,style: smallererTextStyle(color: ThemeColor.blackColor),)
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
                                    DocumentSnapshot document = await guardian.doc(x.split('+')[0]).get();
                                    Map data =document.data();
                                    int index =int.parse(x.split('+')[1]);
                                    List<int> statuses = List.from(data['children status']);
                                    statuses[index]=-1;
                                    await guardian.doc(x.split('+')[0]).update({'children status': statuses});
                                    kindergartenProfile.pendingStudentUID.remove(x);
                                  }

                                  await kindergarten
                                      .doc(kindergartenProfile.name)
                                      .update({
                                    'pending student uid':kindergartenProfile.pendingStudentUID
                                  });

                                  items.clear();
                                  students.clear();
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

  void filterSearchResults(String query) {
    List<Student> dummySearchList = new List.from([]);
    dummySearchList.addAll(students);
    if (query.isNotEmpty) {
      List<Student> dummyListData = new List.from([]);
      dummySearchList.forEach((item) {
        if (('${item.firstName} ${item.lastName}')
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if (item.age.toString().contains(query)){
          dummyListData.add(item);
        }else if(item.guardian.toLowerCase().contains(query.toLowerCase())){
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
        items.addAll(students);
      });
    }
  }

  Future<void> updateDatabase(Student student)async{
    try {
      kindergartenProfile.studentFirstName.add(student.firstName);
      kindergartenProfile.studentUID.add(student.uid);
      kindergartenProfile.studentLastName.add(student.lastName);
      kindergartenProfile.studentAge.add(student.age);
      kindergartenProfile.pendingStudentUID.remove(student.uid);
      kindergartenProfile.studentAbsent = kindergartenProfile.studentAbsent+1;

      kindergartenProfile.feesType
          .forEach((key, value) {
        if(value['type']==0||value['type']==1){
          value['selected students'].add(student.uid);
          value['selected students fname'].add(student.firstName);
          value['selected students lname'].add(student.lastName);
        }
      });

      await kindergarten.doc(kindergartenProfile.name).set({
        'student first name': kindergartenProfile.studentFirstName,
        'student last name': kindergartenProfile.studentLastName,
        'student uid': kindergartenProfile.studentUID,
        'student age': kindergartenProfile.studentAge,
        'pending student uid': kindergartenProfile.pendingStudentUID,
        'student absent': kindergartenProfile.studentAbsent,
        'fees type':kindergartenProfile.feesType
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });

      await studentPath.doc(student.uid).collection('attendance').doc('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}').
      set({
        'status':'absent',
        'datetime':DateTime.now()
      });

      DocumentSnapshot document = await guardian.doc(student.uid.split('+')[0]).get();
      Map data =document.data();
      int index =int.parse(student.uid.split('+')[1]);
      List<int> statuses = List.from(data['children status']);
      statuses[index]=-1;
      await guardian.doc(student.uid.split('+')[0]).update({'children status': statuses});

      Fluttertoast.showToast(
          msg: 'New student is added',
          fontSize: SizeConfig.smaller,
          textColor: ThemeColor.whiteColor,
          backgroundColor: ThemeColor.themeBlueColor);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'New student is added successfully',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }catch(e){
      Fluttertoast.showToast(
          msg: 'Server Failure',
          fontSize: SizeConfig.smaller,
          textColor: ThemeColor.whiteColor,
          backgroundColor: ThemeColor.themeBlueColor);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Server Error. Please check your internet connection.',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
  }
}
