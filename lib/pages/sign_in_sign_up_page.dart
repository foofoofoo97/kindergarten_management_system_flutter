import 'dart:io';

import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/strings.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/pages/forget_password_page.dart';
import 'package:kiki/services/authentication.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SignInSignUpPage extends StatefulWidget {
  BaseAuth auth;
  VoidCallback signInCallback;
  VoidCallback employeeCallback;
  VoidCallback ownerCallback;
  VoidCallback guardianCallback;
  SignInSignUpPage({this.auth, this.employeeCallback, this.ownerCallback, this.guardianCallback, this.signInCallback});

  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {

  bool noEmailError;
  bool noPasswordError;
  TextEditingController emailController;
  TextEditingController passwordController;
  bool obscureText;
  String accountType;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> accountTypes =['owner', 'employee', 'guardian'];



  @override
  void initState() {
    super.initState();
    noEmailError = true;
    noPasswordError = true;
    obscureText = true;
    accountType='employee';
    emailController = new TextEditingController(text: 'fooziqin@gmail.com');
    passwordController = new TextEditingController(text: '03290329');
  }

  @override
  Widget build(BuildContext context) {
    return KiCenterPage(
      color: ThemeColor.whiteColor,
      scaffoldKey: _scaffoldKey,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.extraLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizeConfig.extraLargeVerticalBox,
            largestTitleText(text: app_name, color: ThemeColor.themeBlueColor),
            SizeConfig.extraSmallVerticalBox,
            Text('Welcome Back',style: smallTextStyle(color: ThemeColor.blueGreyColor),),
            SizeConfig.extraLargeVerticalBox,
            SizeConfig.smallVerticalBox,
            ToggleSwitch(
              minWidth: SizeConfig.safeBlockHorizontal*27,
              minHeight: SizeConfig.safeBlockVertical*5,
              fontSize: SizeConfig.smaller*0.9,
              initialLabelIndex: 1,
              activeBgColor: ThemeColor.themeBlueColor,
              activeFgColor: ThemeColor.whiteColor,
              inactiveBgColor: ThemeColor.blueGreyColor.withOpacity(0.16),
              inactiveFgColor: ThemeColor.blueGreyColor,
              labels: ['OWNER','EMPLOYEE','GUARDIAN'],
              onToggle: (index) {
                accountType = accountTypes.elementAt(index);
              },
            ),
            SizeConfig.mediumVerticalBox,
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  KiTextField.borderlessTextFormField(
                    controller: emailController,
                    titleText: email_cap,
                    hintText: 'Enter email',
                    onSaved: (value){
                      setState(() {
                        noEmailError= Validators.emailValidator(value);
                      });
                      },
                    noError: noEmailError,
                    textStyle: smallerTextStyle(color: ThemeColor.blackColor),
                    errorText: 'Incorrect email format. E.g. abc@kiki.com',
                    errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                    labelStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  ),
                  SizeConfig.mediumVerticalBox,
                  KiTextField.borderlessTextFormField(
                      controller: passwordController,
                      titleText: password_cap,
                      hintText: 'Enter password',
                      onSaved: (value){
                        setState(() {
                          noPasswordError = Validators.passwordValidator(value);
                        });
                      },
                      obscureText: obscureText,
                      noError: noPasswordError,
                      textStyle: smallerTextStyle(color: ThemeColor.blackColor),
                      errorText: 'Password should have at least 6 characters',
                      errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                      labelStyle: smallerTextStyle(color: ThemeColor.blackColor)
                  )
                ],
              ),
            ),
            SizeConfig.largeVerticalBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: KiButton.rectButton(
                        color: ThemeColor.themeBlueColor,
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*2),
                        child: Text(sign_in,
                            style: smallTextStyle(color: ThemeColor.whiteColor)),
                        onPressed: () async {
                          _formKey.currentState.save();
                          if(noEmailError & noPasswordError){
                            bool pass = await widget.auth.signIn(emailController.text.toString(), passwordController.text.toString());
                            if(pass) {
                              if(accountType=='employee')
                                widget.employeeCallback();
                              else if(accountType == 'guardian')
                                widget.guardianCallback();
                              else widget.ownerCallback();
                            }
                            else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  backgroundColor: ThemeColor.blueGreyColor.withOpacity(0.8),
                                  content: Text('Invalid email or password. Please try again',style: smallerTextStyle(color: ThemeColor.whiteColor),),
                                ));
                            }
                          }
                        }
                        )),
                SizeConfig.largeHorizontalBox,
                Expanded(
                    child: KiButton.rectButton(
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*2),
                        color: ThemeColor.themeBlueColor,
                        child: Text(sign_up, style: smallTextStyle(color: ThemeColor.whiteColor)),
                        onPressed: () async {
                          _formKey.currentState.save();
                          if(noEmailError & noPasswordError){
                            bool pass = await widget.auth.signUp(emailController.text.toString(), passwordController.text.toString());
                            if(pass) {
                              if(accountType=='employee')
                                widget.employeeCallback();
                              else if(accountType == 'guardian')
                                widget.guardianCallback();
                              else widget.ownerCallback();
                            }
                            else {
                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    backgroundColor: ThemeColor.blueGreyColor
                                        .withOpacity(0.8),
                                    content: Text(
                                      'Email has been registered. Please try again',
                                      style: smallerTextStyle(
                                          color: ThemeColor.whiteColor),),
                                  ));
                            }
                          }
                        }
                    )),
              ],
            ),
            SizeConfig.mediumVerticalBox,
            KiButton.smallButton(
                child: Text('Forget Password',style: smallTextStyle(color: ThemeColor.themeBlueColor),),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPasswordPage(auth:widget.auth)),
                  );
                }
            ),
            SizeConfig.extraLargeVerticalBox,
            Text(
              '- Sign in with -',
              style: smallTextStyle(color: ThemeColor.blueGreyColor),
              textAlign: TextAlign.center,
            ),
            SizeConfig.mediumVerticalBox,
            KiButton.circleButton(
                child: Image.asset(
                  'assets/google_logo.png',
                  scale: SizeConfig.medium,
                ),
                padding: EdgeInsets.all(SizeConfig.large),
                color: ThemeColor.whiteColor,
                onPressed: () async {
                  bool signed = await widget.auth.signInWithGoogle();
                  if (signed){
                    if(accountType=='employee')
                      widget.employeeCallback();
                    else if(accountType == 'guardian')
                      widget.guardianCallback();
                    else widget.ownerCallback();
                  }
                  else {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor: ThemeColor.blueGreyColor.withOpacity(0.8),
                      content: Text(
                        'Google authentication failed. Please try again later',
                        style: smallerTextStyle(color: ThemeColor.whiteColor),
                      ),
                    ));
                  }
                })
          ],
        ),
      ),
    );
  }
}
