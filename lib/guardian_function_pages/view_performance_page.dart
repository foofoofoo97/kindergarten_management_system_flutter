import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/performance.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ViewPerformancePage extends StatefulWidget {
  @override
  _ViewPerformancePageState createState() => _ViewPerformancePageState();
}

class _ViewPerformancePageState extends State<ViewPerformancePage> {

  GuardianProfile guardianProfile = new GuardianProfile();
  CollectionReference student = FirebaseFirestore.instance.collection('student');
  List<bool> openA =new List.from([]);
  List<bool> openB =new List.from([]);
  Map<int,String> valueFrequency ={
    1:'Never',
    2:'Rarely',
    3:'Sometimes',
    4:'Often',
    5:'Very Often'
  };
  DateFormat formatter = DateFormat('dd MMM yyy dd:mm');


  @override
  void initState() {
    // TODO: implement initState
    for(int x=0;x<guardianProfile.childrenUID.length;x++){
      openA.add(false);
      openB.add(false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: guardianProfile.childrenUID.length,
      child:Scaffold(
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
                      tabs: performanceTabBar()),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: performanceTabView(),
        ),
      ),
    );
  }

  List<Widget> performanceTabBar(){
    List<Widget> temp=new List.from([]);
    for (int x = 0; x < guardianProfile.childrenFirstName.length; x++) {
      temp.add(
        Tab(
          child:
          Column(mainAxisAlignment: MainAxisAlignment.center,
              children:<Widget>[Text(
                '${guardianProfile.childrenFirstName[x]} ${guardianProfile.childrenLastName[x]}',
                style: TextStyle(letterSpacing: 1.2),
              ),
                SizeConfig.ultraSmallVerticalBox,
                Text(guardianProfile.childrenKindergarten[x],style: TextStyle(letterSpacing: 0.9))
          ]),
        ),
      );
    }
    return temp;
  }

  List<Widget> performanceTabView(){
    List<Widget> temp = new List.from([]);
    for(int index=0;index<guardianProfile.childrenLastName.length;index++){
      temp.add(guardianProfile.childrenStatus[index]!=1?
      KiCenterPage(
        color: ThemeColor.whiteColor,
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.medium),
          child: Column(
            children: <Widget>[
              Icon(Icons.verified_user,color: ThemeColor.blueColor,size: SizeConfig.extraLarge*2,),
              SizeConfig.mediumVerticalBox,
              Text('Analysis Report Are Not Available',
                textAlign: TextAlign.center,
                style: smallTextStyle(color: ThemeColor.blueColor),),
              SizeConfig.mediumVerticalBox,
              Text('${guardianProfile.childrenFirstName[index]} ${guardianProfile.childrenLastName[index]} has not yet verified by kindergarten as their current student',
                textAlign:TextAlign.center,
                style: smallTextStyle(color: ThemeColor.themeBlueColor),),
              SizeConfig.extraLargeVerticalBox
            ],
          ),
        ),
      )
          :StreamBuilder<DocumentSnapshot>(stream: student.doc(guardianProfile.childrenUID[index]).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
              body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(left:SizeConfig.small,right: SizeConfig.small,top: SizeConfig.extraSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${guardianProfile.childrenFirstName[index]} ${guardianProfile.childrenLastName[index]} Performance Report',style: smalllTextStyle(color: ThemeColor.themeBlueColor),),
                      SizeConfig.smallVerticalBox,
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical,
                            horizontal: SizeConfig.extraSmall),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: ThemeColor.lightBlueGreyColor, width: 1.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(snapshot.data.data()['performance']['result'],style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                            SizeConfig.smallVerticalBox,
                            Text('Performance recorded by: ${snapshot.data.data()['performance']['byRole']}, ${snapshot.data.data()['performance']['byName']}',style: smallerTextStyle(color: ThemeColor.blueGreyColor),),
                            SizeConfig.ultraSmallVerticalBox,
                            Text('Performance recorded on: ${formatter.format(snapshot.data.data()['performance']['datetime'].toDate())}',style: smallerTextStyle(color: ThemeColor.blueGreyColor),),
                            SizeConfig.ultraSmallVerticalBox,
                            Text('Comments by recorder: ${snapshot.data.data()['performance']['comment']}',style: smallerTextStyle(color: ThemeColor.blueGreyColor),)
                          ],
                        ),
                      ),
                      SizeConfig.mediumVerticalBox,
                      Card(
                        elevation: 12.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: ThemeColor.whiteColor,
                        child: Container(
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Part A: Student Attention In Class', style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                                IconButton(
                                  icon: Icon(openA[index]? Icons.expand_less:Icons.expand_more),
                                  iconSize: SizeConfig.extraLarge,
                                  color: ThemeColor.lightBlueColor2,
                                  onPressed: (){
                                    setState(() {
                                      openA[index]=!openA[index];
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      openA[index]?Card(
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: ThemeColor.whiteColor,
                          child: ListView.builder(
                      shrinkWrap: true,
                        padding: EdgeInsets.all( SizeConfig.extraSmall),
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: addQuestions.length,
                        itemBuilder: (context,x){
                          return Column(children:<Widget>[Container(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.safeBlockVertical,
                                horizontal: SizeConfig.extraSmall),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                    color: ThemeColor.lightBlueGreyColor, width: 1.0)),
                            child: ListTile(
                              dense: true,
                              title: Text(addQuestions[x],style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                              subtitle: Text(valueFrequency[snapshot.data.data()['performance']['partA'][x]],style: smallerTextStyle(color: ThemeColor.blueColor),),
                              leading: Text((x+1).toString(),style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                            ),
                          ),
                            SizeConfig.ultraSmallVerticalBox
                          ]);
                        },
                      ),
                      ):Container(),
                      Card(
                        elevation: 12.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: ThemeColor.whiteColor,
                        child: Container(
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Part B: Student Reading & Learning Abilities', style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                                IconButton(
                                  icon: Icon(openB[index]? Icons.expand_less:Icons.expand_more),
                                  iconSize: SizeConfig.extraLarge,
                                  color: ThemeColor.lightBlueColor2,
                                  onPressed: (){
                                    setState(() {
                                      openB[index]=!openB[index];
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      openB[index]?Card(
                        elevation: 12.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: ThemeColor.whiteColor,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(SizeConfig.extraSmall),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: dyslexiaQuestions.length,
                          itemBuilder: (context,x){
                            return Column(children:<Widget>[Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: SizeConfig.safeBlockVertical,
                                  horizontal: SizeConfig.extraSmall),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                      color: ThemeColor.lightBlueGreyColor
                                      , width: 1.0)),
                              child: ListTile(
                                dense: true,
                                title: Text(dyslexiaQuestions[x],style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                                subtitle: Text(valueFrequency[snapshot.data.data()['performance']['partB'][x]],style: smallerTextStyle(color: ThemeColor.blueColor),),
                                leading: Text((x+1).toString(),style: smallererTextStyle(color: ThemeColor.blueGreyColor),),
                              ),
                            ),
                              SizeConfig.ultraSmallVerticalBox
                            ]);
                          },
                        ),
                      ):Container(),
                      SizeConfig.mediumVerticalBox
                    ],
                  ),
                ),
              ),
            );
          }));
    }
    return temp;
  }
}
