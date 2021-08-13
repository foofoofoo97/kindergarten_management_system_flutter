import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/add_dashboard_message_dialog.dart';
import 'package:intl/intl.dart';


class ManageDashboardPage extends StatefulWidget {

  @override
  _ManageDashboardPageState createState() => _ManageDashboardPageState();
}

class _ManageDashboardPageState extends State<ManageDashboardPage> {

  TextEditingController titleController = new TextEditingController();
  TextEditingController subtitleController = new TextEditingController();

  final GlobalKey<ScaffoldState> _employeeKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _guardianKey = new GlobalKey<ScaffoldState>();

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: ThemeColor.whiteColor,
              appBar: new PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight * 0.9),
                child: new Container(
                  color: ThemeColor.themeBlueColor,
                  child: new SafeArea(
                    child: Column(
                      children: <Widget>[
                        new TabBar(
                            indicatorColor: ThemeColor.accentCyanColor,
                            unselectedLabelColor: ThemeColor.whiteColor,
                            labelColor: ThemeColor.accentCyanColor,
                            labelStyle: TextStyle(fontFamily: 'PatrickHand',fontSize: SizeConfig.extraSmall),
                            isScrollable: true,
                            tabs: [
                              Tab(
                                  child: Text(
                                'Guardian Dashboard',
                                style: TextStyle(letterSpacing: 1.2),
                              )),
                              Tab(
                                  child: Text(
                                'Employee Dashboard',
                                style: TextStyle(letterSpacing: 1.2),
                              )),
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: <Widget>[guardianTabBarView(), employeeTabBarView()],
              ),
            ),
          );
  }

  Widget guardianTabBarView() {
     return StreamBuilder<QuerySnapshot>(
        stream: kindergarten.doc(kindergartenProfile.name).collection('guardian dashboard').orderBy('datetime',descending: true).snapshots(),
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
            key: _guardianKey,
            backgroundColor: ThemeColor.whiteColor,
            body: Padding(
              padding: EdgeInsets.all(SizeConfig.small),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Guardian Dashboard',
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
                      KiButton.rectButton(
                          child: Text(
                            'Add Message',
                            style: extraSmallTextStyle(
                                color: ThemeColor.whiteColor),
                          ),
                          color: ThemeColor.blueColor,
                          onPressed: () {
                            titleController = new TextEditingController();
                            subtitleController =
                            new TextEditingController();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    AddDashboardMessageDialog(
                                      titleController: titleController,
                                      subtitleController:
                                      subtitleController,
                                      onPressed: () async {
                                        try {
                                          await kindergarten
                                              .doc(kindergartenProfile.name)
                                              .collection(
                                              'guardian dashboard')
                                              .doc('${DateTime.now()}')
                                              .set({
                                            'datetime': DateTime.now(),
                                            'title': titleController.text
                                                .toString(),
                                            'content': subtitleController.text.toString()
                                          });

                                          Navigator.pop(context);
                                          Fluttertoast.showToast(msg: 'New message added to dashboard', backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.extraSmall);
                                        } catch (e) {
                                          _guardianKey.currentState
                                              .showSnackBar(SnackBar(
                                            backgroundColor: ThemeColor
                                                .themeBlueColor
                                                .withOpacity(0.8),
                                            content: Text(
                                              'Connection failed. Message cannot be added',
                                              style: extraSmallTextStyle(
                                                  color: ThemeColor
                                                      .whiteColor),
                                            ),
                                          ));
                                        }
                                      },
                                    ));
                          }),
                    ],
                  ),
                  SizeConfig.mediumVerticalBox,
                  Expanded(
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
                                DateFormat("dd-MM-yyyy kk:mm").format((querySnapshot.data.docs[x].data()['datetime']).toDate()),
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        ),
                                      ]),
                                  trailing: KiButton.smallButton(
                                      child: Icon(
                                        Icons.close,
                                        color: ThemeColor.redColor,
                                        size: SizeConfig.medium,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await kindergarten
                                              .doc(
                                              '${kindergartenProfile.name}/guardian dashboard/${querySnapshot.data.docs[x].id}')
                                              .delete();

                                          _guardianKey.currentState
                                              .showSnackBar(SnackBar(
                                            backgroundColor:
                                            ThemeColor
                                                .themeBlueColor
                                                .withOpacity(0.8),
                                            content: Text(
                                              'Message is deleted successfully',
                                              style:
                                              extraSmallTextStyle(
                                                  color: ThemeColor
                                                      .whiteColor),
                                            ),
                                          ));
                                        } catch (e) {
                                          _guardianKey.currentState
                                              .showSnackBar(SnackBar(
                                            backgroundColor:
                                            ThemeColor
                                                .themeBlueColor
                                                .withOpacity(0.8),
                                            content: Text(
                                              'Connection failed. Message cannot be deleted',
                                              style:
                                              extraSmallTextStyle(
                                                  color: ThemeColor
                                                      .whiteColor),
                                            ),
                                          ));
                                        }
                                      }),
                                ));
                              }),
                        )),
                ],
              ),
            ),
          );
        });
  }

  Widget employeeTabBarView() {
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
        body: Padding(
          padding: EdgeInsets.all(SizeConfig.small),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  KiButton.rectButton(
                      child: Text(
                        'Add Message',
                        style: extraSmallTextStyle(
                            color: ThemeColor.whiteColor),
                      ),
                      color: ThemeColor.blueColor,
                      onPressed: () {
                        titleController = new TextEditingController();
                        subtitleController =
                        new TextEditingController();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                AddDashboardMessageDialog(
                                  titleController: titleController,
                                  subtitleController:
                                  subtitleController,
                                  onPressed: () async {
                                    try {
                                      await kindergarten
                                          .doc(kindergartenProfile.name)
                                          .collection(
                                          'employee dashboard')
                                          .doc('${DateTime.now()}')
                                          .set({
                                        'datetime': DateTime.now(),
                                        'title': titleController.text
                                            .toString(),
                                        'content': subtitleController
                                            .text
                                            .toString()
                                      });
                                      Navigator.pop(context);
                                      Fluttertoast.showToast(msg: 'New message added to dashboard', backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.extraSmall);
                                    } catch (e) {
                                      _employeeKey.currentState
                                          .showSnackBar(SnackBar(
                                        backgroundColor: ThemeColor
                                            .themeBlueColor
                                            .withOpacity(0.8),
                                        content: Text(
                                          'Connection failed. Message cannot be added',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor
                                                  .whiteColor),
                                        ),
                                      ));
                                    }
                                  },
                                ));
                      }),
                ],
              ),
              SizeConfig.mediumVerticalBox,
              Expanded(
                  child: querySnapshot.data.docs.length == 0
                      ? Center(
                      child: Text(
                         'No Message Yet',style: smallTextStyle(color: ThemeColor.blueGreyColor)))
                      : Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                        // reverse: true,
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
                            trailing: KiButton.smallButton(
                                child: Icon(
                                  Icons.close,
                                  color: ThemeColor.redColor,
                                  size: SizeConfig.medium,
                                ),
                                onPressed: () async {

                                  try {
                                    await kindergarten
                                        .doc(
                                        '${kindergartenProfile
                                            .name}/employee dashboard/${querySnapshot.data.docs[x].id}')
                                        .delete();

                                    _employeeKey.currentState
                                        .showSnackBar(SnackBar(
                                      backgroundColor:
                                      ThemeColor
                                          .themeBlueColor
                                          .withOpacity(0.8),
                                      content: Text(
                                        'Message is deleted successfully',
                                        style:
                                        extraSmallTextStyle(
                                            color: ThemeColor
                                                .whiteColor),
                                      ),
                                    ));
                                  } catch (e) {
                                    _employeeKey.currentState
                                        .showSnackBar(SnackBar(
                                      backgroundColor:
                                      ThemeColor
                                          .themeBlueColor
                                          .withOpacity(0.8),
                                      content: Text(
                                        'Connection failed. Message cannot be deleted',
                                        style:
                                        extraSmallTextStyle(
                                            color: ThemeColor
                                                .whiteColor),
                                      ),
                                    ));
                                  }
                                }),
                          ));
                        }),
                  ))
            ],
          ),
        ),
      );
    });
  }
}
