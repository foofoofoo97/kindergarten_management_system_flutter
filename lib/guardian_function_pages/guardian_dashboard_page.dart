import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/chatroom_pages/guardian_search_receiver_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class GuardianDashboardPage extends StatefulWidget {
  @override
  _GuardianDashboardPageState createState() => _GuardianDashboardPageState();
}

class _GuardianDashboardPageState extends State<GuardianDashboardPage> {
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  GuardianProfile guardianProfile = new GuardianProfile();
  List<String> verifiedKindergarten = new List.from([]);
  Map<String,dynamic> verifiedChildren= new Map();

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  void init(){
    for(int x =0;x<guardianProfile.childrenStatus.length;x++){
      if(guardianProfile.childrenStatus[x]==1){
        verifiedKindergarten.add(guardianProfile.childrenKindergarten[x]);
        verifiedChildren.putIfAbsent(guardianProfile.childrenKindergarten[x], () => new List.from([]));
        verifiedChildren[guardianProfile.childrenKindergarten[x]].add('${guardianProfile.childrenFirstName[x]} ${guardianProfile.childrenLastName[x]}');
      }
    }

    verifiedKindergarten =verifiedKindergarten.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return verifiedKindergarten.length==0?
    KiCenterPage(
      color: ThemeColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.medium),
        child: Column(
          children: <Widget>[
            Icon(Icons.verified_user,color: ThemeColor.blueColor,size: SizeConfig.extraLarge*2,),
            SizeConfig.mediumVerticalBox,
            Text('Dashboard View Is Restricted',style: smallTextStyle(color: ThemeColor.blueColor),),
            SizeConfig.mediumVerticalBox,
            Text('No children has been verified by kindergarten as their current students',
              textAlign:TextAlign.center,
              style: smallTextStyle(color: ThemeColor.themeBlueColor),),
            SizeConfig.extraLargeVerticalBox
          ],
        ),
      ),
    ):
    DefaultTabController(
      length: verifiedKindergarten.length,
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
                      tabs: guardianTabs()),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: guardianTabViews(),
        ),
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
                    builder: (context) =>
                        GuardianSearchReceiverPage()));
          },
        ),
      ),
    );
  }

  List<Tab> guardianTabs() {
    List<Tab> list = new List.from([]);
    String name;
    for (int x = 0; x < verifiedKindergarten.length; x++) {
      name='';
      for(String child in verifiedChildren[verifiedKindergarten[x]]){
        name = '$child '+name;
      }
      list.add(
        Tab(
            child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SizeConfig.ultraSmallVerticalBox,
            Text(
              verifiedKindergarten[x],
              style: TextStyle(letterSpacing: 1.2),
            ),
            SizeConfig.ultraSmallVerticalBox,
            Text(
              name,
              style: TextStyle(letterSpacing: 0.9),
            ),
          ],
        )),
      );
    }
    return list;
  }

  List<Widget> guardianTabViews() {
    List<Widget> list = new List.from([]);
    for (int x = 0; x < verifiedKindergarten.length; x++) {
      list.add(guardianTabView(x,verifiedKindergarten));
    }

    return list;
  }

  Widget guardianTabView(int index,List<String> distinctKindergarten) {
    return StreamBuilder<QuerySnapshot>(
        stream: kindergarten.doc(distinctKindergarten[index]).collection('guardian dashboard').orderBy('datetime', descending: true).snapshots(),
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
          return Scaffold(
            backgroundColor: ThemeColor.whiteColor,
            body: Padding(
              padding: EdgeInsets.all(SizeConfig.small),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(distinctKindergarten[index],
                      style: smallTextStyle(
                          color: ThemeColor.themeBlueColor)),
                  Text('Dashboard',
                      style: smallerTextStyle(color: ThemeColor.blueColor)),
                  SizeConfig.smallVerticalBox,
                  snapshot.data.docs.length == 0
                            ? Container(
                            height: SizeConfig.safeBlockVertical * 50,
                            child:Center(
                            child: Text('No Message Yet',
                                style: smallTextStyle(color:ThemeColor.blueGreyColor))))
                            : Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, x) {
                                return Card(
                                    elevation: 10.0,
                                    color: ThemeColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                ),child:ListTile(
                                  dense: true,
                                  onTap: () {
                                    print(x);
                                  },
                                  contentPadding: EdgeInsets.all(
                                      SizeConfig.extraSmall),
                                  title: Text(
                                    snapshot.data.docs[x].data()['title'],
                                    style: smallTextStyle(
                                        color: ThemeColor
                                            .themeBlueColor),
                                  ),
                                  subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:<Widget>[
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          snapshot.data.docs[x].data()['content'],
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blackColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          DateFormat("dd-MM-yyyy H:m").format((snapshot.data.docs[x].data()['datetime']).toDate()),
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        ),
                                      ]),
                                ));
                              }),
                        ),
                ],
              ),
            ),
          );
        });
  }
}
