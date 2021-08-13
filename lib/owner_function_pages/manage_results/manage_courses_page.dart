import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:kiki/ui_widgets/add_new_course_dialog.dart';

class ManageCoursesPage extends StatefulWidget {
  @override
  _ManageCoursesPageState createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController ageController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController detailsController = new TextEditingController();
  String selected;

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  List<Widget> getAgeButtons() {
    List<Widget> temp = new List.from([]);
    for (String age in kindergartenProfile.studentCourse.keys.toList()) {
      temp.add(Card(
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
              '$age Years Old (${kindergartenProfile.studentCourse[age].length})',
              style: smallerTextStyle(
                  color: selected == age
                      ? ThemeColor.themeBlueColor
                      : ThemeColor.blueGreyColor),
            ),
            onPressed: () {
              setState(() {
                  selected=age;
              });
            },
          ),
        ),
      ));
    }
    return temp;
  }


  @override
  void initState() {
    // TODO: implement initState
    if(kindergartenProfile.studentCourse.keys.length>0) {
      selected = kindergartenProfile.studentCourse.keys.toList()[0] ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KiPage(
      scaffoldKey: _scaffoldKey,
      color: ThemeColor.whiteColor,
      appBarType: AppBarType.backButton,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text('Current Courses',
                  style:
                      mediumSmallTextStyle(color: ThemeColor.themeBlueColor)),
            ]),
            SizeConfig.smallVerticalBox,
            Wrap(
              alignment: WrapAlignment.center,
              spacing: SizeConfig.small,
              runSpacing: SizeConfig.ultraSmall,
              children: getAgeButtons(),
            ),
            kindergartenProfile.studentCourse.keys.length == 0
                ? Container(
                    height: SizeConfig.blockSizeVertical * 60,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'No course is added yet',
                            style:
                                smallTextStyle(color: ThemeColor.blueGreyColor),
                          ),
                          SizeConfig.mediumVerticalBox,
                          KiButton.rectButton(
                              child: Text(
                                'Add',
                                style: smallerTextStyle(
                                    color: ThemeColor.themeBlueColor),
                              ),
                              color: ThemeColor.lightBlueColor,
                              onPressed: () {
                                callAddDialog(0,null);
                              })
                        ]),
                  )
                : Column(
                children:<Widget>[
                  SizeConfig.ultraSmallVerticalBox,
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      KiButton.rectButton(
                          child: Text(
                            'Add',
                            style: smallerTextStyle(
                                color: ThemeColor.themeBlueColor),
                          ),
                          color: ThemeColor.lightBlueColor,
                          onPressed: () {
                            callAddDialog(0,null);
                          })
                    ]
                  ),
                //KIUPDATE: ADD SEARCH BAR
                !kindergartenProfile.studentCourse.containsKey(selected)||kindergartenProfile.studentCourse[selected].length==0?
                Container(
                  height: SizeConfig.blockSizeVertical * 60,
                  child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'No course is added yet',
                          style:
                          smallTextStyle(color: ThemeColor.blueGreyColor),
                        ),
                      ]),
                ):ListView.builder(
                    itemCount: kindergartenProfile.studentCourse[selected].length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context,x){
                      return Card(
                        color: ThemeColor.whiteColor,
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          dense: true,
                          onTap: (){
                            callAddDialog(1, x);
                          },
                          trailing: KiButton.smallButton(
                            onPressed: ()async{
                              try {
                                String key = kindergartenProfile
                                    .studentCourse[selected].keys.toList()[x];
                                kindergartenProfile.studentCourse[selected]
                                    .remove(key);
                                if(kindergartenProfile.studentCourse[selected].length==0){
                                  kindergartenProfile.studentCourse.remove(selected);
                                }
                                await kindergarten.doc(kindergartenProfile.name)
                                    .update({
                                  'student course': kindergartenProfile
                                      .studentCourse
                                });

                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  backgroundColor: ThemeColor
                                      .themeBlueColor
                                      .withOpacity(0.8), content: Text(
                                  'Selected course is deleted successfully',
                                  style: extraSmallTextStyle(
                                      color: ThemeColor
                                          .whiteColor),
                                ),
                                ));
                              }catch(e){
                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  backgroundColor: ThemeColor
                                      .themeBlueColor
                                      .withOpacity(0.8), content: Text(
                                  'Connection failed. Course cannot be deleted',
                                  style: extraSmallTextStyle(
                                      color: ThemeColor
                                          .whiteColor),
                                ),
                                ));
                              }
                            },
                            child: Icon(Icons.close,color: ThemeColor.redColor,size: SizeConfig.medium,)
                          ),
                          contentPadding: EdgeInsets.all(SizeConfig.small),
                          title: Row(
                            children: <Widget>[
                              Text(kindergartenProfile.studentCourse[selected].keys.toList()[x],style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                              SizeConfig.mediumHorizontalBox,
                              Text('($selected Years Old)',style: extraSmallTextStyle(color: ThemeColor.blueColor),)
                            ]),subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children:<Widget>[
                            SizeConfig.ultraSmallVerticalBox,
                            Text(kindergartenProfile.studentCourse[selected].values.toList()[x],style: smallerTextStyle(color: ThemeColor.blueGreyColor),),
                        ]))
                      );
                    }
                )
            ]),
          ],
        ),
      ),
    );
  }

  void callAddDialog(int type,int index){
    String tempAge;
    String tempName;
    if(type==0) {
      nameController.clear();
      ageController.clear();
      detailsController.clear();
    }
    else{
      tempAge=selected;
      tempName =kindergartenProfile.studentCourse[selected].keys.toList()[index];
      nameController.text=tempName;
      ageController.text =selected;
      detailsController.text = kindergartenProfile.studentCourse[selected].values.toList()[index];
    }
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AddNewCourseDialog(
              type:type,
              ageController: ageController,
              nameController: nameController,
              detailsController: detailsController,
              onPressed: () async {
                try {
                  String age = ageController.text.toString();
                  String name =nameController.text.toString();
                  String details = detailsController.text.toString()??'';
                  Map course = new Map();
                  if(type==1){
                    print(tempAge);
                    print(tempName);
                    kindergartenProfile.studentCourse[tempAge].remove(tempName);
                  }

                  if(kindergartenProfile.studentCourse.containsKey(age)){
                    course = kindergartenProfile.studentCourse[age];
                    course.putIfAbsent(name, () => details);
                    kindergartenProfile.studentCourse[age]=course;
                  }

                  else{
                    course.putIfAbsent(name, () => details);
                    kindergartenProfile.studentCourse.putIfAbsent(age,()=>course);
                  }
                  await kindergarten.doc(kindergartenProfile.name).update({
                    'student course': kindergartenProfile.studentCourse
                  });

                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: 'New course is added', backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.extraSmall);
                }
                catch (e) {
                  _scaffoldKey.currentState
                      .showSnackBar(SnackBar(
                    backgroundColor: ThemeColor
                        .themeBlueColor
                        .withOpacity(0.8), content: Text(
                      'Connection failed. Course cannot be added',
                      style: extraSmallTextStyle(
                          color: ThemeColor
                              .whiteColor),
                    ),
                  ));
                }
              },
            ));
  }
}
