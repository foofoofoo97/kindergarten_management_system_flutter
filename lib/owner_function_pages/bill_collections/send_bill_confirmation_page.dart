import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class SendBillConfirmationPage extends StatefulWidget {
  @override
  _SendBillConfirmationPageState createState() => _SendBillConfirmationPageState();
}

class _SendBillConfirmationPageState extends State<SendBillConfirmationPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference student = FirebaseFirestore.instance.collection('student');
  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');

  DateFormat formatter = DateFormat('MMM yyy');

  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiCenterPage(
          color: ThemeColor.whiteColor,
          scaffoldKey: _scaffoldKey,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.extraLarge),
            child: Column(
              children: <Widget>[
                DateTime.now().day==kindergartenProfile.dayToBill? Text(
                  'TIME TO BILLS !',style: extraLargeTextStyle(color: ThemeColor.themeBlueColor),
                ):Text('${DateTime.now().day-kindergartenProfile.dayToBill} DAYS LATE !', style: largeTextStyle(color: ThemeColor.redColor),),
                SizeConfig.mediumVerticalBox,
                Text('Time To Send Bills To Guardians',style: mediumSmallTextStyle(color: ThemeColor.themeBlueColor),),
                SizeConfig.extraSmallVerticalBox,
                Text('You could change current settings of day to remind sending bill by clicking settings button in fees collection page',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),textAlign: TextAlign.center,),
                SizeConfig.mediumVerticalBox,
                KiButton.rectButton(

                    onPressed: ()async{
                      setState(() {
                        isLoading=true;
                      });
                      try{
                        await generateBill();
                        kindergartenProfile.isBilled=true;
                        await kindergarten.doc(kindergartenProfile.name).update({
                          'date to bill':kindergartenProfile.dayToBill,
                          'month to bill': kindergartenProfile.monthToBill!=12? kindergartenProfile.monthToBill+1:1,
                        });}
                      catch(e){
                        Fluttertoast.showToast(msg: 'Failed to connect database', textColor: ThemeColor.whiteColor,backgroundColor: ThemeColor.themeBlueColor,fontSize: SizeConfig.smaller);
                      }
                      setState(() {
                        isLoading=false;
                      });
                    },
                    color: ThemeColor.themeBlueColor,
                    child:Text('SEND NOW',style: smallerTextStyle(color: ThemeColor.whiteColor),)),
                SizeConfig.ultraSmallVerticalBox,
                KiButton.rectButton(
                    onPressed: (){
                      //Notifier timer
                    },
                    color: ThemeColor.lightBlueColor,
                    child:Text('REMIND ME LATER',style: smallerTextStyle(color: ThemeColor.themeBlueColor),)),

              ],
            ),
          ),
        ),
        isLoading?Center(
          child: SizedBox(
            height: SizeConfig.safeBlockVertical * 5,
            width: SizeConfig.safeBlockVertical * 5,
            child: CircularProgressIndicator(
              backgroundColor: ThemeColor.whiteColor,
            ),
          ),
        ) : Container()
      ],
    );
  }

  Future<void> generateBill()async{
    double totalFees=0;
    Map<String,dynamic> names = new Map();
    Map<String,dynamic> parent = new Map();

    kindergartenProfile.feesType.forEach((key,value)async{
      for(int index=0;index<value['selected students'].length;index++){
        String uid = value['selected students'][index];
        names.putIfAbsent(uid, () => {
          'totalFee': 0,
          'fees': new Map(),
          'fname':value['selected students fname'][index],
          'lname':value['selected students lname'][index],
          'uid':uid,
        });
        totalFees=totalFees+value['amount'];
        names[uid]['totalFee'] = names[uid]['totalFee']+value['amount'];
        names[uid]['fees'].putIfAbsent(key, () => value['amount']);
      }
    });

    for(String key in names.keys){
    String guardianID = key.split('+')[0];
    parent.putIfAbsent(guardianID, () =>
        {
          'totalFee': 0,
          'billTime': DateTime.now(),
          'status': 0,
          'noOfBills': 0,
          'children name': new List.from([]),
          'kindergarten': kindergartenProfile.name,
          'fname':'',
          'lname':'',
          'updateTime':DateTime.now(),
          'paidTime':DateTime.now()
   });
    if(parent[guardianID]['fname']==''){
        DocumentSnapshot documentSnapshot = await guardian.doc(guardianID).get();
        parent[guardianID]['fname']=documentSnapshot.data()['first name'];
        print(parent[guardianID]['fname']);
        parent[guardianID]['lname']=documentSnapshot.data()['last name'];
    }

      parent[guardianID]['totalFee']=parent[guardianID]['totalFee']+names[key]['totalFee'];
      parent[guardianID]['noOfBills']=parent[guardianID]['noOfBills']+1;
      List tempFirstName = parent[guardianID]['children name'];
      tempFirstName.add('${names[key]['fname']} ${names[key]['lname']}');
      parent[guardianID]['children name'] = tempFirstName;
      await guardian.doc('$guardianID/bills/${formatter.format(DateTime.now())}/${formatter.format(DateTime.now())}/${kindergartenProfile.name}/item/$key').set(names[key]);
    }

    for(String guardianID in parent.keys){
      await kindergarten.doc('${kindergartenProfile.name}/bills/${formatter.format(DateTime.now())}/${formatter.format(DateTime.now())}/$guardianID').set(parent[guardianID]);
      await guardian.doc('$guardianID/bills/${formatter.format(DateTime.now())}').set({
        'month': DateTime.now().month,
        'day': DateTime.now().year
      });
      await guardian.doc('$guardianID/bills/${formatter.format(DateTime.now())}/${formatter.format(DateTime.now())}/${kindergartenProfile.name}').set(parent[guardianID]);
    }


    await kindergarten.doc('${kindergartenProfile.name}/bills/${formatter.format(DateTime.now())}').set({
      'totalBills': totalFees,
      'totalUnPaid':totalFees,
      'totalPaid':0,
      'totalBillsNo': parent.length,
      'totalBillsStudents':names.keys.length,
      'totalUnPaidNo': parent.length,
      'totalUnPaidStudents': names.keys.length,
      'totalPaidStudents':0,
      'totalPaidNo': 0,
      'status':0,
      'billTime': DateTime.now()
    });
  }
}
