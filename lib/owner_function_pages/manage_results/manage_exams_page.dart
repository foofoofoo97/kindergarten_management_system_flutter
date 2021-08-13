import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_results/add_new_exam_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ManageExamsPage extends StatefulWidget {
  @override
  _ManageExamsPageState createState() => _ManageExamsPageState();
}

class _ManageExamsPageState extends State<ManageExamsPage> {
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  DateFormat formatter = DateFormat('dd MMM yyy');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: kindergarten.doc(kindergartenProfile.name).collection('exams').orderBy('examEndDate', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (!querySnapshot.hasData) {
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
          } else if (querySnapshot.hasError) {
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
          return Scaffold(
            backgroundColor: ThemeColor.whiteColor,
            appBar: kiAppBar(AppBarType.backButton, context),
            body: Padding(
              padding: EdgeInsets.only(left:SizeConfig.small,right: SizeConfig.small,top: SizeConfig.smaller),
              child: Column(
                children: <Widget>[
                  Text(
                    'Manage Exam',
                    style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      KiButton.rectButton(
                          child: Text(
                            'Add',
                            style: extraSmallTextStyle(
                                color: ThemeColor.themeBlueColor),
                          ),
                          color: ThemeColor.lightBlueColor,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddNewExamPage()));
                          })
                    ],
                  ),
                  SizeConfig.extraSmallVerticalBox,
              querySnapshot.data.docs.length==0? Container(
                    height: SizeConfig.safeBlockVertical*80,
                    child:
                        Column(
                          children: <Widget>[
                            Text('No Exam Is Added Yet',style: smallTextStyle(color: ThemeColor.blueGreyColor)),
                            SizeConfig.mediumVerticalBox,
                            KiButton.rectButton(
                                child: Text(
                                  'Add',
                                  style: extraSmallTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                ),
                                color: ThemeColor.lightBlueColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddNewExamPage()));
                                })
                          ],
                        ))
                        :Expanded(child:ListView.builder(
                        itemCount: querySnapshot.data.docs.length,
                        itemBuilder: (context,x){
                          return Card(
                            color: ThemeColor.whiteColor,
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(vertical:SizeConfig.ultraSmall,horizontal: SizeConfig.small),
                              title: Text(querySnapshot.data.docs[x].data()['exam name'],style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                              subtitle: Text('${formatter.format(querySnapshot.data.docs[x].data()['examStartDate'].toDate())} - ${formatter.format(querySnapshot.data.docs[x].data()['examEndDate'].toDate())}',style: smallerTextStyle(color: ThemeColor.blueGreyColor),),
                              trailing: KiButton.smallButton(
                                child: Icon(Icons.close,color: ThemeColor.redColor,size: SizeConfig.medium,),
                                onPressed: ()async{
                                  try {
                                    await kindergarten.doc(
                                        kindergartenProfile.name).collection(
                                        'exams').doc(
                                        querySnapshot.data.docs[x].id).delete();

                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      backgroundColor: ThemeColor
                                          .themeBlueColor
                                          .withOpacity(0.8), content: Text(
                                      'Exam is deleted successfully',
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
                                      'Connection failed. Exam cannot be deleted',
                                      style: extraSmallTextStyle(
                                          color: ThemeColor
                                              .whiteColor),
                                    ),
                                    ));
                                  }
                                }
                              ),
                            ),
                          );
                    }),
                  )
                ],
              ),
            ),
          );
        });
  }
}
