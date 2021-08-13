import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Result.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_results/add_new_exam_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_results/manage_courses_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_results/manage_exams_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class AddNewResultPage extends StatefulWidget {
  NameResult nameResult;
  String selectedExam;
  AddNewResultPage({this.nameResult,this.selectedExam});

  @override
  _AddNewResultPageState createState() => _AddNewResultPageState();
}

class _AddNewResultPageState extends State<AddNewResultPage> {
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference student =
      FirebaseFirestore.instance.collection('student');

  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool isLoading;
  bool hasExam;
  List<String> grades = [
    'A (80-100)',
    'A- (70-79)',
    'B+ (65-69)',
    'B (60-64)',
    'B- (55-59)',
    'C+ (50-54)',
    'C (45-49)',
    'C- (40-44)',
    'D (30-39)',
    'F (0-30)',
    'Not Included',
    'Not Attended'
  ];
  Map<String, String> recordToGrade ={
    'A':'A (80-100)',
    'A-':'A- (70-79)',
    'B+':'B+ (65-69)',
    'B':'B (60-64)',
    'B-':'B- (55-59)',
    'C+':'C+ (50-54)',
    'C':'C (45-49)',
    'C-':'C- (40-44)',
    'D':'D (30-39)',
    'F':'F (0-30)',
    'Not Attended':'Not Attended'
  };
  Map<String, String> gradesToRecord = {
    'A (80-100)': 'A',
    'A- (70-79)': 'A-',
    'B+ (65-69)': 'B+',
    'B (60-64)': 'B',
    'B- (55-59)': 'B-',
    'C+ (50-54)': 'C+',
    'C (45-49)': 'C',
    'C- (40-44)': 'C-',
    'D (30-39)': 'D',
    'F (0-30)': 'F',
    'Not Attended': 'Not Attended',
  };

  DateFormat formatter = DateFormat('dd MMM yyy');

  String selectedExam;
  List<String> selectedGrades = new List.from([]);
  Map<String, dynamic> exams = new Map();
  List<TextEditingController> marksEditingControllers = new List.from([]);
  List<bool> noMarksErrors = new List.from([]);

  bool isSubmitting;
  String editId;
  @override
  void initState() {
    // TODO: implement initState
    isLoading = false;
    isSubmitting =false;
    if(widget.selectedExam!=null){
      selectedExam=widget.selectedExam;
      init();
    }

    super.initState();
  }

  Future<void> init()async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot =
        await student
        .doc(widget.nameResult.uid)
        .collection('results')
        .where('exam name',
        isEqualTo: selectedExam)
        .get();
    if(querySnapshot.docs.length>0){

      editId=querySnapshot.docs[0].id;
      Map data = Map.from(querySnapshot.docs[0].data()['course result']);
      int index=0;
      for(String course in kindergartenProfile.studentCourse[widget.nameResult.age.toString()].keys){
        if(data.containsKey(course)){
          selectedGrades[index]=recordToGrade[data[course]['grade']];
          marksEditingControllers[index].text=data[course]['marks'];
        }
        else{
          selectedGrades[index]='Not Included';
        }
        index++;
      }
    }
    else{
      editId=null;
      selectedGrades.clear();
      marksEditingControllers.clear();
      for(int y=0;y<kindergartenProfile.studentCourse[widget.nameResult.age.toString()].length;y++){
        marksEditingControllers.add(new TextEditingController());
        selectedGrades.add(null);
      }
    }
    setState(() {
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: kindergarten
                .doc(kindergartenProfile.name)
                .collection('exams')
                .orderBy('examEndDate', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container(
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
                  ),
                );
              } else if (snapshot.hasError) {
                Fluttertoast.showToast(
                    msg: 'Failed to connect database',
                    backgroundColor: ThemeColor.themeBlueColor,
                    textColor: ThemeColor.whiteColor,
                    fontSize: SizeConfig.smaller);
                return Container(
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
                  ),
                );
              }

