import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/employee_search_receiver_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Employee.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:intl/intl.dart';

class EmployeeDashboardPage extends StatefulWidget {

  @override
  _EmployeeDashboardPageState createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {

  final GlobalKey<ScaffoldState> _employeeKey = new GlobalKey<ScaffoldState>();
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  EmployeeProfile employeeProfile = new EmployeeProfile();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  //KIUPDATE: STREAMBUILDER

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: kindergarten.doc(kindergartenProfile.name).collection('employee dashboard').orderBy('datetime',descending: true).snapshots(),
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.blueColor)
                  ),
                ),
              ),
            );
          }
          else if (querySnapshot.hasError) {
            Fluttertoast.showToast(msg: 'Failed to connect database',
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.blueColor)
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            key: _employeeKey,
            backgroundColor: ThemeColor.whiteColor,
            floatingActionButton: FloatingActionButton(
              heroTag: "chat float",
              child: Icon(
                Icons.chat,
                color: ThemeColor.whiteColor,
              ),
              backgroundColor: ThemeColor.themeBlueColor,
              elevation: 15.0,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmployeeSearchReceiverPage()));
              },
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Employee Dashboard',
                                style: smallTextStyle(
                                    color: ThemeColor.themeBlueColor)),
                            SizeConfig.ultraSmallVerticalBox,
                            Text(
                              'Manage Dashboard',
                              style: smallerTextStyle(
                                  color: ThemeColor.blueColor),
                            ),
                          ],
                        ),
                    SizeConfig.mediumVerticalBox,
                    Container(
                        height: SizeConfig.safeBlockVertical * 60,
                        child: querySnapshot.data.docs.length == 0
                            ? Center(
                            child: Text('No Message Yet',
                                style: smallTextStyle(
                                    color: ThemeColor.blueGreyColor)))
                            : Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                              itemCount: querySnapshot.data.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, x) {
                                return Card(
                                    elevation: 10.0,
                                    color: ThemeColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child:ListTile(
                                      onTap: () {
                                        print(x);
                                      },
                                      contentPadding: EdgeInsets.all(
                                          SizeConfig.extraSmall),
                                      title: Text(
                                        querySnapshot.data.docs[x].data()['title'],
                                        style: smallTextStyle(
                                            color: ThemeColor
                                                .themeBlueColor),
                                      ),
                                      subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:<Widget>[
                                            SizeConfig.ultraSmallVerticalBox,
                                            Text(
                                              querySnapshot.data.docs[x].data()['content'],
                                              style: extraSmallTextStyle(
                                                  color: ThemeColor.blackColor),
                                            ),
                                            SizeConfig.ultraSmallVerticalBox,
                                            Text(
                                              DateFormat("dd-MM-yyyy H:m").format((querySnapshot.data.docs[x].data()['datetime']).toDate()),
                                              style: extraSmallTextStyle(
                                                  color: ThemeColor.blueGreyColor),
                                            ),
                                          ]),
                                    ));
                              }),
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
