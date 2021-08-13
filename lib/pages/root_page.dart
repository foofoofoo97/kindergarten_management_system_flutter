import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Owner.dart';
import 'package:kiki/pages/choose_user_type_page.dart';
import 'package:kiki/pages/employee_fill_info_page.dart';
import 'package:kiki/pages/guardian_fill_info_page.dart';
import 'package:kiki/pages/main_employee_page.dart';
import 'package:kiki/pages/main_guardian_page.dart';
import 'package:kiki/pages/main_owner_page.dart';
import 'package:kiki/pages/owner_fill_info_page.dart';
import 'package:kiki/pages/sign_in_sign_up_page.dart';
import 'package:kiki/services/authentication.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

enum AccountType{
  NOT_DETERMINED,
  EMPLOYEE,
  OWNER,
  GUARDIAN,
  NEW_OWNER,
  NEW_GUARDIAN,
  NEW_EMPLOYEE
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  AccountType accountType = AccountType.NOT_DETERMINED;
  CollectionReference owner = FirebaseFirestore.instance.collection('owner');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');
  CollectionReference employee = FirebaseFirestore.instance.collection('employee');
  CollectionReference users = FirebaseFirestore.instance.collection('user');

  Map<String, AccountType> type={
    'NOT_DETERMINED':AccountType.NOT_DETERMINED,
    'EMPLOYEE':AccountType.EMPLOYEE,
    'OWNER':AccountType.OWNER,
    'GUARDIAN':AccountType.GUARDIAN,
    'NEW_OWNER':AccountType.NEW_OWNER,
    'NEW_GUARDIAN':AccountType.NEW_GUARDIAN,
    'NEW_EMPLOYEE':AccountType.NEW_EMPLOYEE
  };
  DocumentSnapshot userSnapshot;

  OwnerProfile ownerProfile = new OwnerProfile();

  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user){
      setState(() {
        if (user != null) {
          _userId = user.uid;
        }
        authStatus = user== null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
        users.doc(_userId).get().then((value) {
          accountType = type[value.data()['type']];
        }) ;
      });
    });
  }


  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void employeeCallback()async{
    await widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
      });
    });
    setState(() {
      authStatus =AuthStatus.NOT_DETERMINED;
    });
    userSnapshot = await employee.doc(_userId).get();
    if(userSnapshot==null||!userSnapshot.exists) {
       users.doc(_userId).set({
        'type': 'NEW_EMPLOYEE'
      });
      setState(() {
        accountType = AccountType.NEW_EMPLOYEE;
        authStatus =AuthStatus.LOGGED_IN;
      });
    }
    else {
       users.doc(_userId).set({
        'type': 'EMPLOYEE'
      });
      setState(() {
        accountType = AccountType.EMPLOYEE;
        authStatus =AuthStatus.LOGGED_IN;
      });
    }
  }

  void switchCallback()async{
    setState(() {
      accountType =AccountType.NOT_DETERMINED;
    });
  }

  void guardianCallback()async{
    await widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
      });
    });
    setState(() {
      authStatus =AuthStatus.NOT_DETERMINED;
    });
    userSnapshot = await guardian.doc(_userId).get();
    if(userSnapshot==null||!userSnapshot.exists) {
       users.doc(_userId).set({
        'type': 'NEW_GUARDIAN'
      });
      setState(() {
        accountType = AccountType.NEW_GUARDIAN;
        authStatus =AuthStatus.LOGGED_IN;
      });
    }
    else {
       users.doc(_userId).set({
        'type': 'GUARDIAN'
      });
      setState(() {
        accountType = AccountType.GUARDIAN;
        authStatus =AuthStatus.LOGGED_IN;
      });
    }
  }

  void ownerCallback()async{
    await widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
      });
    });

    setState(() {
      authStatus =AuthStatus.NOT_DETERMINED;
    });

    userSnapshot = await owner.doc(_userId).get();
      if(userSnapshot==null||!userSnapshot.exists) {
         users.doc(_userId).set({
          'type': 'NEW_OWNER'
        });
        setState(() {
          accountType = AccountType.NEW_OWNER;
          authStatus =AuthStatus.LOGGED_IN;
        });
      }
      else {
         users.doc(_userId).set({
          'type': 'OWNER'
        });
        setState(() {
          accountType = AccountType.OWNER;
          authStatus =AuthStatus.LOGGED_IN;
        });
      }
  }

  Future<void> getOwnerProfile()async{
    userSnapshot = await owner.doc(_userId).get();

  }

  void newOwnerCallback(){
    users.doc(_userId).set({
      'type': 'OWNER'
    });
    setState(() {
      accountType = AccountType.OWNER;
    });
  }
  void newEmployeeCallback(){
    users.doc(_userId).set({
      'type': 'EMPLOYEE'
    });
    setState(() {
      accountType = AccountType.EMPLOYEE;
    });
  }
  void newGuardianCallback(){
    users.doc(_userId).set({
      'type': 'GUARDIAN'
    });

    setState(() {
        accountType = AccountType.GUARDIAN;
      });

  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      accountType =AccountType.NOT_DETERMINED;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Material(
      child: Container(
        color: ThemeColor.whiteColor,
        alignment: Alignment.center,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              CircularProgressIndicator(),
              SizeConfig.largeVerticalBox,
              Text('Is signing in..', style: smallTextStyle(color: ThemeColor.blueColor),)],
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;

      case AuthStatus.NOT_LOGGED_IN:
        return new SignInSignUpPage(
          auth: widget.auth,
          employeeCallback: employeeCallback,
          guardianCallback: guardianCallback,
          ownerCallback: ownerCallback,
        );
        break;

       case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          switch(accountType){
            case AccountType.NOT_DETERMINED:
              return ChooseUserTypePage(
                uid: _userId,
                guardianCallback: guardianCallback,
                ownerCallback: ownerCallback,
                employeeCallback: employeeCallback,
                signOutCallback: logoutCallback,
              );
            case AccountType.NEW_OWNER:
              return new OwnerFillInfoPage(
                uid: _userId,
                showLogout: true,
                logoutCallback: logoutCallback,
                newOwnerCallback: newOwnerCallback,
              );
            case AccountType.OWNER:
              return new MainOwnerPage(
                uid: _userId,
                auth: widget.auth,
                logoutCallback: logoutCallback,
                switchCallback: switchCallback,
              );
            case AccountType.NEW_GUARDIAN:
              return new GuardianFillInfoPage(
                uid: _userId,
                showLogout: true,
                logoutCallback: logoutCallback,
                newGuardianCallback: newGuardianCallback,
              );
            case AccountType.GUARDIAN:
              return new MainGuardianPage(
                uid: _userId,
                auth: widget.auth,
                logoutCallback: logoutCallback,
                switchCallback: switchCallback,
              );
            case AccountType.NEW_EMPLOYEE:
              return new EmployeeFillInfoPage(
                uid: _userId,
                showLogout: true,
                logoutCallback: logoutCallback,
                newEmployeeCallback: newEmployeeCallback,
              );
            case AccountType.EMPLOYEE:
                return new MainEmployeePage(
                  uid: _userId,
                  auth: widget.auth,
                  employeeCallback: employeeCallback,
                  logoutCallback: logoutCallback,
                  switchCallback: switchCallback,
                );
            default:
              return buildWaitingScreen();
          }
        }
        else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}