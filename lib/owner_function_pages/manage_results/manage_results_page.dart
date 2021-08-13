import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Result.dart';
import 'package:kiki/owner_function_pages/manage_results/manage_courses_page.dart';
import 'package:kiki/owner_function_pages/manage_results/view_detailed_result_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ManageResultsPage extends StatefulWidget {
  @override
  _ManageResultsPageState createState() => _ManageResultsPageState();
}

class _ManageResultsPageState extends State<ManageResultsPage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  CollectionReference student = FirebaseFirestore.instance.collection('student');
  TextEditingController searchController = new TextEditingController();

  List<NameResult> items = new List.from([]);
  List<NameResult> duplicateCopy = new List.from([]);

  List<Widget> ageWidgets = new List.from([]);
  Map<int, List<NameResult>> ageStudents = new Map();

  int selected;

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    selected=-1;
    init();
    super.initState();
  }

  Future<void> init()async {
    try {
      QuerySnapshot querySnapshot = await student.where('kindergarten', isEqualTo: kindergartenProfile.name).get();
      if (querySnapshot.docs.length > 0) {
        querySnapshot.docs.forEach((doc) {
          for (int x = 0; x < kindergartenProfile.studentUID.length; x++) {
            if (kindergartenProfile.studentUID[x] == doc.id) {
              ageStudents.putIfAbsent(
                  kindergartenProfile.studentAge[x], () => new List.from([]));

              NameResult person = new NameResult();

              person.uid = kindergartenProfile.studentUID[x];
              person.name =
              '${kindergartenProfile.studentFirstName[x]} ${kindergartenProfile
                  .studentLastName[x]}';
              person.result = doc.data()['latest grade'] ?? 'No Result';
              person.age = kindergartenProfile.studentAge[x];

              ageStudents[kindergartenProfile.studentAge[x]].add(person);
              duplicateCopy.add(person);
              break;
            }
          }
        });
        items.addAll(duplicateCopy);

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'Failed to connect database',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
    }
  }

  void buildAllAgesWidgets() {
    ageWidgets.clear();
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
            'All (${duplicateCopy.length})',
            style: smallererTextStyle(
                color: selected == -1
                    ? ThemeColor.themeBlueColor
                    : ThemeColor.blueGreyColor),
          ),
          onPressed: () {
            setState(() {
              selected = -1;
              items.clear();
              items.addAll(duplicateCopy);
            });
          },
        ),
      ),
    ));

    List<int> arranged = ageStudents.keys.toList();
    arranged.sort((a, b) => a.compareTo(b));

    for (int age in arranged) {
      List<NameResult> students = ageStudents[age];
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

    return isLoading?Container(
      color: ThemeColor.whiteColor,
      child: Center(
        child: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            width: SizeConfig.safeBlockVertical * 5,
            child: CircularProgressIndicator(
              backgroundColor: ThemeColor.whiteColor,
            )
        ),
      ),
    ):RefreshIndicator(
      onRefresh: ()async{
        items.clear();
        duplicateCopy.clear();
        selected=-1;
        ageStudents.clear();
        await init();
        setState(() {
          buildAllAgesWidgets();
        });
      },
      child: KiPage(
        color: ThemeColor.whiteColor,
        child: Padding(
          padding: EdgeInsets.only(top:SizeConfig.smaller,left: SizeConfig.small, right: SizeConfig.small),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizeConfig.smallHorizontalBox,
                  Expanded(child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Student Results',
                        style: smallTextStyle(color: ThemeColor.themeBlueColor),
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      Text(
                        'Swipe down to refresh',
                        style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      ),
                    ],
                  )),
                  KiButton.rectButton(
                    // padding: EdgeInsets.all(SizeConfig.extraSmall),
                    color: ThemeColor.blueColor,
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>ManageCoursesPage()
                      ));
                    },
                    child: Text('Courses',style: extraSmallTextStyle(color: ThemeColor.whiteColor),)
                  ),
                  SizeConfig.smallHorizontalBox
                ],
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
                    hintText: 'Search student name, age, result',
                    maxLines: 1,
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                    activeBorderColor: ThemeColor.themeBlueColor,
                    borderColor: ThemeColor.blueGreyColor,
                    radius: 25.0,
                    textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor)),
              ),
              SizeConfig.extraSmallVerticalBox,
              duplicateCopy.length==0?Container(
                height: SizeConfig.safeBlockVertical*50,
                child: Center(
                    child: Text(
                        'No Result Yet',style: smallTextStyle(color: ThemeColor.blueGreyColor))),
              ):ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, x) {
                    return Card(
                        elevation: 12.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          dense: true,
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context)=>ViewDetailedResultPage(
                                nameResult: items[x],
                              )
                            ));
                          },
                          title: Text(
                            '${items[x].name}',
                            style: smallerTextStyle(
                                color: ThemeColor.themeBlueColor),
                          ),
                          subtitle: Wrap(
                            spacing: SizeConfig.ultraSmall,
                            children: <Widget>[
                              Text('${items[x].age} Years Old',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),)
                            ],
                          ),
                          trailing: Text(items[x].result,style: extraSmallTextStyle(color:ThemeColor.blueColor),),
                        ));
                  }),
              SizeConfig.largeVerticalBox
            ],
          ),
        ),
      ),
    );
  }

  void filterSearchResults(String query) {
    List<NameResult> dummySearchList = new List.from([]);
    dummySearchList.addAll(duplicateCopy);
    if(query.isNotEmpty) {
      List<NameResult> dummyListData = new List.from([]);
      for(NameResult item in dummySearchList){
        if((item.name).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        else if('${item.age} years old'.contains(query)){
          dummyListData.add(item);
        }

        else if(item.result.toLowerCase().contains(query.toLowerCase())||
        item.result.replaceAll(new RegExp(r"\s+"), "").toLowerCase().contains(query.toLowerCase())){
          dummyListData.add(item);
        }
      }

      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    }
    else {
      setState(() {
        items.clear();
        items.addAll(duplicateCopy);
      });
    }
  }
}
