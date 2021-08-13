import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/BillSummary.dart';
import 'package:kiki/owner_function_pages/bill_collections/manage_bill_page.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ViewPreviousMonthsPage extends StatefulWidget {
  String kindergarten;
  ViewPreviousMonthsPage({this.kindergarten});
  @override
  _ViewPreviousMonthsPageState createState() => _ViewPreviousMonthsPageState();
}

class _ViewPreviousMonthsPageState extends State<ViewPreviousMonthsPage> {

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  List<BillSummary> billSummary = new List.from([]);

  double totalEarnings;
  double totalPaid;
  double totalUnpaid;
  bool isLoading;

  DateFormat formatter = DateFormat('MMM yyy');
  DateFormat formatter2 = DateFormat('dd MMM yyy kk:mm');

  @override
  void initState() {
    // TODO: implement initState
    isLoading=true;
    totalEarnings=0;
    totalPaid=0;
    totalUnpaid=0;
    init();
    super.initState();
  }
  
  Future<void> init()async{
    try{
      QuerySnapshot querySnapshot =await kindergarten.doc(widget.kindergarten).collection('bills').orderBy('billTime',descending:true).get();
      querySnapshot.docs.forEach((doc) {
        Map data =doc.data();
        BillSummary temp = new BillSummary();
        temp.status = data['status'].toInt();
        temp.totalUnPaidNo =data['totalUnPaidNo'].toInt();
        temp.totalPaidNo = data['totalPaidNo'].toInt();
        temp.totalPaid = data['totalPaid'].toDouble();
        temp.totalUnPaid = data['totalUnPaid'].toDouble();
        temp.totalBillsNo = data['totalBillsNo'].toInt();
        temp.totalBills =data['totalBills'].toDouble();
        temp.totalBillsStudents =data['totalBillsStudents'].toInt();
        temp.totalUnPaidStudents =data['totalUnPaidStudents'].toInt();
        temp.totalPaidStudents = data['totalPaidStudents'].toInt();
        temp.billTime =data['billTime'].toDate();

        totalPaid=totalPaid+temp.totalPaid;
        totalUnpaid = totalUnpaid+temp.totalUnPaid;
        totalEarnings =totalEarnings+temp.totalBills;
        billSummary.add(temp);
      });

      setState(() {
        isLoading=false;
      });
    }catch(e){
      Fluttertoast.showToast(
          msg: 'Failed to connect database',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.smaller);
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
        valueColor:
        AlwaysStoppedAnimation<Color>(ThemeColor.blueColor)),
    ))):RefreshIndicator(
      onRefresh: ()async{
        totalEarnings=0;
        totalPaid=0;
        totalUnpaid=0;
        billSummary.clear();
        await init();
      },
      child: Scaffold(
        backgroundColor: ThemeColor.whiteColor,
        appBar: kiAppBar(AppBarType.backButton, context),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left:SizeConfig.small, right: SizeConfig.small,top: SizeConfig.smaller),
            child: Column(
              children: <Widget>[
                Center(child:Text('MONTHLY COLLECTIONS',style: smalllTextStyle(color:ThemeColor.themeBlueColor),)),
                SizeConfig.ultraSmallVerticalBox,
                Text('Swipe down to refresh',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                SizeConfig.smallVerticalBox,
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.extraSmall,
                      horizontal: SizeConfig.smaller),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: ThemeColor.lightBlueGreyColor, width: 1.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Accumulated Earnings',style: smalllTextStyle(color: ThemeColor.blueColor),),
                          Text('RM ${totalEarnings.toStringAsFixed(2)}',style: smalllTextStyle(color: ThemeColor.themeBlueColor),)
                        ],
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Paid Bills',style: smallerTextStyle(color: ThemeColor.blackColor),),
                          Text('RM ${totalPaid.toStringAsFixed(2)}',style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('UnPaid Bills',style: smallerTextStyle(color: ThemeColor.blackColor),),
                          Text('RM ${totalUnpaid.toStringAsFixed(2)}',style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                        ],)
                    ],
                  ),
                ),
                SizeConfig.smallVerticalBox,
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: billSummary.length,
                itemBuilder: (context,x){
                  return Card(
                    color: ThemeColor.whiteColor,
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>ManageBillPage(date: formatter.format(billSummary[x].billTime),kindergarten: widget.kindergarten,)
                        ));
                      },
                      contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.extraSmall,horizontal: SizeConfig.smaller),
                      leading: Text(billSummary[x].status==0? 'IN\nPROGRESS':'FINISHED',style: extraSmallTextStyle(color: billSummary[x].status==0? ThemeColor.redColor:ThemeColor.blueColor),textAlign: TextAlign.center,),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(formatter.format(billSummary[x].billTime).toUpperCase(), style: smallerTextStyle(color: ThemeColor.blueColor),),
                          Text('RM ${billSummary[x].totalBills.toStringAsFixed(2)}',style: smallerTextStyle(color: ThemeColor.themeBlueColor),)
                        ],
                      ),

                      subtitle: Column(
                        children: <Widget>[
                          SizeConfig.extraSmallVerticalBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Bill Time',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                              Text(formatter2.format(billSummary[x].billTime),style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Total Paid Bills', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                              Text('RM ${billSummary[x].totalPaid.toStringAsFixed(2)}',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Total UnPaid Bills', style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
                              Text('RM ${billSummary[x].totalUnPaid.toStringAsFixed(2)}',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizeConfig.mediumVerticalBox
              ],
            ),
          ),
        ),
      ),
    );
  }
}
