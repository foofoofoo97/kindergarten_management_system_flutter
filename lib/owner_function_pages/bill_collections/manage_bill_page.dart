import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Bill.dart';
import 'package:kiki/models/BillSummary.dart';
import 'package:kiki/owner_function_pages/bill_collections/bill_settings_page.dart';
import 'package:kiki/owner_function_pages/bill_collections/view_detailed_bill_page.dart';
import 'package:kiki/owner_function_pages/bill_collections/view_previous_months_page.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_fees/manage_fees_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/info_message_dialog_2.dart';

class ManageBillPage extends StatefulWidget {

  String kindergarten;
  String date;
  ManageBillPage({this.kindergarten, this.date});

  @override
  _ManageBillPageState createState() => _ManageBillPageState();
}

class _ManageBillPageState extends State<ManageBillPage> {
  CollectionReference kindergarten = FirebaseFirestore.instance.collection(
      'kindergarten');
  CollectionReference student = FirebaseFirestore.instance.collection(
      'student');

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController searchController = new TextEditingController();

  BillSummary billSummary = new BillSummary();
  List<Bill> items = new List.from([]);
  List<Bill> duplicateAll = new List.from([]);
  List<Bill> duplicateUnPaid = new List.from([]);
  List<Bill> duplicatePaid = new List.from([]);

  DateFormat formatter = DateFormat('MMM yyy');

  int view;
  bool isLoading;
  int open;

  bool isRefreshing;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    isRefreshing=false;
    view = 0;
    getDocument();

