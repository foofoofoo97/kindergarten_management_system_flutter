import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/chatroom_pages/guardian_search_receiver_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/guardian_function_pages/guardian_dashboard_page.dart';
import 'package:kiki/guardian_function_pages/manage_children_accounts_page.dart';
import 'package:kiki/guardian_function_pages/manage_personal_account.dart';
import 'package:kiki/guardian_function_pages/view_performance_page.dart';
import 'package:kiki/guardian_function_pages/view_posts_page.dart';
import 'package:kiki/guardian_function_pages/view_results_page.dart';
import 'package:kiki/guardian_function_pages/view_school_fees_page.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/owner_function_pages/manage_guardian_accounts/manage_guardian_accounts_page.dart';
import 'package:kiki/services/authentication.dart';

class MainGuardianPage extends StatefulWidget {
  VoidCallback logoutCallback;
  VoidCallback switchCallback;
  String uid;
  BaseAuth auth;

  MainGuardianPage({this.uid, this.auth, this.logoutCallback,this.switchCallback});

  @override
  _MainGuardianPageState createState() => _MainGuardianPageState();
}

class _MainGuardianPageState extends State<MainGuardianPage> {
  CollectionReference guardian =
      FirebaseFirestore.instance.collection('guardian');

  GuardianProfile guardianProfile = new GuardianProfile();

  Future<void> init(Map userData) async {
    guardianProfile.uid =widget.uid;
    guardianProfile.homeAddress = userData['home address'];
    guardianProfile.firstName = userData['first name'];
    guardianProfile.lastName = userData['last name'];
    guardianProfile.contactNo = userData['contact no'];
    guardianProfile.childrenFirstName =
        List.from(userData['children first name']);
    guardianProfile.childrenLastName =
        List.from(userData['children last name']);
    guardianProfile.childrenAge = List.from(userData['children age']);
    guardianProfile.childrenKindergarten =
        List.from(userData['children kindergarten']);
    guardianProfile.noOfChildren = userData['no of children'];
    guardianProfile.childrenUID = List.from(userData['children uid']);
    guardianProfile.childrenStatus = List.from(userData['children status']??new List.from([]));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: guardian.doc(widget.uid).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
          if (!documentSnapshot.hasData) {
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
          } else if (documentSnapshot.hasError) {
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
          } else {
            Map data = documentSnapshot.data.data();
            init(data);
            return MaterialApp(
                home: DefaultTabController(
                    length: 5,
                    child: Scaffold(
                        appBar: AppBar(
                          backgroundColor: ThemeColor.themeBlueColor,
                          bottom: TabBar(
                            indicatorColor: ThemeColor.accentCyanColor,
                            unselectedLabelColor: ThemeColor.whiteColor,
                            labelColor: ThemeColor.accentCyanColor,
                            labelStyle: TextStyle(fontFamily: 'PatrickHand',fontSize: SizeConfig.extraSmall),
                            isScrollable: true,
                            tabs: [
                              Tab(
                                child: Text(
                                  'Dashboard',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Posts',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Results',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Performance',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'School Fees',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                            ],
                          ),
                          title: largeTitleText(text: 'KIKI Guardian',color: ThemeColor.whiteColor),
                        ),
                        body: TabBarView(
                          children: [
                            GuardianDashboardPage(),
                            ViewPostsPage(),
                            ViewResultsPage(),
                            ViewPerformancePage(),
                            ViewSchoolFeesPage(),
                          ],
                        ),
                        drawer: Drawer(
                          child: ListView(
                            // Important: Remove any padding from the ListView.
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              DrawerHeader(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Icon(
                                        Icons.person,
                                        color: ThemeColor.whiteColor,
                                        size: SizeConfig.safeBlockVertical * 6,
                                      ),
                                      backgroundColor: ThemeColor.blueColor,
                                      radius: SizeConfig.safeBlockVertical * 4,
                                    ),
                                    SizeConfig.mediumVerticalBox,
                                    Text(
                                        '${guardianProfile.firstName} ${guardianProfile.lastName}',
                                        style: mediumLargeTextStyle(
                                            color: ThemeColor.blueColor)),
                                    SizeConfig.smallVerticalBox
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColor.themeBlueColor,
                                ),
                              ),
                              SizeConfig.largeVerticalBox,
                              Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.extraSmall),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text('Chat Room',
                                          style: smallTextStyle(
                                              color:
                                                  ThemeColor.themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GuardianSearchReceiverPage()));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Personal Account',
                                          style: smallTextStyle(
                                              color:
                                                  ThemeColor.themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context)=>GuardianManagePersonalAccount()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Children Profiles',
                                          style: smallTextStyle(
                                              color:
                                              ThemeColor.themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context)=>GuardianManageChildrenAccountsPage()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Switch Account',
                                          style: smallTextStyle(
                                              color:
                                              ThemeColor.blueColor)),
                                      onTap: () {
                                        widget.switchCallback();
                                      },
                                    ),

                                    ListTile(
                                      title: Text('Sign Out',
                                          style: smallTextStyle(
                                              color: ThemeColor.redColor)),
                                      onTap: () {
                                        widget.logoutCallback();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))));
          }
        });
  }
}
