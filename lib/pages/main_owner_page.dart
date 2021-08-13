import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/chatroom_pages/owner_search_receiver_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/owner_function_pages/bill_collections/send_bill_confirmation_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_attendance/manage_attendance_page.dart';
import 'package:kiki/owner_function_pages/bill_collections/manage_bill_page.dart';
import 'package:kiki/owner_function_pages/manage_employee_accounts/manage_employee_accounts_page.dart';
import 'package:kiki/owner_function_pages/manage_guardian_accounts/manage_guardian_accounts_page.dart';
import 'package:kiki/owner_function_pages/manage_personal_account.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_student_profiles/manage_student_accounts_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_dashboard/manage_dashboard_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_fees/manage_fees_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_posts/manage_posts_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_results/manage_results_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/performance_analysis/manage_student_performance_page.dart';
import 'package:kiki/services/authentication.dart';

class MainOwnerPage extends StatefulWidget {

  VoidCallback logoutCallback;
  VoidCallback switchCallback;
  String uid;
  BaseAuth auth;

  MainOwnerPage({this.uid, this.auth, this.logoutCallback,this.switchCallback});

  @override
  _MainOwnerPageState createState() => _MainOwnerPageState();
}

class _MainOwnerPageState extends State<MainOwnerPage> {
  CollectionReference kindergarten =
  FirebaseFirestore.instance.collection('kindergarten');

  CollectionReference owner =
  FirebaseFirestore.instance.collection('owner');

