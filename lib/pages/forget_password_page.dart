import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/strings.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/services/authentication.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ForgetPasswordPage extends StatefulWidget {
  BaseAuth auth;
  ForgetPasswordPage({this.auth});
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {

  TextEditingController emailController;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool noEmailError;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noEmailError = true;
    emailController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return KiCenterPage(
      scaffoldKey: _scaffoldKey,
      color: ThemeColor.whiteColor,
      appBarType: AppBarType.backButton,
      child: Column(
        children: <Widget>[
          Text('Reset Password', style: mediumSmallTextStyle(color:ThemeColor.themeBlueColor)),
          SizeConfig.mediumVerticalBox,
          Text('Enter your registered email to change your password', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.extraLarge),
              child: KiTextField.borderlessTextFormField(
                  controller: emailController,
                  titleText: email_cap,
                  hintText: 'Enter email',
                  textStyle: smallerTextStyle(color: ThemeColor.blackColor),
                  onSaved: (value){
                    setState(() {
                      noEmailError = Validators.emailValidator(value);
                    });
                  },
                  noError: noEmailError,
                  errorText: 'Incorrect email format. E.g. abc@kiki.com',
                  errorStyle: extraSmallTextStyle(color: ThemeColor.blueGreyColor),
                  labelStyle: smallerTextStyle(color: ThemeColor.blackColor)
              ),
            ),
          ),
          KiButton.rectButton(
                  color: ThemeColor.themeBlueColor,
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.extraSmall, horizontal: SizeConfig.medium),
                  child: Text('Reset Password', style: smallerTextStyle(color: ThemeColor.whiteColor)),
                  onPressed: () async {
                    _formKey.currentState.save();
                    if(noEmailError){
                      bool pass = await widget.auth.resetPassword(emailController.text.toString());
                      if(pass) {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor: ThemeColor.blueGreyColor
                              .withOpacity(0.8),
                          content: Text(
                            'Reset password link has been sent to your email. \nPlease check your inbox',
                            style: smallerTextStyle(
                                color: ThemeColor.whiteColor),),
                        ));
                      }
                      else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor: ThemeColor.blueGreyColor
                              .withOpacity(0.8),
                          content: Text(
                            'Invalid email. Please try again.',
                            style: smallTextStyle(
                                color: ThemeColor.whiteColor),),
                        ));
                      }
                    }
                  }
              )
       ],),
    );
  }
}
