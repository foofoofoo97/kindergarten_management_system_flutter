import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/owner_function_pages/manage_student_profiles/manage_pending_students_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/action_alert_dialog.dart';
import 'package:kiki/ui_widgets/edit_student_info_dialog.dart';

class ManageStudentAccountsPage extends StatefulWidget {
  @override
  _ManageStudentAccountsPageState createState() =>
      _ManageStudentAccountsPageState();
}

class _ManageStudentAccountsPageState extends State<ManageStudentAccountsPage> {
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  TextEditingController searchController = new TextEditingController();
  Map<int, List<Student>> ageStudents = new Map();
  List<Student> items = new List.from([]);
  int selected;
  List<Student> allStudents = new List.from([]);
  List<Widget> ageWidgets = new List.from([]);
  List<String> chosens = new List.from([]);

  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference guardian =
      FirebaseFirestore.instance.collection('guardian');
  CollectionReference student =
  FirebaseFirestore.instance.collection('student');

  bool isLoading;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    selected = -1;
    isLoading = false;
    init();
    super.initState();
  }

  void init() {
    for (int index = 0;
        index < kindergartenProfile.studentFirstName.length;
        index++) {
      ageStudents.putIfAbsent(
          kindergartenProfile.studentAge[index], () => new List.from([]));
      Student temp = new Student();
      temp.uid = kindergartenProfile.studentUID[index];
      temp.firstName = kindergartenProfile.studentFirstName[index];
      temp.lastName = kindergartenProfile.studentLastName[index];
      temp.kindergarten = kindergartenProfile.name[index];
      temp.age = kindergartenProfile.studentAge[index];
      ageStudents[kindergartenProfile.studentAge[index]].add(temp);
      allStudents.add(temp);
    }
      items.addAll(selected==-1? allStudents: ageStudents[selected]);
  }

  void buildAllAgesWidgets() {
    ageWidgets = new List.from([]);
    ageWidgets.add(Card(
      elevation: 12.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: selected == -1 ? ThemeColor.lightBlueColor : ThemeColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
        child: KiButton.smallButton(
          child: Text(
            'All (${allStudents.length})',
            style: smallererTextStyle(
                color: selected == -1
                    ? ThemeColor.themeBlueColor
                    : ThemeColor.blueGreyColor),
          ),
          onPressed: () {
            setState(() {
              selected = -1;
              chosens.clear();
              items.clear();
              items.addAll(allStudents);
            });
          },
        ),
      ),
    ));
    List<int> arranged = ageStudents.keys.toList();
    arranged.sort((a, b) => a.compareTo(b));

    for (int age in arranged) {
      List<Student> students = ageStudents[age];
      ageWidgets.add(Card(
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color:
            selected == age ? ThemeColor.lightBlueColor : ThemeColor.whiteColor,
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
          child: KiButton.smallButton(
            child: Text(
              '$age Years Old (${students.length})',
              style: smallererTextStyle(
                  color: selected == age
                      ? ThemeColor.themeBlueColor
                      : ThemeColor.blueGreyColor),
            ),
            onPressed: () {
              setState(() {
                selected = age;
                chosens.clear();
                items.clear();
                items.addAll(students);
              });
            },
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    buildAllAgesWidgets();
    return Stack(children: <Widget>[
      RefreshIndicator(
        onRefresh: ()async{
          ageStudents.clear();
          items.clear();
          allStudents.clear();
          ageWidgets.clear();
          chosens.clear();
          setState(() {
            init();
            buildAllAgesWidgets();
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
                        builder: (context)=>ManagePendingStudentsPage()
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
                  top: SizeConfig.extraSmall),
              child: Column(
                children: <Widget>[
                  Center(
                      child: Text(
                    'Manage Student Profiles',
                    style: mediumSTextStyle(color: ThemeColor.themeBlueColor),
                  )),
                  SizeConfig.smallVerticalBox,
                  Center(
                      child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    runSpacing: SizeConfig.ultraSmall,
                    spacing: SizeConfig.ultraSmall,
                    children: ageWidgets,
                  )),
                  SizeConfig.smallVerticalBox,
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.extraSmall),
                    child: KiTextField.borderedTextFormField(
                        controller: searchController,
                        titleText: 'Search',
                        hintText: 'Search student name, age',
                        maxLines: 1,
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        hintStyle:
                            smallerTextStyle(color: ThemeColor.blueGreyColor),
                        activeBorderColor: ThemeColor.themeBlueColor,
                        borderColor: ThemeColor.blueGreyColor,
                        radius: 25.0,
                        textStyle:
                            smallerTextStyle(color: ThemeColor.themeBlueColor),
                        labelStyle:
                            smallerTextStyle(color: ThemeColor.themeBlueColor)),
                  ),
                  SizeConfig.ultraSmallVerticalBox,
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, x) {
                      return Card(
                        color: chosens.contains(items[x].uid)
                            ? ThemeColor.lightestBlueGreyColor
                            : ThemeColor.whiteColor,
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          dense: true,
                          onTap: () {
                            if (chosens.contains(items[x].uid)) {
                              setState(() {
                                chosens.remove(items[x].uid);
                              });
                            } else {
                              setState(() {
                                chosens.add(items[x].uid);
                              });
                            }
                          },
                          title: Text(
                            '${items[x].firstName} ${items[x].lastName}',
                            style: smallerTextStyle(
                                color: ThemeColor.themeBlueColor),
                          ),
                          subtitle: Text(
                            '${items[x].age} Years Old',
                            style: extraSmallTextStyle(
                                color: ThemeColor.blueGreyColor),
                          ),
                          leading: IconButton(
                            icon: Icon(Icons.edit),
                            color: ThemeColor.lightBlueColor2,
                            iconSize: SizeConfig.large,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      EditStudentInfoDialog(
                                        index: x,
                                        onPressed: (value) async {
                                          try {
                                            setState(() {
                                              ageStudents.clear();
                                              items.clear();
                                              allStudents.clear();
                                              ageWidgets.clear();
                                              kindergartenProfile.studentAge[x]=int.parse(value);
                                              init();
                                              buildAllAgesWidgets();
                                            });
                                            await kindergarten.doc(
                                                kindergartenProfile.name).update({
                                              'student age': kindergartenProfile.studentAge
                                            });
                                            Fluttertoast.showToast(msg:'Student age is changed',fontSize: SizeConfig.smaller, backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor);
                                          }catch(e){
                                            Fluttertoast.showToast(msg:'Failed to connect database',fontSize: SizeConfig.smaller, backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor);
                                          }
                                        },
                                      ));
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.clear),
                            iconSize: SizeConfig.medium,
                            color: ThemeColor.redColor,
                            onPressed: () async {

                              showDialog(context: context,
                                  builder: (context) =>
                                      ActionAlertDialog(
                                        title: 'Delete ${items[x].firstName} ${items[x].lastName}',
                                        msg: 'Are you sure to delete ${items[x].firstName} ${items[x].lastName} from the list?',
                                        onPressed: () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          try {
                                            String guardianID = items[x].uid
                                                .split('+')[0];
                                            String no = items[x].uid
                                                .split('+')[1];
                                            DocumentSnapshot guardianProfile =
                                            await guardian.doc(guardianID).get();
                                            List list1 = new List.from([]);
                                            list1.addAll(List.from(
                                                guardianProfile
                                                    .data()['children status']));
                                            list1[int.parse(no)] = -1;

                                            await guardian
                                                .doc(guardianID)
                                                .update(
                                                {'children status': list1});

                                            kindergartenProfile.feesType
                                                .forEach((key, value) {
                                              int index = value['selected students']
                                                  .indexOf(items[x].uid);
                                              print(key);
                                              print(index);
                                              if(index!=-1) {
                                                value['selected students']
                                                    .removeAt(
                                                    index);
                                                value['selected students fname']
                                                    .removeAt(index);
                                                value['selected students lname']
                                                    .removeAt(index);
                                              }
                                            });
                                            DocumentSnapshot document = await student.doc(items[x].uid).collection('attendance').doc('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}').get();

                                            String status = document.data()['status'];
                                            status=='present'? kindergartenProfile.studentPresent=kindergartenProfile.studentPresent-1:
                                            status=='absent'? kindergartenProfile.studentAbsent=kindergartenProfile.studentAbsent-1:
                                            status=='leave'?kindergartenProfile.studentLeave=kindergartenProfile.studentLeave-1:
                                            kindergartenProfile.studentLate =kindergartenProfile.studentLate-1;

                                            int index = kindergartenProfile.studentUID.indexOf(items[x].uid);
                                            kindergartenProfile.studentLastName
                                                .removeAt(index);
                                            kindergartenProfile.studentFirstName
                                                .removeAt(index);
                                            kindergartenProfile.studentUID
                                                .removeAt(index);
                                            kindergartenProfile.studentAge
                                                .removeAt(index);
                                            await kindergarten
                                                .doc(kindergartenProfile.name)
                                                .update({
                                              'student first name':
                                              kindergartenProfile
                                                  .studentFirstName,
                                              'student last name':
                                              kindergartenProfile.studentLastName,
                                              'student uid': kindergartenProfile
                                                  .studentUID,
                                              'student age': kindergartenProfile
                                                  .studentAge,
                                              'fees type': kindergartenProfile
                                                  .feesType,
                                              'student present':kindergartenProfile.studentPresent,
                                              'student late': kindergartenProfile.studentLate,
                                              'student leave':kindergartenProfile.studentLeave,
                                              'student absent':kindergartenProfile.studentAbsent
                                            });

                                            setState(() {
                                              ageStudents.clear();
                                              items.clear();
                                              allStudents.clear();
                                              ageWidgets.clear();
                                              init();
                                              buildAllAgesWidgets();
                                            });

                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                                msg: 'Student is removed',
                                                fontSize: SizeConfig.smaller,
                                                backgroundColor: ThemeColor
                                                    .themeBlueColor,
                                                textColor: ThemeColor.whiteColor);
                                          } catch (e) {
                                            print(e);
                                          _scaffoldKey.currentState
                                                .showSnackBar(SnackBar(
                                              backgroundColor:
                                              ThemeColor.themeBlueColor
                                                  .withOpacity(0.8),
                                              content: Text(
                                                'Connection failed. Please check your connection',
                                                style: extraSmallTextStyle(
                                                    color: ThemeColor.whiteColor),
                                              ),
                                            ));
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },

                                      ));
                            }
                          ),
                        ),
                      );
                    },
                  ),
                  SizeConfig.mediumVerticalBox
                ],
              ),
            ),
          ),
          bottomNavigationBar: chosens.length > 0
              ? BottomAppBar(
                  elevation: 0.0,
                  color: ThemeColor.lightestBlueGreyColor,
                  child: KiButton.smallButton(
                    onPressed: (){
                      showDialog(context: context,
                          builder: (context) =>
                      ActionAlertDialog(
                          title: 'Delete Students',
                          msg: 'Are you sure to delete ${chosens.length} students from the list?',
                          onPressed:() async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          for(String x in chosens) {
                            String guardianID = x.split('+')[0];
                            String no = x.split('+')[1];
                            DocumentSnapshot guardianProfile =
                            await guardian.doc(guardianID).get();
                            List list1 = new List.from([]);
                            list1.addAll(List.from(
                                guardianProfile
                                    .data()['children status']));
                            list1[int.parse(no)] = -1;
                            await guardian
                                .doc(guardianID)
                                .update(
                                {'children status': list1});
                            kindergartenProfile.feesType
                                .forEach((key, value) {
                              print('a');
                              int index = value['selected students']
                                  .indexOf(x);
                              if(index!=-1) {
                                value['selected students'].removeAt(
                                    index);
                                value['selected students fname']
                                    .removeAt(index);
                                value['selected students lname']
                                    .removeAt(index);
                              }
                            });
                            print('b');
                            DocumentSnapshot document = await student.doc(x).collection('attendance').doc('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}').get();

                            print('c');
                            String status = document.data()['status'];
                            status=='present'? kindergartenProfile.studentPresent=kindergartenProfile.studentPresent-1:
                            status=='absent'? kindergartenProfile.studentAbsent=kindergartenProfile.studentAbsent-1:
                            status=='leave'?kindergartenProfile.studentLeave=kindergartenProfile.studentLeave-1:
                            kindergartenProfile.studentLate =kindergartenProfile.studentLate-1;

                            int index = kindergartenProfile.studentUID.indexOf(x);
                            kindergartenProfile.studentLastName
                                .removeAt(index);
                            kindergartenProfile.studentFirstName
                                .removeAt(index);
                            kindergartenProfile.studentUID
                                .removeAt(index);
                            kindergartenProfile.studentAge
                                .removeAt(index);
                          }

                          print('d');
                          await kindergarten
                              .doc(kindergartenProfile.name)
                              .update({
                            'student first name':
                            kindergartenProfile
                                .studentFirstName,
                            'student last name':
                            kindergartenProfile.studentLastName,
                            'student uid': kindergartenProfile
                                .studentUID,
                            'student age': kindergartenProfile
                                .studentAge,
                            'fees type': kindergartenProfile
                                .feesType,
                            'student present':kindergartenProfile.studentPresent,
                            'student late': kindergartenProfile.studentLate,
                            'student leave':kindergartenProfile.studentLeave,
                            'student absent':kindergartenProfile.studentAbsent
                          });

                          print('e');

                          setState(() {
                            ageStudents.clear();
                            items.clear();
                            allStudents.clear();
                            ageWidgets.clear();
                            chosens.clear();
                            init();
                            buildAllAgesWidgets();
                          });

                          Navigator.pop(context);

                          Fluttertoast.showToast(
                              msg: 'Students are removed',
                              fontSize: SizeConfig.smaller,
                              backgroundColor: ThemeColor
                                  .themeBlueColor,
                              textColor: ThemeColor.whiteColor);
                        } catch (e) {
                          print(e);
                          _scaffoldKey.currentState
                              .showSnackBar(SnackBar(
                            backgroundColor:
                            ThemeColor.themeBlueColor
                                .withOpacity(0.8),
                            content: Text(
                              'Connection failed. Please check your connection',
                              style: extraSmallTextStyle(
                                  color: ThemeColor.whiteColor),
                            ),
                          ));
                        }
                        setState(() {
                          isLoading = false;
                        });
                      }));},
                      child: Container(
                      height: SizeConfig.safeBlockVertical * 6,
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      Text(
                      'Remove ${chosens.length == kindergartenProfile.studentUID.length ? 'All' : chosens.length} Students',
                      style: smalllTextStyle(color: ThemeColor.redColor),
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
    ]);
  }

  void filterSearchResults(String query) {
    List<Student> dummySearchList = new List.from([]);
    dummySearchList
        .addAll(selected == -1 ? allStudents : ageStudents[selected]);
    if (query.isNotEmpty) {
      List<Student> dummyListData = new List.from([]);
      dummySearchList.forEach((item) {
        if (('${item.firstName} ${item.lastName}')
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        } else if (item.age.toString().contains(query)) {
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
        items.addAll(selected == -1 ? allStudents : ageStudents[selected]);
      });
    }
  }
}
