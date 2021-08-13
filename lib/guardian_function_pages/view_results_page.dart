import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';

class ViewResultsPage extends StatefulWidget {
  @override
  _ViewResultsPageState createState() => _ViewResultsPageState();
}

class _ViewResultsPageState extends State<ViewResultsPage> {

  GuardianProfile guardianProfile = new GuardianProfile();
  CollectionReference student =
  FirebaseFirestore.instance.collection('student');

  DateFormat formatter = DateFormat('dd MMM yyy');
  List<int> open = new List.from([]);
 @override
  void initState() {
    // TODO: implement initState
   for(int x=0;x<guardianProfile.childrenFirstName.length;x++){
     open.add(0);
   }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: guardianProfile.childrenFirstName.length,
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
                      tabs: resultTabBar()),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: resultTabView(),
        ),
      ),
    );
  }
  List<Widget> resultTabBar(){
    List<Widget> temp=List.from([]);
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

  List<Widget> resultTabView(){
    List<Widget> temp = List.from([]);
    for(int index=0;index<guardianProfile.childrenLastName.length;index++){
      temp.add(StreamBuilder<QuerySnapshot>(stream: student.doc(guardianProfile.childrenUID[index]).collection('results').orderBy('examEndDate', descending: true).snapshots(),
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
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizeConfig.smallHorizontalBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${guardianProfile.childrenFirstName[index]} ${guardianProfile.childrenLastName[index]}',
                                    style: smallTextStyle(
                                        color: ThemeColor.themeBlueColor),
                                  ),
                                  SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'Exam Results',
                                          style:
                                          smallerTextStyle(color: ThemeColor.blueColor),),
                                ],
                              ),
                            ),
                            SizeConfig.smallHorizontalBox
                          ],
                        ),
                        SizeConfig.smallVerticalBox,
                        snapshot.data.docs.length == 0
                            ? Container(
                          alignment: Alignment.center,
                          height: SizeConfig.safeBlockVertical * 60,
                          child:
                              Text(
                                'No Result Is Added Yet',
                                style:
                                smallerTextStyle(color: ThemeColor.blueColor),
                              )
                        )
                            : Expanded(
                            // height: SizeConfig.safeBlockVertical * 70,
                            child: ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, x) {
                                  return Card(
                                      elevation: 10.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      color: ThemeColor.whiteColor,
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                        EdgeInsets.all(SizeConfig.small),
                                        onTap: () {
                                          setState(() {
                                            if (open[index] == x)
                                              open[index] = null;
                                            else
                                              open[index] = x;
                                          });
                                        },
                                        trailing: Icon(open[index]==x?Icons.expand_less:Icons.expand_more,size: SizeConfig.large,color: ThemeColor.blueGreyColor,),
                                        title: Wrap(
                                            alignment:
                                            WrapAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                snapshot.data.docs[x]
                                                    .data()['exam name'].toUpperCase(),
                                                style: smallerTextStyle(
                                                    color: ThemeColor
                                                        .blackColor).copyWith(
                                                    letterSpacing: 0.2
                                                ),
                                              ),
                                              Text(
                                                '${formatter.format(snapshot.data.docs[x].data()['examStartDate'].toDate())} - ${formatter.format((snapshot.data.docs[x].data()['examEndDate'].toDate()))}',
                                                style: extraSmallTextStyle(
                                                    color:
                                                    ThemeColor.blueGreyColor),
                                              ),
                                            ]),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizeConfig.ultraSmallVerticalBox,
                                            SizeConfig.ultraSmallVerticalBox,
                                            Text(
                                              'Average Marks:  ${snapshot.data.docs[x].data()['averageMarks']}',
                                              style: smallerTextStyle(
                                                  color: ThemeColor.themeBlueColor),
                                            ),
                                            SizeConfig.ultraSmallVerticalBox,
                                            Text(
                                              'Grades:  ${snapshot.data.docs[x].data()['grade result']}',
                                              style: smallerTextStyle(
                                                  color: ThemeColor.themeBlueColor),
                                            ),
                                            SizeConfig.smallVerticalBox,
                                            Column(
                                              children: open[index] == x
                                                  ? getWidgets(Map.from(snapshot
                                                  .data.docs[x]
                                                  .data()['course result']))
                                                  : [],
                                            )
                                          ],
                                        ),
                                      ));
                                })),
                      ],
                    ),
                  ),
                );
          }));
    }
    return temp;
  }

  List<Widget> getWidgets(Map data) {
    List<Widget> temp = List.from([]);
    for (String key in data.keys) {
      temp.add(Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
          child: Row(
            children: <Widget>[
              Text(
                '$key  ',
                style: smallerTextStyle(color: ThemeColor.themeBlueColor),
              ),
              Text(
                '${data[key]['marks']} ${data[key]['grade']}',
                style: smallerTextStyle(color: ThemeColor.blueColor),
              )
            ],
          )));
    }
    return temp;
  }
}
