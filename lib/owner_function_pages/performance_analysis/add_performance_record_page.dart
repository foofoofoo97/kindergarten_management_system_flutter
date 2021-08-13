import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/performance.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Student.dart';
import 'package:kiki/owner_function_pages/performance_analysis/add_performance_record_2_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:kiki/ui_widgets/rating_widget.dart';

class AddPerformanceRecordPage extends StatefulWidget {
  Student student;
  String roleName;
  String name;

  AddPerformanceRecordPage({this.roleName,this.name,this.student});

  @override
  _AddPerformanceRecordPageState createState() => _AddPerformanceRecordPageState();
}

class _AddPerformanceRecordPageState extends State<AddPerformanceRecordPage> {

  List answer = new List.from([]);
  CollectionReference student = FirebaseFirestore.instance.collection('student');

  @override
  void initState() {
    // TODO: implement initState
    if(widget.student.performance.keys.length==0) {
      for (int x = 0; x < addQuestions.length; x++) {
        answer.add(0);
      }
    }
    else{
      answer =widget.student.performance['partA'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KiPage(
      appBarType: AppBarType.backButton,
      color: ThemeColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.only(left:SizeConfig.small,right: SizeConfig.small,top: SizeConfig.ultraSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Update ',style: smallTextStyle(color: ThemeColor.themeBlueColor),),
                Text('${widget.student.firstName} ${widget.student.lastName} ',style: smallTextStyle(color: ThemeColor.blueColor),),
                Text('Performance Record',style: smallTextStyle(color: ThemeColor.themeBlueColor),)
              ],
            ),
            SizeConfig.smallVerticalBox,
            Text('Part A : Student Attention In School',style: smallerTextStyle(color: ThemeColor.blueGreyColor),),
            SizeConfig.extraSmallVerticalBox,
            Card(
              color: ThemeColor.whiteColor,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(SizeConfig.smaller),
                child: Wrap(
                  spacing: SizeConfig.extraSmall,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text('1',style: smallerTextStyle(color: ThemeColor.blackColor),),
                        Text('Never',style: smallerTextStyle(color: ThemeColor.blackColor),)
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text('2',style: smallerTextStyle(color: ThemeColor.blackColor),),
                        Text('Rarely',style: smallerTextStyle(color: ThemeColor.blackColor),)
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text('3',style: smallerTextStyle(color: ThemeColor.blackColor),),
                        Text('Sometimes',style: smallerTextStyle(color: ThemeColor.blackColor),)
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text('4',style: smallerTextStyle(color: ThemeColor.blackColor),),
                        Text('Often',style: smallerTextStyle(color: ThemeColor.blackColor),)
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text('5',style: smallerTextStyle(color: ThemeColor.blackColor),),
                        Text('Very Often',style: smallerTextStyle(color: ThemeColor.blackColor),)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizeConfig.extraSmallVerticalBox,
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: addQuestions.length,
                  itemBuilder: (context, x){
                    return Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.safeBlockVertical,
                              horizontal: SizeConfig.extraSmall),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                  color: ThemeColor.themeBlueColor, width: 1.0)),
                          child: ListTile(
                            dense: true,
                            title: Text(addQuestions[x],style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                            leading: Text((x+1).toString(),style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                            subtitle: RatingWidget(
                              value: answer[x],
                              onPressed: (value){
                                setState(() {
                                  answer[x]=value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizeConfig.extraSmallVerticalBox
                      ],
                    );
                  }),
            SizeConfig.smallVerticalBox,
            Center(
              child: KiButton.rectButton(
                  color: ThemeColor.blueColor,
                  child: Text('Next',style: smallTextStyle(color: ThemeColor.whiteColor),),
                  onPressed: ()async{
                    bool isError = false;
                    for(int x in answer){
                      if(x==0){
                        isError=true;
                        break;
                      }
                    }
                    if(isError){
                      Fluttertoast.showToast(msg: 'Please finish all questions to next', backgroundColor: ThemeColor.themeBlueColor, fontSize: SizeConfig.smaller, textColor: ThemeColor.whiteColor);
                    }
                    else {
                      Map map = new Map();
                      map = widget.student.performance;
                      if(map.keys.length==0){
                        map.putIfAbsent('datetime', () => Timestamp.fromDate(DateTime.now()));
                        map.putIfAbsent('byRole', () => widget.roleName);
                        map.putIfAbsent('byName', () => widget.name);
                        map.putIfAbsent('partA', () => answer);
                        map.putIfAbsent('partB', () => new List.from([]));
                        map.putIfAbsent('result', () => null);
                        map.putIfAbsent('comment', () => null);
                      }
                      else{
                        map['partA']=answer;
                      }
                      Student temp = widget.student;
                      temp.performance=map;

                      await student.doc(widget.student.uid).update({
                          'performance': map
                        });
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=> AddPerformanceRecord2Page(
                              roleName: widget.roleName,
                              name: widget.name,
                              student: temp)
                      ));
                    }
                  }
              ),
            ),
            SizeConfig.extraSmallVerticalBox
          ],
        ),
      ),
    );
  }
}
