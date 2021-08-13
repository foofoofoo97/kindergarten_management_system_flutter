import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/owner_function_pages/performance_analysis/add_performance_record_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class ManageStudentPerformancePage extends StatefulWidget {
  String roleName;
  String name;
  ManageStudentPerformancePage({this.roleName, this.name});

  @override
  _ManageStudentPerformancePageState createState() =>
      _ManageStudentPerformancePageState();
}

class _ManageStudentPerformancePageState
    extends State<ManageStudentPerformancePage> {
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference student =
  FirebaseFirestore.instance.collection('student');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  TextEditingController searchController = new TextEditingController();
  Map<int, List<Student>> ageStudents = new Map();

  List<Student> items = new List.from([]);
  int selected;
  List<Student> allStudents = new List.from([]);
  List<Widget> ageWidgets = new List.from([]);

  DateFormat formatter = DateFormat('dd MMM yyy dd:mm');

  bool isLoading;
  int open;

  @override
  void initState() {
    // TODO: implement initState
    open=0;
    isLoading=true;
    selected = -1;
    init();
    super.initState();
  }

  Future<void> init() async{
    QuerySnapshot querySnapshot = await student.where('kindergarten',isEqualTo: kindergartenProfile.name).get();
    for (int index = 0;
        index < kindergartenProfile.studentUID.length;
        index++) {
      ageStudents.putIfAbsent(
          kindergartenProfile.studentAge[index], () => new List.from([]));
      Student temp = new Student();
      temp.uid = kindergartenProfile.studentUID[index];
      temp.firstName = kindergartenProfile.studentFirstName[index];
      temp.lastName = kindergartenProfile.studentLastName[index];
      temp.kindergarten = kindergartenProfile.name[index];
      temp.age = kindergartenProfile.studentAge[index];

      for(int x=0; x<querySnapshot.docs.length;x++){
        if(querySnapshot.docs[x].id==kindergartenProfile.studentUID[index])
          {
            Map data = querySnapshot.docs[x].data();
            temp.performance = Map.from(data['performance']??new Map());
            break;
          }
      }
      ageStudents[kindergartenProfile.studentAge[index]].add(temp);
      allStudents.add(temp);
    }
    items.addAll(allStudents);

    setState(() {
      isLoading=false;
    });
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
              open=0;
              selected = -1;
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
    return isLoading
        ? Container(
      color: ThemeColor.whiteColor,
      child: Center(
        child: SizedBox(
          height: SizeConfig.safeBlockVertical * 5,
          width: SizeConfig.safeBlockVertical * 5,
          child: CircularProgressIndicator(
              backgroundColor: ThemeColor.whiteColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeColor.blueColor)
          ),
        ),
      ),
    ):RefreshIndicator(
      onRefresh: () async {
        open=0;
        ageStudents.clear();
        items.clear();
        allStudents.clear();
        ageWidgets.clear();
        await init();
        setState(() {
          buildAllAgesWidgets();
        });
      },
      child: Scaffold(
        backgroundColor: ThemeColor.whiteColor,
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.small,
                right: SizeConfig.small,
                top: SizeConfig.smaller),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Student Performance Analysis Tool',
                  style: smalllTextStyle(color: ThemeColor.themeBlueColor),
                ),
                SizeConfig.ultraSmallVerticalBox,
                Text(
                  'Swipe down to refresh',
                  style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                ),
                SizeConfig.extraSmallVerticalBox,
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
                        setState(() {
                          open=0;
                        });
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
                allStudents.length == 0
                    ? Container(
                        height: SizeConfig.safeBlockVertical * 50,
                        child: Center(
                            child: Text('No Record Yet',
                                style: smallTextStyle(
                                    color: ThemeColor.blueGreyColor))),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, x) {
                          return Card(
                            color: ThemeColor.whiteColor,
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.all(SizeConfig.safeBlockVertical),
                                onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddPerformanceRecordPage(
                                              student: items[x],
                                              name: widget.name,
                                              roleName: widget.roleName,
                                            )));
                              },
                              leading: IconButton(
                                icon: Icon(open==x? Icons.expand_less:Icons.expand_more),
                                iconSize: SizeConfig.extraLarge,
                                color: ThemeColor.lightBlueColor2,
                                onPressed: (){
                                  setState(() {
                                    open==x? open=null: open=x;
                                  });
                                },
                              ),
                              trailing: SizedBox(
                                width: SizeConfig.large,
                                height: SizeConfig.large,
                                child: DecoratedBox(
                                  decoration:  BoxDecoration(
                                      color: getColor(items[x].performance['result'])
                                  ),
                                ),
                              ),
                              title: Text(
                                '${items[x].firstName} ${items[x].lastName}',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              subtitle: open==x?Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Text(
                                      '${items[x].age} Years Old',
                                      style: extraSmallTextStyle(
                                          color: ThemeColor.blackColor),
                                    ),
                                SizeConfig.extraSmallVerticalBox,
                               items[x].performance.keys.length!=0? Text(items[x].performance['result'],style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),):Container(),
                                SizeConfig.ultraSmallVerticalBox,
                                Text(
                                  items[x].performance.keys.length==0?
                                     'No record has been made yet':
                                     'Updated by ${items[x].performance['byRole']}, ${items[x].performance['byName']}',
                                  style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                                ),
                                SizeConfig.ultraSmallVerticalBox,
                                items[x].performance.keys.length!=0?Text(
                                 'Updated on ${formatter.format(items[x].performance['datetime'].toDate())}',
                                  style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                                ):SizeConfig.ultraSmallVerticalBox
                              ]):
                              Text(
                                '${items[x].age} Years Old',
                                style: extraSmallTextStyle(
                                    color: ThemeColor.blueGreyColor),
                              )
                            ),
                          );
                        },
                      ),
                SizeConfig.mediumVerticalBox
              ],
            ),
          ),
        ),
      ),
    );
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

  Color getColor(String x){
    switch(x){
      case 'Student is highly suspected having both Attention Deficit and Reading Difficulty (Dsylexia) issues. Please contact school to further discuss regarding your children problem':
        return Colors.red;
      case 'Student is highly suspected having Attention Deficit Problem. Please contact school to further discuss regarding your children problem':
      case 'Student is highly suspected having Reading Difficulty (Dsylexia) problem. Please contact school to further discuss regarding your children problem':
        return Colors.orange;
      case 'Student is considered as healthy through our performance and behaviour analysis tool. For further information please contact with school owner or teachers':
        return Colors.green;
      default:
        return ThemeColor.lightBlueGreyColor;
    }
  }
}
