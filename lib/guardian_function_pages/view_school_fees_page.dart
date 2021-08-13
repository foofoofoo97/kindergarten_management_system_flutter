import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/guardian_function_pages/view_detailed_bill_page.dart';
import 'package:kiki/models/Bill.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ViewSchoolFeesPage extends StatefulWidget {
  @override
  _ViewSchoolFeesPageState createState() => _ViewSchoolFeesPageState();
}

class _ViewSchoolFeesPageState extends State<ViewSchoolFeesPage> {

  CollectionReference guardian =
  FirebaseFirestore.instance.collection('guardian');

  GuardianProfile guardianProfile = new GuardianProfile();
  List<String> verifiedKindergarten = new List.from([]);
  Map<String, dynamic> verifiedChildren = new Map();
  bool isLoading;
  Map<String,dynamic> dataMap = new Map();
  DateFormat formatter = DateFormat('MMM yyy');
  DateFormat formatter2 = DateFormat('dd MMM yyy kk:mm');

  @override
  void initState() {
    // TODO: implement initState
    isLoading=true;
    setup();
    init();
    super.initState();

  }
  void setup(){
    for(int x =0;x<guardianProfile.childrenStatus.length;x++){
      if(guardianProfile.childrenStatus[x]==1){
        verifiedKindergarten.add(guardianProfile.childrenKindergarten[x]);
        verifiedChildren.putIfAbsent(guardianProfile.childrenKindergarten[x], () => new List.from([]));
        verifiedChildren[guardianProfile.childrenKindergarten[x]].add('${guardianProfile.childrenFirstName[x]} ${guardianProfile.childrenLastName[x]}');
      }
    }

    verifiedKindergarten =verifiedKindergarten.toSet().toList();
  }


  Future<void> init()async{
    try{
      QuerySnapshot monthSnapshot = await guardian.doc(guardianProfile.uid).collection('bills').orderBy('day',descending: true).orderBy('month', descending: true).get();
      List<String> id =new List.from([]);
      monthSnapshot.docs.forEach((doc){
         id.add(doc.id);
      });
      for(String docId in id){
        await getItems(docId);
      }
      setState(() {
        isLoading=false;
      });
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: 'Failed to connect database',backgroundColor: ThemeColor.themeBlueColor, textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
    }
  }

  Future<void> getItems(String id)async{
    try {
      QuerySnapshot kindergartenSnapshot = await guardian.doc(
          guardianProfile.uid).collection('bills').doc(id).collection(id).get();
      kindergartenSnapshot.docs.forEach((documentSnapshot) {
        dataMap.putIfAbsent(documentSnapshot.id, () => new List.from([]));
        Map data =documentSnapshot.data();
        Bill bill = new Bill();
        bill.billId=id;
        bill.totalFee = data['totalFee'].toDouble();
        bill.childrenName = List.from(data['children name']);
        bill.billTime = data['billTime'].toDate();
        bill.status = data['status'].toInt();
        bill.paidTime = data['paidTime'].toDate();
        bill.kindergarten = data['kindergarten'];
        bill.uid = guardianProfile.uid;
        bill.noOfBills = data['noOfBills'].toInt();

        dataMap[documentSnapshot.id].add(bill);

      });
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: 'Failed to connect database',backgroundColor: ThemeColor.themeBlueColor, textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
    }

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
            valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.blueColor),
          ),
        ),
      ),
    ) :
    verifiedKindergarten.length==0?
    KiCenterPage(
      color: ThemeColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.medium),
        child: Column(
          children: <Widget>[
            Icon(Icons.verified_user,color: ThemeColor.blueColor,size: SizeConfig.extraLarge*2,),
            SizeConfig.mediumVerticalBox,
            Text('Fees View Is Restricted',style: smallTextStyle(color: ThemeColor.blueColor),),
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
      ),
    );
  }

  List<Tab> guardianTabs() {
    List<Tab> list = new List.from([]);
    String name;
    for (int x = 0; x < verifiedKindergarten.length; x++) {
      name = '';
      for (String child in verifiedChildren[verifiedKindergarten[x]]) {
          setState(() {
            name = name + '$child  ';
          });
      }
      list.add(
        Tab(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SizeConfig.ultraSmallVerticalBox,
                Text(
                  guardianProfile.childrenKindergarten[x],
                  style: TextStyle(letterSpacing: 1.2),
                ),
                SizeConfig.ultraSmallVerticalBox,
                Text(
                  '$name',
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
      list.add(guardianTabView(x,verifiedKindergarten[x]));
    }

    return list;
  }

  Widget guardianTabView(int index, String distinctKindergarten){
    return Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      body: RefreshIndicator(
        onRefresh: ()async{
          dataMap.clear();
          verifiedKindergarten.clear();
          verifiedChildren.clear();
          setup();
          await init();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left:SizeConfig.small, right: SizeConfig.small, top: SizeConfig.smaller),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(distinctKindergarten,style: smallTextStyle(color: ThemeColor.themeBlueColor),),
                SizeConfig.ultraSmallVerticalBox,
                Text(
                  'Swipe down to refresh posts',style: smallererTextStyle(color: ThemeColor.blueGreyColor),
                ),
                SizeConfig.ultraSmallVerticalBox,
                dataMap.containsKey(distinctKindergarten)? ListView.builder(
                  padding: EdgeInsets.only(top: SizeConfig.extraSmall
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dataMap[distinctKindergarten].length,
                  itemBuilder: (context,x){
                    return Card(
                    color: ThemeColor.whiteColor,
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                    ),

                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical:SizeConfig.extraSmall,horizontal: SizeConfig.small),
                      leading: Text(dataMap[distinctKindergarten][x].status==0? 'UNPAID':'PAID',style: smallererTextStyle(color: dataMap[distinctKindergarten][x].status==0? ThemeColor.redColor:ThemeColor.blueColor),),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(formatter.format(dataMap[distinctKindergarten][x].billTime).toUpperCase(),style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                          Text('RM ${dataMap[distinctKindergarten][x].totalFee.toStringAsFixed(2)}',style: smallerTextStyle(color: ThemeColor.blueColor),)
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context)=> ViewDetailedGuardianBillPage(
                            bill: dataMap[distinctKindergarten][x],
                            date: dataMap[distinctKindergarten][x].billId,
                          )
                        ));
                      },
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizeConfig.ultraSmallVerticalBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Bill Time',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                              Text(formatter2.format(dataMap[distinctKindergarten][x].billTime),style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Paid Time',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                              Text(dataMap[distinctKindergarten][x].status==0? 'Not Available':formatter2.format(dataMap[distinctKindergarten][x].paidTime),style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Children',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                              Text(getChildren(dataMap[distinctKindergarten][x].childrenName),style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                            ],
                          ),
                        ],
                      ),
                    ));
                  },
                ):
                Container(
                    height: SizeConfig.safeBlockVertical * 50,
                    child:Center(
                        child: Text('No Bills Yet',
                            style: smallTextStyle(color:ThemeColor.blueGreyColor)))),
                SizeConfig.mediumVerticalBox
              ],
            ),
          ),
        ),
      ),
    );
  }


String getChildren(List childrenName) {
  String temp ='';
  for(String name in childrenName){
    temp='$temp, '+name;
  }
  temp=temp.substring(1);
  return temp;
}}