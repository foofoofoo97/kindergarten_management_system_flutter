import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Result.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_results/add_new_result_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:intl/intl.dart';
import 'package:kiki/ui_widgets/info_message_dialog.dart';

class ViewDetailedResultPage extends StatefulWidget {
  NameResult nameResult;
  ViewDetailedResultPage({this.nameResult});

  @override
  _ViewDetailedResultPageState createState() => _ViewDetailedResultPageState();
}

class _ViewDetailedResultPageState extends State<ViewDetailedResultPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  CollectionReference student =
      FirebaseFirestore.instance.collection('student');
  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  int open;
  bool isLoading;

  DateFormat formatter = DateFormat('dd MMM yyy');

  @override
  void initState() {
    // TODO: implement initState
    open = 0;
    isLoading=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: student
            .doc(widget.nameResult.uid)
            .collection('results')
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
          return Stack(
            children: <Widget>[
              Scaffold(
                key: _scaffoldKey,
                appBar: kiAppBar(AppBarType.backButton, context),
                backgroundColor: ThemeColor.whiteColor,
                body: Padding(
                  padding: EdgeInsets.only(left:SizeConfig.small,right: SizeConfig.small,top: SizeConfig.smaller),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizeConfig.smallHorizontalBox,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.nameResult.name,
                                  style: mediumSTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                ),
                                SizeConfig.ultraSmallVerticalBox,
                                Row(
                                    children:<Widget>[
                                      Text(
                                  'View Detailed Results',
                                  style:
                                      smallerTextStyle(color: ThemeColor.blueColor),),
                                      SizeConfig.smallHorizontalBox,
                                      KiButton.smallButton(
                                        child: Icon(Icons.info,color: ThemeColor.blueColor,size: SizeConfig.mediumSmall,),
                                        onPressed: (){
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>InfoMessageDialog(
                                                info: 'Single tap to view result details. \nLong press to update existing results.',
                                              ));
                                        }
                                      )
                                    ])
                              ],
                            ),
                          ),
                          snapshot.data.docs.length == 0
                              ? Container()
                              : KiButton.rectButton(
                                  child: Text(
                                    'New',
                                    style: smallerTextStyle(
                                        color: ThemeColor.whiteColor),
                                  ),
                                  color: ThemeColor.blueColor,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddNewResultPage(
                                                nameResult: widget.nameResult)));
                                  }),
                          SizeConfig.smallHorizontalBox
                        ],
                      ),
                      SizeConfig.mediumVerticalBox,
                      snapshot.data.docs.length == 0
                          ? Expanded(
                              // height: SizeConfig.safeBlockVertical * 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'No Result Is Added Yet',
                                    style:
                                        smallTextStyle(color: ThemeColor.blueColor),
                                  ),
                                  SizeConfig.smallVerticalBox,
                                  KiButton.rectButton(
                                      child: Text(
                                        'New',
                                        style: smallerTextStyle(
                                            color: ThemeColor.whiteColor),
                                      ),
                                      color: ThemeColor.blueColor,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddNewResultPage(
                                                        nameResult:
                                                            widget.nameResult)));
                                      }),
                                      SizeConfig.extraLargeVerticalBox,
                                  SizeConfig.extraLargeVerticalBox
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, x) {
                                    return Card(
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        color: ThemeColor.whiteColor,
                                        child: ListTile(
                                          dense: true,
                                          contentPadding:
                                              EdgeInsets.all(SizeConfig.small),
                                          onLongPress: (){
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=> AddNewResultPage(
                                                nameResult: widget.nameResult,
                                                selectedExam: snapshot.data.docs[x].data()['exam name'],
                                              )
                                            ));
                                          },
                                          trailing: KiButton.smallButton(
                                              child: Icon(
                                                Icons.close,
                                                color: ThemeColor.redColor,
                                                size: SizeConfig.medium,
                                              ),
                                              onPressed: () async{
                                                try {
                                                  setState(() {
                                                    isLoading=true;
                                                  });
                                                  await student.doc(
                                                      widget.nameResult.uid)
                                                      .collection('results').doc(
                                                      snapshot.data.docs[x].id)
                                                      .delete();
                                                  QuerySnapshot ranks = await student.doc(widget.nameResult.uid).collection('results').orderBy('examEndDate',descending: true).limit(1).get();
                                                  if(ranks.docs.length>0) {
                                                    await student.doc(
                                                        widget.nameResult.uid)
                                                        .update({
                                                      'latest grade': ranks.docs[0]
                                                          .data()['grade result']
                                                    });
                                                  }else{
                                                    await student.doc(
                                                        widget.nameResult.uid)
                                                        .update({
                                                      'latest grade': null
                                                    });
                                                  }
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                    backgroundColor: ThemeColor
                                                        .themeBlueColor
                                                        .withOpacity(0.8),
                                                    content: Text(
                                                      'Selected result is deleted successfully',
                                                      style: extraSmallTextStyle(
                                                          color: ThemeColor.whiteColor),
                                                    ),
                                                  ));
                                                }catch(e){

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
                                                setState(() {
                                                  isLoading=false;
                                                });
                                              }),
                                          onTap: () {
                                            setState(() {
                                              if (open == x)
                                                open = null;
                                              else
                                                open = x;
                                            });
                                          },
                                          title: Wrap(
                                              alignment:
                                                  WrapAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data.docs[x]
                                                      .data()['exam name'].toUpperCase(),
                                                  style: smallerTextStyle(
                                                      color: ThemeColor
                                                          .blackColor).copyWith(
                                                    letterSpacing: 0.2
                                                  ),
                                                ),
                                                Text(
                                                  '${formatter.format(snapshot.data.docs[x].data()['examStartDate'].toDate())} - ${formatter.format((snapshot.data.docs[x].data()['examEndDate'].toDate()))}',
                                                  style: extraSmallTextStyle(
                                                      color:
                                                          ThemeColor.blueGreyColor),
                                                ),
                                              ]),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizeConfig.ultraSmallVerticalBox,
                                              SizeConfig.ultraSmallVerticalBox,
                                              Text(
                                                'Average Marks:  ${snapshot.data.docs[x].data()['averageMarks']}',
                                                style: smallerTextStyle(
                                                    color: ThemeColor.themeBlueColor),
                                              ),
                                              SizeConfig.ultraSmallVerticalBox,
                                              Text(
                                                'Grades:  ${snapshot.data.docs[x].data()['grade result']}',
                                                style: smallerTextStyle(
                                                    color: ThemeColor.themeBlueColor),
                                              ),
                                              SizeConfig.smallVerticalBox,
                                              Column(
                                                children: open == x
                                                    ? getWidgets(Map.from(snapshot
                                                        .data.docs[x]
                                                        .data()['course result']))
                                                    : [],
                                              )
                                            ],
                                          ),
                                        ));
                                  })),
                    ],
                  ),
                ),
              ),
              isLoading?Center(
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
        });
  }

  List<Widget> getWidgets(Map data) {
    List<Widget> temp = new List.from([]);
    for (String key in data.keys) {
      temp.add(Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
          child: Row(
            children: <Widget>[
              Text(
                '$key  ',
                style: smallerTextStyle(color: ThemeColor.themeBlueColor),
              ),
              Text(
                '${data[key]['marks']} ${data[key]['grade']}',
                style: smallerTextStyle(color: ThemeColor.blueColor),
              )
            ],
          )));
    }
    return temp;
  }
}