  OwnerProfile ownerProfile = new OwnerProfile();
  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  DateFormat formatter = DateFormat('dd MMM yyy');
  DateFormat formatter2 = DateFormat('MMM yyy');

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    init();
    super.initState();
  }


  Future<void> init() async {
    DocumentSnapshot userSnapshot = await owner.doc(widget.uid).get();
    Map userData = userSnapshot.data();
    ownerProfile.uid = widget.uid;
    ownerProfile.kindergarten = userData['kindergarten name'];
    ownerProfile.firstName = userData['first name'];
    ownerProfile.lastName = userData['last name'];
    ownerProfile.contactNo = userData['contact no'];

    setState(() {
      isLoading = false;
    });
  }

  void initKindergarten(Map data){
    kindergartenProfile.name = data['name'];
    kindergartenProfile.contactNo = data['contact no'];
    kindergartenProfile.address = data['address'];
    kindergartenProfile.feesType = Map.from(data['fees type']?? new Map());

    kindergartenProfile.employeeUID =
        List.from(data['employee uid']?? new List.from([]));
    kindergartenProfile.ownerUID =
        List.from(data['owner uid']?? new List.from([]));
    kindergartenProfile.employeeFirstName =
        List.from(data['employee first name']?? new List.from([]));
    kindergartenProfile.employeeLastName =
        List.from(data['employee last name']??new List.from([]));
    kindergartenProfile.employeeJobTitle =
        List.from(data['employee job title']??new List.from([]));

    kindergartenProfile.canResults= List.from(data['can results']?? new List.from([]));
    kindergartenProfile.canPerformance= List.from(data['can performance']?? new List.from([]));
    kindergartenProfile.canPosts= List.from(data['can posts']?? new List.from([]));
    kindergartenProfile.canAttendance= List.from(data['can attendance']?? new List.from([]));

    kindergartenProfile.pendingEmployeeUID = List.from(data['pending employee uid']??new List.from([]));
    kindergartenProfile.pendingStudentUID = List.from(data['pending student uid']??new List.from([]));


    kindergartenProfile.studentUID =
        List.from(data['student uid']??[]);
    kindergartenProfile.studentFirstName =
        List.from(data['student first name']??[]);
    kindergartenProfile.studentLastName =
        List.from(data['student last name']??[]);
    kindergartenProfile.studentAge =
        List.from(data['student age']??[]);

    kindergartenProfile.studentCourse = Map.from(data['student course']?? new Map());
    kindergartenProfile.startWorkMinutes = data['start work min'];
    kindergartenProfile.startWorkHours = data['start work hrs'];
    kindergartenProfile.startStudyMinutes = data['start study min'];
    kindergartenProfile.startStudyHours = data['start study hrs'];

    kindergartenProfile.employeeAttendanceCheck = data['employee attendance check']==null? null:data['employee attendance check'];
    kindergartenProfile.studentAttendanceCheck = data['student attendance check']==null? null:data['student attendance check'];

    kindergartenProfile.employeePresent =data['employee present']??0;
    kindergartenProfile.employeeLate = data['employee late']??0;
    kindergartenProfile.employeeLeave = data['employee leave']??0;
    kindergartenProfile.employeeAbsent = data['employee absent']??kindergartenProfile.studentUID.length;

    kindergartenProfile.studentPresent =data['student present']??0;
    kindergartenProfile.studentLate = data['student late']??0;
    kindergartenProfile.studentLeave = data['student leave']??0;
    kindergartenProfile.studentAbsent = data['student absent']??kindergartenProfile.studentUID.length;


    kindergartenProfile.dayToBill = data['date to bill']??1;
    kindergartenProfile.monthToBill =data['month to bill']?? DateTime.now().month;
    kindergartenProfile.isBilled = billSentChecker();
    //Build Notifier
  }

  bool billSentChecker(){
    bool send =true;
    if(kindergartenProfile.monthToBill==DateTime.now().month){
      if(DateTime.now().month==2 && kindergartenProfile.dayToBill>DateTime(DateTime.now().year,3,0).day){
        send=false;
      }
      if(DateTime.now().day>=kindergartenProfile.dayToBill){
        send=false;
      }
    }
    else if(kindergartenProfile.monthToBill<=DateTime.now().month){
      send =false;
    }
    return send;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
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
    )
        : StreamBuilder<DocumentSnapshot>(
        stream: kindergarten.doc(ownerProfile.kindergarten).snapshots(),
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.blueColor)
                  ),
                ),
              ),
            );
          }
          else if(documentSnapshot.hasError){
            Fluttertoast.showToast(msg: 'Failed to connect database',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
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
          else {
            Map data = documentSnapshot.data.data();
            initKindergarten(data);

            return !kindergartenProfile.isBilled && kindergartenProfile.feesType.length>0?
            SendBillConfirmationPage():
            MaterialApp(
                home: DefaultTabController(
                    length: 5,
                    child: Scaffold(
                        appBar: AppBar(
                          backgroundColor: ThemeColor.themeBlueColor,
                          bottom: TabBar(
                            indicatorColor: ThemeColor.accentCyanColor,
                            unselectedLabelColor: ThemeColor.whiteColor,
                            labelColor: ThemeColor.accentCyanColor,
                            labelStyle: TextStyle(fontSize: SizeConfig.extraSmall, fontFamily: 'PatrickHand'),
                            isScrollable: true,
                            tabs: [
                              Tab(
                                child: Text(
                                  'Attendance',
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
                                  'Posts',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Dashboard',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                            ],
                          ),
                          title: largeTitleText(text: 'KIKI Owner',color: ThemeColor.whiteColor),
                        ),
                        body: TabBarView(
                          children: [
                            ManageAttendancePage(),
                            ManageResultsPage(),
                            ManageStudentPerformancePage(
                              roleName: 'Owner',
                              name: '${ownerProfile.firstName} ${ownerProfile.lastName}',
                            ),
                            ManagePostsPage(),
                            ManageDashboardPage(),
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
                                        '${ownerProfile.firstName} ${ownerProfile.lastName}',
                                        style: mediumLargeTextStyle(color: ThemeColor.blueColor)),
                                    SizeConfig.smallVerticalBox
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColor.themeBlueColor,
                                ),
                              ),
                              SizeConfig.largeVerticalBox,
                              Padding(
                                padding:
                                EdgeInsets.only(left: SizeConfig.extraSmall),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text('Fees Management',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context)=>ManageFeesPage(kindergarten: kindergartenProfile.name)
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Bills Collection',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context)=>ManageBillPage(
                                                kindergarten: kindergartenProfile.name,
                                                date: formatter2.format(DateTime.now()))
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Chat Room',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(
                                            builder: (context) =>
                                                OwnerSearchReceiverPage()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Student Profiles',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context)=>ManageStudentAccountsPage()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Employee Accounts',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context)=>ManageEmployeeAccountsPage()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Guardian Accounts',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context)=>ManageGuardianAccountsPage()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Personal Account',
                                          style: smallTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context)=>ManageOwnerPersonalAccount()
                                        ));
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Switch Account',
                                          style: smallTextStyle(
                                              color: ThemeColor.blueColor)),
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