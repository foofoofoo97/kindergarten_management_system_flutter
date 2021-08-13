import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Bill.dart';
import 'package:kiki/models/StudentBill.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class ViewDetailedGuardianBillPage extends StatefulWidget {
  Bill bill;
  String date;
  ViewDetailedGuardianBillPage({this.bill,this.date});

  @override
  _ViewDetailedGuardianBillPageState createState() => _ViewDetailedGuardianBillPageState();
}

class _ViewDetailedGuardianBillPageState extends State<ViewDetailedGuardianBillPage> {

  DateFormat formatter = DateFormat('MMM yyy');
  DateFormat timeFormatter = DateFormat('dd MMM yyy kk:mm');

  CollectionReference guardian = FirebaseFirestore.instance.collection('guardian');
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  List<StudentBill> list = new List.from([]);
  bool isLoading;
  bool isUpdating;
  Bill chosenBill;

  @override
  void initState() {
    // TODO: implement initState
    isLoading=true;
    isUpdating=false;
    chosenBill=widget.bill;
    init();
    super.initState();
  }

  Future<void> init()async{
    try{
      QuerySnapshot querySnapshot = await guardian.doc(chosenBill.uid).collection('bills/${widget.date}/${widget.date}/${chosenBill.kindergarten}/item').get();
      querySnapshot.docs.forEach((doc) {
        StudentBill studentBill= new StudentBill();
        studentBill.fname = doc.data()['fname'];
        studentBill.lname =doc.data()['lname'];
        studentBill.uid =doc.data()['uid'];
        studentBill.totalFee = doc.data()['totalFee'].toDouble();
        studentBill.fees =Map.from(doc.data()['fees']);
        list.add(studentBill);
      });

      setState(() {
        isLoading=false;
      });}
    catch(e){
      Fluttertoast.showToast(msg: 'Failed to connect database',backgroundColor: ThemeColor.themeBlueColor,textColor: ThemeColor.whiteColor,fontSize: SizeConfig.smaller);
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
        ),
      ),
    ):Scaffold(
      appBar: kiAppBar(AppBarType.backButton, context),
      backgroundColor: ThemeColor.whiteColor,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left:SizeConfig.small, right:SizeConfig.small,top: SizeConfig.smaller),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Text(chosenBill.kindergarten.toUpperCase(),style: smalllTextStyle(color: ThemeColor.themeBlueColor),)],),
                      SizeConfig.ultraSmallVerticalBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Bill of ${formatter.format(chosenBill.billTime).toUpperCase()}',style: smalllTextStyle(color: ThemeColor.blueColor),)
                        ],
                      ),
                      SizeConfig.ultraSmallVerticalBox,
                      Card(
                          color: ThemeColor.whiteColor,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(SizeConfig.small),
                              child:Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Bill Time: ${timeFormatter.format(chosenBill.billTime)}',style: extraSmallTextStyle(color: ThemeColor.blackColor),),
                                          SizeConfig.ultraSmallVerticalBox,
                                          Text('Paid Time: ${chosenBill.status==0?'Not Available Yet':timeFormatter.format(chosenBill.paidTime)}',style: extraSmallTextStyle(color: ThemeColor.blackColor),),
                                        ],
                                      ),
                                      Text(chosenBill.status==0?'UnPaid':'Paid',style: smallerTextStyle(color: chosenBill.status==0?ThemeColor.redColor:ThemeColor.blueColor),)
                                    ],
                                  ),
                                  SizeConfig.extraSmallVerticalBox,
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: list.length,
                                      itemBuilder: (context,x){
                                        return Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: SizeConfig.extraSmall,
                                                  horizontal: SizeConfig.smaller),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  border: Border.all(
                                                      color: ThemeColor.lightBlueGreyColor, width: 1.0)),
                                              child: ListTile(
                                                title: Row(
                                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text('${list[x].fname} ${list[x].lname}',style: smallerTextStyle(color: ThemeColor.blueColor),),
                                                    Text('RM ${list[x].totalFee.toStringAsFixed(2)}',style: smallerTextStyle(color: ThemeColor.blackColor),)
                                                  ],
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children:getChildren(list[x].fees),
                                                ),
                                              ),
                                            ),
                                            SizeConfig.smallVerticalBox
                                          ],
                                        );
                                      }),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: SizeConfig.smaller),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color: ThemeColor.lightBlueColor2, width: 1.0)),
                                    child: ListTile(
                                      dense: true,
                                      title: Row(
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Total',style: smallerTextStyle(color: ThemeColor.blueColor),),
                                          Text('RM ${chosenBill.totalFee.toStringAsFixed(2)}',style: smallerTextStyle(color: ThemeColor.blackColor),)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizeConfig.smallVerticalBox
                                ],))),
                      SizeConfig.mediumVerticalBox,
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  KiButton.rectButton(
                      onPressed: ()async{
                        try{
                          if(chosenBill.status==0) {
                            setState(() {
                              isUpdating=true;
                            });

                            DateTime now = DateTime.now();

                            int status = 1;
                            await kindergarten.doc('${chosenBill
                                .kindergarten}/bills/${formatter.format(
                                DateTime.now())}/${formatter.format(
                                DateTime.now())}/${chosenBill.uid}').update({
                              'status': status,
                              'paidTime': now
                            });
                            await guardian.doc('${chosenBill
                                .uid}/bills/${formatter.format(
                                DateTime.now())}/${formatter.format(
                                DateTime.now())}/${chosenBill.kindergarten}')
                                .update({
                              'status': status,
                              'paidTime':now
                            });

                            DocumentSnapshot document = await kindergarten.doc(
                                '${chosenBill.kindergarten}/bills/${formatter
                                    .format(DateTime.now())}').get();
                            Map data = document.data();

                              await kindergarten.doc('${chosenBill
                                  .kindergarten}/bills/${formatter.format(
                                  DateTime.now())}').update({
                                'totalUnPaid': data['totalUnPaid'] -
                                    chosenBill.totalFee,
                                'totalPaid': data['totalPaid'] +
                                    chosenBill.totalFee,
                                'totalUnPaidNo': data['totalUnPaidNo'] - 1,
                                'totalUnPaidStudents': data['totalUnPaidStudents'] -
                                    chosenBill.noOfBills,
                                'totalPaidStudents': data['totalPaidStudents'] +
                                    chosenBill.noOfBills,
                                'totalPaidNo': data['totalPaidNo'] + 1,
                                'status': (data['totalUnPaid'] -
                                    chosenBill.totalFee) == 0 ? 1 : 0,
                                'paidTime': now,
                                'updateTime': now
                              });

                              setState(() {
                                chosenBill.paidTime = now;
                              });

                            setState(() {
                              chosenBill.status = status;
                              isUpdating = false;
                            });

                            Fluttertoast.showToast(
                                msg: 'Bill status is updated',
                                backgroundColor: ThemeColor.themeBlueColor,
                                textColor: ThemeColor.whiteColor,
                                fontSize: SizeConfig.smaller);
                          }
                          else{
                            Fluttertoast.showToast(
                                msg: 'Bill is paid',
                                backgroundColor: ThemeColor.themeBlueColor,
                                textColor: ThemeColor.whiteColor,
                                fontSize: SizeConfig.smaller);

                          }
                        }catch(e){
                          Fluttertoast.showToast(msg: 'Failed to connect database',
                              backgroundColor: ThemeColor.themeBlueColor,
                              textColor: ThemeColor.whiteColor,
                              fontSize: SizeConfig.smaller);
                        }
                      },
                      color: ThemeColor.lightBlueColor,
                      child: Text(chosenBill.status==0?'PAY NOW':'PAID',style: extraSmallTextStyle(color: ThemeColor.themeBlueColor),)
                  )
                ],
              )
            ],
          ),
          isUpdating?Center(
            child: SizedBox(
              height: SizeConfig.safeBlockVertical * 5,
              width: SizeConfig.safeBlockVertical * 5,
              child: CircularProgressIndicator(
                backgroundColor: ThemeColor.whiteColor,
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }

  List<Widget> getChildren(Map fees){
    List<Widget> temp = new List.from([]);
    temp.add(SizeConfig.smallVerticalBox);
    temp.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Item',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor)),
        Text('Fee',style: extraSmallTextStyle(color: ThemeColor.blueGreyColor),),
      ],
    ));
    for(String key in fees.keys){
      temp.add(SizeConfig.ultraSmallVerticalBox);
      temp.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(key,style: smallererTextStyle(color: ThemeColor.themeBlueColor),),
              Text('RM ${fees[key].toStringAsFixed(2)}',style: smallererTextStyle(color: ThemeColor.themeBlueColor),)
            ],
          )
      );
    }
    return temp;
  }

  Future<void> resendBill()async{
    try{
      Map<String,dynamic> children =new Map();
      List<StudentBill> studentBills =new List.from([]);
      Map<String,dynamic> guardianData = new Map();
      DocumentSnapshot documentSnapshot = await kindergarten.doc(chosenBill.kindergarten).get();
      Map data = Map.from(documentSnapshot.data()['fees type']);

      for(String course in data.keys){
        print(course);
        int index=0;
        for(String uid in data[course]['selected students']){
          String parent = uid.split('+')[0];
          print(uid);
          if(chosenBill.uid==parent){
            print(uid);
            children.putIfAbsent(uid, () => {
              'totalFee': 0,
              'fees': new Map(),
              'fname': data[course]['selected students fname'][index],
              'lname': data[course]['selected students lname'][index],
              'uid': uid,
            });
            children[uid]['totalFee'] = children[uid]['totalFee'] + data[course]['amount'];
            children[uid]['fees'].putIfAbsent(course, () => data[course]['amount']);
          }
          index++;
        }
      }
      guardianData.addAll({
        'totalFee':0,
        'updateTime': DateTime.now(),
        'billTime':DateTime.now(),
        'noOfBills':0,
        'children name':new List.from([])
      });

      children.forEach((key, value) {
        guardianData['noOfBills']=guardianData['noOfBills']+1;
        guardianData['totalFee']=guardianData['totalFee']+value['totalFee'];
        guardianData['children name'].add('${value['fname']} ${value['lname']}');

        StudentBill studentBill = new StudentBill();
        studentBill.uid =key;
        studentBill.fname=value['fname'];
        studentBill.lname=value['lname'];
        studentBill.totalFee=value['totalFee'];
        studentBill.fees=value['fees'];

        studentBills.add(studentBill);
      });

      await guardian.doc(chosenBill.uid).collection('bills').doc(widget.date).collection(widget.date).doc(chosenBill.kindergarten).update(guardianData);
      await guardian.doc(chosenBill.uid).collection('bills').doc(widget.date).collection(widget.date).doc(chosenBill.kindergarten).collection('item').get().
      then((value){ for(DocumentSnapshot doc in value.docs){
        doc.reference.delete();
      }});
      for(String uid in children.keys){
        await guardian.doc(chosenBill.uid).collection('bills').doc(widget.date).collection(widget.date).doc(chosenBill.kindergarten).collection('item').doc(uid).set(children[uid]);
      }

      await kindergarten.doc(chosenBill.kindergarten).collection('bills').doc(widget.date).collection(widget.date).doc(chosenBill.uid).update(guardianData);
      DocumentSnapshot kindergartenSnap = await kindergarten.doc(chosenBill.kindergarten).collection('bills').doc(widget.date).get();
      Map snappedData = kindergartenSnap.data();
      await kindergarten.doc(chosenBill.kindergarten).collection('bills').doc(widget.date).update({
        'totalBills':snappedData['totalBills']+guardianData['totalFee']-widget.bill.totalFee,
        'totalBillsStudents': snappedData['totalBillsStudents']+guardianData['noOfBills']-widget.bill.noOfBills,
        'totalUnPaid':snappedData['totalUnPaid']+guardianData['totalFee']-widget.bill.totalFee,
        'totalUnPaidStudents':snappedData['totalUnPaidStudents']+guardianData['noOfBills']-widget.bill.noOfBills
      });
      setState(() {
        chosenBill.totalFee=guardianData['totalFee'];
        chosenBill.billTime =guardianData['billTime'];
        list.clear();
        list.addAll(studentBills);
      });

    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to connect database',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.smaller);

    }
  }
}