              selectedGrades.length = kindergartenProfile.studentCourse[widget.nameResult.age.toString()].length;
              for(int x=0;x<kindergartenProfile.studentCourse[widget.nameResult.age.toString()].length;x++){
                marksEditingControllers.add(new TextEditingController());
                noMarksErrors.add(true);
              }
              exams.clear();

              return KiPage(
                  appBarType: AppBarType.backButton,
                  color: ThemeColor.whiteColor,
                  scaffoldKey: _scaffoldKey,
                  child: Padding(
                      padding: EdgeInsets.all(SizeConfig.small),
                      child: Column(children: <Widget>[
                        Text(
                          widget.selectedExam==null?'New Result': 'Update Result',
                          style: mediumSmallTextStyle(
                              color: ThemeColor.themeBlueColor),
                        ),
                        snapshot.data.docs.length == 0
                            ? Container(
                                height: SizeConfig.safeBlockVertical * 60,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'No Exam Is Added Yet',
                                        style: smallTextStyle(
                                            color: ThemeColor.blueColor),
                                      ),
                                      SizeConfig.mediumVerticalBox,
                                      KiButton.rectButton(
                                          child: Text(
                                            'Add Exam',
                                            style: extraSmallTextStyle(
                                                color: ThemeColor.whiteColor),
                                          ),
                                          color: ThemeColor.blueColor,
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddNewExamPage()));
                                          })
                                    ],
                                  ),
                                ),
                              )
                            : kindergartenProfile
                                        .studentCourse[
                                            widget.nameResult.age.toString()]
                                        .length ==
                                    0
                                ? Container(
                                    height: SizeConfig.safeBlockVertical * 60,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'No Course Is Added Yet',
                                            style: smallTextStyle(
                                                color: ThemeColor.blueColor),
                                          ),
                                          SizeConfig.mediumVerticalBox,
                                          KiButton.rectButton(
                                              child: Text(
                                                'Manage Course',
                                                style: extraSmallTextStyle(
                                                    color: ThemeColor.whiteColor),
                                              ),
                                              color: ThemeColor.blueColor,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ManageCoursesPage()));
                                              })
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(children: <Widget>[
                                    SizeConfig.mediumVerticalBox,
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          KiButton.smallButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ManageExamsPage()));
                                              },
                                              child: Text(
                                                'Manage Exam List',
                                                style: smallerTextStyle(
                                                    color: ThemeColor.blueColor),
                                              ))
                                        ]),
                                    SizeConfig.smallVerticalBox,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: SizeConfig.safeBlockVertical,
                                          horizontal: SizeConfig.smaller),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color: ThemeColor.themeBlueColor,
                                              width: 1.0)),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Exam Name',
                                              style: smallerTextStyle(
                                                  color: ThemeColor.themeBlueColor),
                                            ),
                                            DropdownButton<String>(
                                              isExpanded: true,
                                              hint: Text(
                                                "Select exam type for the result",
                                                style: smallerTextStyle(
                                                    color:
                                                        ThemeColor.blueGreyColor),
                                              ),
                                              underline: Container(),
                                              value: selectedExam,
                                              onChanged: (String value) async {
                                                setState(() {
                                                  isLoading = true;
                                                  selectedExam = value;
                                                });
                                                QuerySnapshot querySnapshot =
                                                    await student
                                                        .doc(widget.nameResult.uid)
                                                        .collection('results')
                                                        .where('exam name',
                                                            isEqualTo: selectedExam)
                                                        .get();
                                                if(querySnapshot.docs.length>0){

                                                  editId=querySnapshot.docs[0].id;
                                                  Map data = Map.from(querySnapshot.docs[0].data()['course result']);
                                                  int index=0;
                                                  for(String course in kindergartenProfile.studentCourse[widget.nameResult.age.toString()].keys){
                                                    if(data.containsKey(course)){
                                                      selectedGrades[index]=recordToGrade[data[course]['grade']];
                                                      marksEditingControllers[index].text=data[course]['marks'];
                                                    }
                                                    else{
                                                      selectedGrades[index]='Not Included';
                                                    }
                                                    index++;
                                                  }
                                                }
                                                else{
                                                  editId=null;
                                                  selectedGrades.clear();
                                                  marksEditingControllers.clear();
                                                  for(int y=0;y<kindergartenProfile.studentCourse[widget.nameResult.age.toString()].length;y++){
                                                    marksEditingControllers.add(new TextEditingController());
                                                    selectedGrades.add(null);
                                                  }
                                                }
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },
                                              items: snapshot.data.docs
                                                  .map((DocumentSnapshot school) {
                                                exams.putIfAbsent(
                                                    school.data()['exam name'],
                                                    () => {
                                                          'examStartDate': school
                                                              .data()[
                                                                  'examStartDate']
                                                              .toDate(),
                                                          'examEndDate': school
                                                              .data()['examEndDate']
                                                              .toDate()
                                                        });
                                                return DropdownMenuItem<String>(
                                                    value:
                                                        school.data()['exam name'],
                                                    child: Wrap(
                                                        direction: Axis.vertical,
                                                        children: <Widget>[
                                                          Text(
                                                              school.data()[
                                                                  'exam name'],
                                                              style: smallerTextStyle(
                                                                  color: ThemeColor
                                                                      .themeBlueColor)),
                                                          SizeConfig
                                                              .ultraSmallVerticalBox,
                                                          Text(
                                                            '${formatter.format(school.data()['examStartDate'].toDate())} - ${formatter.format(school.data()['examEndDate'].toDate())}',
                                                            style: smallerTextStyle(
                                                                color: ThemeColor
                                                                    .blueGreyColor),
                                                          )
                                                        ]));
                                              }).toList(),
                                            )
                                          ]),
                                    ),
                                    SizeConfig.smallVerticalBox,
                                    isLoading
                                        ? Container()
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              KiButton.smallButton(
                                                  child: Text(
                                                    'Manage Course List',
                                                    style: smallerTextStyle(
                                                        color:
                                                            ThemeColor.blueColor),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ManageCoursesPage()));
                                                  })
                                            ],
                                          ),
                                    SizeConfig.smallVerticalBox,
                                    isLoading
                                        ? Container(
                                            color: ThemeColor.whiteColor,
                                            child: Center(
                                              child: SizedBox(
                                                height:
                                                    SizeConfig.safeBlockVertical *
                                                        5,
                                                width:
                                                    SizeConfig.safeBlockVertical *
                                                        5,
                                                child: CircularProgressIndicator(
                                                    backgroundColor:
                                                        ThemeColor.whiteColor,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            ThemeColor.blueColor)),
                                              ),
                                            ),
                                          )
                                        : Form(
                                            key: _formKey,
                                            child: Container(
                                              height:
                                                  SizeConfig.safeBlockVertical * 55,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: kindergartenProfile
                                                    .studentCourse[widget
                                                        .nameResult.age
                                                        .toString()]
                                                    .length,
                                                itemBuilder: (context, x) {
                                                  return Column(children: <Widget>[
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: SizeConfig
                                                              .safeBlockVertical,
                                                          horizontal:
                                                              SizeConfig.smaller),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  5.0),
                                                          border: Border.all(
                                                              color: ThemeColor
                                                                  .themeBlueColor,
                                                              width: 1.0)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            kindergartenProfile
                                                                .studentCourse[
                                                                    widget
                                                                        .nameResult
                                                                        .age
                                                                        .toString()]
                                                                .keys
                                                                .toList()[x],
                                                            style: smallerTextStyle(
                                                                color: ThemeColor
                                                                    .themeBlueColor),
                                                          ),
                                                          SizeConfig
                                                              .ultraSmallVerticalBox,
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Expanded(
                                                                  child: KiTextField
                                                                      .borderlessTextFormField(
                                                                textStyle: smallerTextStyle(
                                                                    color: ThemeColor
                                                                        .themeBlueColor),
                                                                errorStyle: extraSmallTextStyle(
                                                                    color: ThemeColor
                                                                        .blueGreyColor),
                                                                labelStyle: smallerTextStyle(
                                                                    color: ThemeColor
                                                                        .themeBlueColor),
                                                                titleText: 'Marks',
                                                                controller:
                                                                    marksEditingControllers[
                                                                        x],
                                                                filled: false,
                                                                onSaved: (value) {
                                                                  noMarksErrors[x] =
                                                                      Validators
                                                                          .numberNotCompulsoryValidator(
                                                                              value);
                                                                },
                                                                noError:
                                                                    noMarksErrors[
                                                                        x],
                                                                textInputType:
                                                                    TextInputType
                                                                        .number,
                                                                maxLines: 1,
                                                                errorText:
                                                                    'Marks must be more than 0',
                                                              )),
                                                              DropdownButton<
                                                                  String>(
                                                                isExpanded: false,
                                                                hint: Text(
                                                                  "Select grade",
                                                                  style: smallerTextStyle(
                                                                      color: ThemeColor
                                                                          .blueGreyColor),
                                                                ),
                                                                underline:
                                                                    Container(),
                                                                value: selectedGrades[x],
                                                                onChanged:
                                                                    (String value) {
                                                                  setState(() {
                                                                    selectedGrades[x] = value;
                                                                  });
                                                                },
                                                                items: grades.map(
                                                                    (String grade) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value: grade,
                                                                    child: Text(
                                                                        grade,
                                                                        style: smallerTextStyle(
                                                                            color: ThemeColor
                                                                                .themeBlueColor)),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizeConfig.smallVerticalBox
                                                  ]);
                                                },
                                              ),
                                            )),
                                    SizeConfig.mediumVerticalBox,
                                    KiButton.rectButton(
                                        color: ThemeColor.blueColor,
                                        child: Text(
                                            widget.selectedExam==null?'Add Result':'Update Result',
                                          style: smallerTextStyle(
                                              color: ThemeColor.whiteColor),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            isSubmitting=true;
                                          });
                                          _formKey.currentState.save();
                                          bool selected = true;
                                          if (selectedExam == null) {
                                            selected = false;
                                          } else {
                                            for (int i = 0;
                                                i <
                                                    kindergartenProfile
                                                        .studentCourse[widget
                                                            .nameResult.age
                                                            .toString()]
                                                        .length;
                                                i++) {
                                              if (selectedGrades[i] == null ||
                                                  !noMarksErrors[i]) {
                                                selected = false;
                                                break;
                                              } else if (selectedGrades[i] !=
                                                      'Not Included' &&
                                                  selectedGrades[i] !=
                                                      'Not Attended' &&
                                                  marksEditingControllers[i]
                                                          .text
                                                          .toString() ==
                                                      '') {
                                                selected = false;
                                                break;
                                              }
                                            }
                                          }
                                          if (selected) {
                                            try {
                                              String latestGrade = '';
                                              Map<String, int> gradeToNo =
                                                  new Map();
                                              Map<String, dynamic> result =
                                                  new Map();
                                              double averageMarks =0;
                                              int noDeductable =0;
                                              for (int no = 0;
                                                  no <
                                                      kindergartenProfile
                                                          .studentCourse[widget
                                                              .nameResult.age
                                                              .toString()]
                                                          .length;
                                                  no++) {
                                                Map<String, String> temp =
                                                    new Map();
                                                if (selectedGrades[no] ==
                                                    'Not Included') {
                                                  continue;
                                                }
                                                if (gradeToNo.containsKey(
                                                    gradesToRecord[
                                                        selectedGrades[no]])) {
                                                  int unk = gradeToNo[
                                                      gradesToRecord[
                                                          selectedGrades[no]]];
                                                  unk = unk + 1;
                                                  gradeToNo[gradesToRecord[
                                                      selectedGrades[no]]] = unk;
                                                } else {
                                                  gradeToNo.putIfAbsent(
                                                      gradesToRecord[
                                                          selectedGrades[no]],
                                                      () => 1);
                                                }
                                                temp.putIfAbsent(
                                                    'grade',
                                                    () => gradesToRecord[
                                                        selectedGrades[no]]);
                                                temp.putIfAbsent(
                                                    'marks',
                                                    () => selectedGrades[no] ==
                                                            'Not Attended'
                                                        ? null
                                                        : marksEditingControllers[
                                                                no]
                                                            .text
                                                            .toString());
                                                if(selectedGrades[no]!='Not Attended'){
                                                  noDeductable=noDeductable+1;
                                                  averageMarks=averageMarks+double.parse(marksEditingControllers[no].text.toString());
                                                }
                                                result.putIfAbsent(
                                                    kindergartenProfile
                                                        .studentCourse[widget
                                                            .nameResult.age
                                                            .toString()]
                                                        .keys
                                                        .toList()[no],
                                                    () => temp);
                                              }
                                              averageMarks=averageMarks/noDeductable;
                                              List<String> gradeKey =
                                              gradeToNo.keys.toSet().toList();
                                              gradeKey.remove('Not Attended');
                                              gradeKey.sort();

                                              for (String key in gradeKey) {
                                                latestGrade = latestGrade +
                                                    ' ${gradeToNo[key]}$key';
                                              }

                                              if(editId==null) {
                                                await student
                                                    .doc(widget.nameResult.uid)
                                                    .collection('results').doc(selectedExam).set({
                                                  'examStartDate': exams[selectedExam]
                                                  ['examStartDate'],
                                                  'examEndDate': exams[selectedExam]
                                                  ['examEndDate'],
                                                  'exam name': selectedExam,
                                                  'course result': result,
                                                  'averageMarks': averageMarks.toStringAsFixed(1),
                                                  'grade result': latestGrade
                                                });
                                              }else{
                                                await student
                                                    .doc(widget.nameResult.uid)
                                                    .collection('results').doc(editId)
                                                    .set({
                                                  'examStartDate': exams[selectedExam]
                                                  ['examStartDate'],
                                                  'examEndDate': exams[selectedExam]
                                                  ['examEndDate'],
                                                  'exam name': selectedExam,
                                                  'course result': result,
                                                  'averageMarks': averageMarks.toStringAsFixed(1),
                                                  'grade result': latestGrade
                                                });
                                              }
                                              QuerySnapshot latestExam = await student.doc(widget.nameResult.uid).collection('results').orderBy('examEndDate',descending: true).limit(1).get();
                                              if((latestExam.docs[0].data()['examEndDate']).toDate().isAtSameMomentAs(exams[selectedExam]['examEndDate'])||exams[selectedExam]['examEndDate'].isAfter(latestExam.docs[0].data()['examEndDate'].toDate())) {

                                                await student
                                                    .doc(widget.nameResult.uid)
                                                    .update({
                                                  'latest grade': latestGrade
                                                });
                                              }
                                              Navigator.pop(context);
                                            } catch (e) {
                                              _scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                backgroundColor: ThemeColor
                                                    .themeBlueColor
                                                    .withOpacity(0.8),
                                                content: Text(
                                                  'Connection failed. Please check your connection',
                                                  style: extraSmallTextStyle(
                                                      color: ThemeColor.whiteColor),
                                                ),
                                              ));
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: 'Fields cannot be empty',
                                                backgroundColor:
                                                    ThemeColor.themeBlueColor,
                                                textColor: ThemeColor.whiteColor,
                                                fontSize: SizeConfig.smaller);
                                          }
                                          setState(() {
                                            isSubmitting=false;
                                          });
                                        })
                                  ])
                      ])));
            }),
        isSubmitting?Center(
          child: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            width: SizeConfig.safeBlockVertical * 5,
            child: CircularProgressIndicator(
              backgroundColor: ThemeColor.whiteColor,
            ),
          ),
        ):Container()
      ],
    );
  }
}