    super.initState();
  }

  Future<void> getDocument() async {
    try {
      DocumentSnapshot documentSnapshot = await kindergarten
          .doc(widget.kindergarten)
          .collection('bills')
          .doc(widget.date)
          .get();

      if (documentSnapshot.exists) {
        Map data = documentSnapshot.data();
        billSummary.totalBills = data['totalBills'].toDouble();
        billSummary.totalBillsStudents = data['totalBillsStudents'].toInt();
        billSummary.totalPaid = data['totalPaid'].toDouble();
        billSummary.totalPaidStudents = data['totalPaidStudents'].toInt();
        billSummary.totalUnPaid = data['totalUnPaid'].toDouble();
        billSummary.totalUnPaidStudents = data['totalUnPaidStudents'].toInt();
        billSummary.totalBillsNo =data['totalBillsNo'].toInt();
        billSummary.totalPaidNo =data['totalPaidNo'].toInt();
        billSummary.totalUnPaidNo = data['totalUnPaidNo'].toInt();
        billSummary.status = data['status'].toInt();

        await getItems();
      }
      else {
        billSummary.totalBills = 0;
        billSummary.totalBillsStudents = 0;
        billSummary.totalPaidStudents = 0;
        billSummary.totalPaid = 0;
        billSummary.totalUnPaidStudents = 0;
        billSummary.totalUnPaid = 0;
        billSummary.status = -1;
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: 'Failed to connect database',
          textColor: ThemeColor.whiteColor,
          backgroundColor: ThemeColor.themeBlueColor,
          fontSize: SizeConfig.smaller);
    }
  }

  Future<void> getItems() async {

    QuerySnapshot querySnapshot = await kindergarten.doc(widget.kindergarten)
        .collection('bills/${widget.date}/${widget.date}').orderBy('updateTime',descending: true).get();
    querySnapshot.docs.forEach((doc) {
      Bill temp = new Bill();
      temp.status = doc.data()['status'].toInt();
      temp.uid = doc.id;
      temp.totalFee = doc.data()['totalFee'].toDouble();
      temp.fname = doc.data()['fname'];
      temp.lname = doc.data()['lname'];
      temp.billTime = doc.data()['billTime'].toDate();
      temp.childrenName = List.from(doc.data()['children name']);
      temp.noOfBills = doc.data()['noOfBills'].toInt();
      temp.paidTime = doc.data()['paidTime'].toDate();
      temp.kindergarten =doc.data()['kindergarten'];

      duplicateAll.add(temp);
      temp.status == 0 ? duplicateUnPaid.add(temp) : duplicatePaid.add(temp);
    });

    items.addAll(duplicateAll);
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
              valueColor:
              AlwaysStoppedAnimation<Color>(ThemeColor.blueColor)),
        ),
      ),
    )
        : RefreshIndicator(
          onRefresh: ()async{
            duplicateUnPaid.clear();
            duplicatePaid.clear();
            duplicateAll.clear();
            items.clear();
            await getDocument();
          },
              child:Scaffold(
              appBar: AppBar(
                backgroundColor: ThemeColor.whiteColor,
                elevation: 0,
                leading: KiButton.smallButton(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: ThemeColor.blueGreyColor,
                      size: SizeConfig.large,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                actions: <Widget>[
                  KiButton.smallButton(
                      child: Icon(
                        Icons.settings,
                        color: ThemeColor.blueGreyColor,
                        size: SizeConfig.large,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ManageBillSettingsPage()));
                      }),
                  SizeConfig.extraLargeHorizontalBox
                ],
              ),
              backgroundColor: ThemeColor.whiteColor,
              key: _scaffoldKey,
              body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.small,
                      right: SizeConfig.small),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          KiButton.smallButton(
                              child: Card(
                                  color: ThemeColor.whiteColor,
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal),
                                      child: Text(
                                        ' Previous Months ',
                                        style: smallerTextStyle(
                                            color: ThemeColor.blueColor),
                                      ))),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewPreviousMonthsPage(
                                              kindergarten: widget.kindergarten,
                                            )));
                              }),
                          //Expanded(child: Container()),
                          KiButton.smallButton(
                              child: Card(
                                  color: ThemeColor.whiteColor,
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal),
                                      child: Text(
                                        ' Manage Fees ',
                                        style: smallerTextStyle(
                                            color: ThemeColor.blueColor),
                                      ))),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageFeesPage(
                                              kindergarten: widget.kindergarten,
                                            )));
                              }),
                        ],
                      ),
                      SizeConfig.extraSmallVerticalBox,
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.extraSmall,
                            horizontal: SizeConfig.smaller),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: ThemeColor.lightestBlueGreyColor, width: 1.0)),
                        child: Column(
                          children: <Widget>[
                            SizeConfig.extraSmallVerticalBox,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Bills Collection'.toUpperCase(),
                                  style: smallTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                ),
                                SizeConfig.smallHorizontalBox,
                                KiButton.smallButton(
                                    child: Icon(
                                      Icons.info, color: ThemeColor.themeBlueColor,
                                      size: SizeConfig.medium*0.9,),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) => InfoMessageDialog2(
                                              height: SizeConfig.safeBlockVertical*45,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: SizeConfig
                                                        .safeBlockVertical,
                                                    horizontal:
                                                    SizeConfig.smaller),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    border: Border.all(
                                                        color: ThemeColor.lightBlueColor2, width: 1.0)),
                                                child:Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizeConfig.smallVerticalBox,
                                                    Text('Settings'.toUpperCase(),style: extraSmallTextStyle(color: ThemeColor.blueColor),textAlign: TextAlign.center,),
                                                    SizeConfig.ultraSmallVerticalBox,
                                                    Text('To change monthly default billing time',style: smallerTextStyle(color: ThemeColor.themeBlueColor),textAlign: TextAlign.center),
                                                    SizeConfig.extraSmallVerticalBox,
                                                    Text('Previous Months'.toUpperCase(),style: extraSmallTextStyle(color: ThemeColor.blueColor),textAlign: TextAlign.center),
                                                    SizeConfig.ultraSmallVerticalBox,
                                                    Text('To view bill collections of previous months',style: smallerTextStyle(color: ThemeColor.themeBlueColor),textAlign: TextAlign.center),
                                                    SizeConfig.extraSmallVerticalBox,
                                                    Text('Manage Fees'.toUpperCase(),style: extraSmallTextStyle(color: ThemeColor.blueColor),textAlign: TextAlign.center),
                                                    SizeConfig.ultraSmallVerticalBox,
                                                    Text('To manage fees type and tag students to charge fees',style: smallerTextStyle(color: ThemeColor.themeBlueColor),textAlign: TextAlign.center)
                                                    ,SizeConfig.smallVerticalBox,
                                                  ],
                                                ),
                                              )));
                                    }
                                ),
                              ],
                            ),
                            SizeConfig.ultraSmallVerticalBox,
                            Text('Swipe down to refresh ',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                            SizeConfig.extraSmallVerticalBox,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Card(
                                  color: ThemeColor.whiteColor,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.extraSmall,
                                        bottom: SizeConfig.extraSmall,
                                        left: SizeConfig.smaller,
                                        right: SizeConfig.smaller),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Total Earnings In ${widget.date==formatter.format(DateTime.now())?'Current':'Selected'} Month',
                                          style: smallerTextStyle(
                                              color: ThemeColor.themeBlueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          '( ${widget.date} )',
                                          style: smallerTextStyle(
                                              color: ThemeColor.themeBlueColor),
                                        ),
                                        SizeConfig.extraSmallVerticalBox,
                                        Text(
                                          'RM ${billSummary.totalBills.toStringAsFixed(2)}',
                                          style: smallTextStyle(
                                              color: ThemeColor.blueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'from ${billSummary.totalBillsNo} bills',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'of ${billSummary.totalBillsStudents} students',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizeConfig.ultraSmallVerticalBox,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Card(
                                  color: ThemeColor.whiteColor,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.extraSmall,
                                        bottom: SizeConfig.extraSmall,
                                        left: SizeConfig.smaller,
                                        right: SizeConfig.smaller),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Total UnPaid',
                                          style: smallerTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'RM ${billSummary.totalUnPaid.toStringAsFixed(
                                              2)}',
                                          style: smallTextStyle(
                                              color: ThemeColor.blueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'from ${billSummary.totalUnPaidNo} bills',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'of ${billSummary.totalUnPaidStudents} students',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizeConfig.smallHorizontalBox,
                                Card(
                                  color: ThemeColor.whiteColor,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.extraSmall,
                                        bottom: SizeConfig.extraSmall,
                                        left: SizeConfig.small,
                                        right: SizeConfig.small),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Total Paid',
                                          style: smallerTextStyle(
                                              color: ThemeColor.themeBlueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'RM ${billSummary.totalPaid.toStringAsFixed(2)}',
                                          style: smallTextStyle(
                                              color: ThemeColor.blueColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'from ${billSummary.totalPaidNo} bills',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        ),
                                        SizeConfig.ultraSmallVerticalBox,
                                        Text(
                                          'of ${billSummary.totalPaidStudents} students',
                                          style: extraSmallTextStyle(
                                              color: ThemeColor.blueGreyColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizeConfig.ultraSmallVerticalBox
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              KiButton.smallButton(
                                  child: Card(
                                    elevation: 12.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    color: view == 0
                                        ? ThemeColor.lightBlueColor
                                        : ThemeColor.whiteColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical),
                                      child: Text(
                                        'All Bills',
                                        style: extraSmallTextStyle(
                                            color: view == 0 ? ThemeColor
                                                .themeBlueColor : ThemeColor
                                                .blueGreyColor),
                                      ),
                                    ),),
                                  onPressed: () {
                                    setState(() {
                                      items.clear();
                                      items.addAll(duplicateAll);
                                      view = 0;
                                    });
                                  }
                              ),
                              KiButton.smallButton(
                                  child: Card(
                                    elevation: 12.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    color: view == 1
                                        ? ThemeColor.lightBlueColor
                                        : ThemeColor.whiteColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical),
                                      child: Text('Paid',
                                          style: extraSmallTextStyle(
                                              color: view == 1 ? ThemeColor
                                                  .themeBlueColor : ThemeColor
                                                  .blueGreyColor)),
                                    ),),
                                  onPressed: () {
                                    setState(() {
                                      items.clear();
                                      items.addAll(duplicatePaid);
                                      view = 1;
                                    });
                                  }
                              ),
                              KiButton.smallButton(
                                  child: Card(
                                    elevation: 12.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    color: view == 2
                                        ? ThemeColor.lightBlueColor
                                        : ThemeColor.whiteColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical),
                                      child: Text(
                                        'UnPaid',
                                        style: extraSmallTextStyle(
                                            color: view == 2 ? ThemeColor
                                                .themeBlueColor : ThemeColor
                                                .blueGreyColor),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      items.clear();
                                      items.addAll(duplicateUnPaid);
                                      view = 2;
                                    });
                                  }
                              )
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom:SizeConfig.extraSmall,top: SizeConfig.small),
                        child: KiTextField.borderedTextFormField(
                            controller: searchController,
                            titleText: 'Search',
                            hintText: 'Search by guardian, student, bill amount',
                            maxLines: 1,
                            onChanged: (value) {
                              filterSearchResults(value);
                            },
                            hintStyle:
                            smallerTextStyle(color: ThemeColor.blueGreyColor),
                            activeBorderColor: ThemeColor.themeBlueColor,
                            borderColor: ThemeColor.blueGreyColor,
                            radius: 25.0,
                            textStyle: smallerTextStyle(
                                color: ThemeColor.themeBlueColor),
                            labelStyle: smallerTextStyle(
                                color: ThemeColor.themeBlueColor)),
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, x) {
                            return Card(
                              color: ThemeColor.whiteColor,
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.only(top:
                                      SizeConfig.safeBlockVertical, bottom:SizeConfig.safeBlockVertical,left: SizeConfig.extraSmall,right: SizeConfig.extraSmall),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context)=>ViewDetailedBillPage(bill: items[x],date: widget.date,)
                                    ));
                                  },
                                  title: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            '${items[x].fname} ${items[x].lname}',
                                            style: smallerTextStyle(
                                                color: ThemeColor.themeBlueColor)),
                                        SizeConfig.mediumHorizontalBox,
                                        Text(
                                          'RM ${items[x].totalFee.toStringAsFixed(
                                              2)}',
                                          style: smallerTextStyle(
                                              color: ThemeColor.blueColor),
                                        )
                                      ]),
                                  trailing: Text(
                                    items[x].status == 0 ? 'UNPAID' : 'PAID',
                                    style: smallererTextStyle(color: items[x].status ==
                                        0 ? ThemeColor.redColor : ThemeColor
                                        .blueColor),),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizeConfig.ultraSmallVerticalBox,
                                      Text('Guardian Of ${getChildren(items[x].childrenName)}(${items[x].noOfBills})',
                                        style: extraSmallTextStyle(
                                            color: ThemeColor.blueGreyColor),)
                                    ],
                                  )
                              ),
                            );
                          }),
                      SizeConfig.largeVerticalBox,
                    ],
                  ),
                ),
              )),
        );
  }

  String getChildren(List childrenName) {
    String temp ='';
    for(String name in childrenName){
      temp=name+', $temp';
    }
     return temp;
  }

  void filterSearchResults(String query) {
    List<Bill> dummySearchList = new List.from([]);
    dummySearchList.addAll(view==0? duplicateAll:view==1? duplicatePaid: duplicateUnPaid);
    if(query.isNotEmpty) {
      List<Bill> dummyListData = new List.from([]);
      dummySearchList.forEach((item) {
        if(('RM ${item.totalFee}').contains(query)) {
          dummyListData.add(item);
        }
        else if('${item.fname} ${item.lname}'.toLowerCase().contains(query.toLowerCase())){
          dummyListData.add(item);
        }
        else if(getChildren(item.childrenName).toLowerCase().contains(query.toLowerCase())){
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(view==0? duplicateAll:view==1? duplicatePaid: duplicateUnPaid);
      });
    }
  }

}


