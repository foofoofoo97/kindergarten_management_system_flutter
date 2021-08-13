import 'package:kiki/contents/size_config.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';

enum AppBarType {
  singleButtonOnTheRight,
  crossButtonTheLeftAndTitle,
  titleBar,
  backButton,
  doubleBackButton,
  titleBarWithButtonOnTheRight,
}

AppBar kiAppBar(AppBarType appBarType,BuildContext context) {
  switch (appBarType) {
    case AppBarType.singleButtonOnTheRight:
      break;
    case AppBarType.crossButtonTheLeftAndTitle:
      break;
    case AppBarType.backButton:
      return AppBar(
        backgroundColor: ThemeColor.whiteColor,
        elevation: 0,
        leading: KiButton.smallButton(
          child: Icon(Icons.arrow_back_ios,color: ThemeColor.blueGreyColor,size: SizeConfig.large,),
          onPressed: (){
            Navigator.pop(context);
          }
        )
      );
    case AppBarType.doubleBackButton:
      return AppBar(
          backgroundColor: ThemeColor.whiteColor,
          elevation: 0,
          leading: KiButton.smallButton(
              child: Icon(Icons.arrow_back_ios,color: ThemeColor.blueGreyColor,size: SizeConfig.large,),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              }
          )
      );
    case AppBarType.titleBar:
      break;
    case AppBarType.titleBarWithButtonOnTheRight:
      break;
    default:
      return null;
  }
}

class KiCenterPage extends StatelessWidget {
  AppBarType appBarType;
  Widget child;
  Color color;
  GlobalKey<ScaffoldState> scaffoldKey;


  KiCenterPage({this.child, this.scaffoldKey, this.appBarType,this.color});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
           key: scaffoldKey,
           backgroundColor:color,
           appBar: kiAppBar(appBarType,context),
           extendBodyBehindAppBar: true,
           extendBody: true,
           body: Center(
             child: SingleChildScrollView(
               child: child
             ),
           ),
    );
  }
}

class KiPage extends StatelessWidget {
  AppBarType appBarType;
  Widget child;
  Color color;
  GlobalKey<ScaffoldState> scaffoldKey;

  KiPage({this.child, this.scaffoldKey, this.appBarType,this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor:color,
      appBar: kiAppBar(appBarType,context),
      body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: child
        ),
    );
  }
}
