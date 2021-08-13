import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_fees/add_new_fees_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:kiki/ui_widgets/info_message_dialog.dart';

class ManageFeesPage extends StatefulWidget {
  String kindergarten;
  ManageFeesPage({this.kindergarten});

  @override
  _ManageFeesPageState createState() => _ManageFeesPageState();
}

class _ManageFeesPageState extends State<ManageFeesPage> {

  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');
  CollectionReference student =
      FirebaseFirestore.instance.collection('student');

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map<int, String> typeToString = {
    0: 'Fees Applied To All Students',
    1: 'Fees Excluded To Selected Students',
    2: 'Fees Applied To Selected Students Only'
  };

  int open;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    open = 0;
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: kindergarten.doc(widget.kindergarten).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
          if (!documentSnapshot.hasData) {
            return Container(
              color: ThemeColor.whiteColor,
              child: Center(
                child: SizedBox(
                  height: SizeConfig.safeBlockVertical * 5,
                  width: SizeConfig.safeBlockVertical * 5,
                  child: CircularProgressIndicator(
                      backgroundColor: ThemeColor.whiteColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.blueColor)
                  ),
                ),
              ),
            );
          }
          else if (documentSnapshot.hasError) {
            Fluttertoast.showToast(msg: 'Failed to connect database',
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.blueColor)
                  ),
                ),
              ),
            );
          }
          Map data = Map.from(documentSnapshot.data.data()['fees type']);
          return Stack(
            children: <Widget>[
              Scaffold(
                key: _scaffoldKey,
                backgroundColor: ThemeColor.whiteColor,
                appBar: kiAppBar(AppBarType.backButton, context),
                body: Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.small,
                      right: SizeConfig.small,
                      top: SizeConfig.smaller),
                  child: Column(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizeConfig.mediumHorizontalBox,

                            Text(
                              'Manage Fees',
                              style: mediumSTextStyle(
                                  color: ThemeColor.themeBlueColor),
                            ),
                            SizeConfig.mediumHorizontalBox,
                            KiButton.smallButton(
                              child: Icon(
                                Icons.info,
                                size: SizeConfig.small * 1.1,
                                color: ThemeColor.themeBlueColor,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        InfoMessageDialog(
                                          info:
                                          'Single tap to expand and view included students. Long press to update selected fees.',
                                        ));
                              },
                            ),
                            Expanded(child: Container(),),
                            data.length==0? Container():KiButton.rectButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddNewFeesPage(
                                                onPressed: (String name,
                                                    Map temp) async {
                                                  data.addAll({name: temp});
                                                  await kindergarten
                                                      .doc(
                                                      documentSnapshot.data.data()['name'])
                                                      .update({
                                                    'fees type':
                                                    data
                                                  });
                                                },
                                              )));
                                },
                                color: ThemeColor.lightBlueColor,
                                child: Text(
                                  'Add',
                                  style: smallerTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                )),
                            SizeConfig.mediumHorizontalBox
                          ]),
                      data.length == 0
                          ? Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'No fees is added yet',
                                      style: smallTextStyle(
                                          color: ThemeColor.blueGreyColor),
                                    ),
                                    SizeConfig.mediumVerticalBox,
                                    KiButton.rectButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddNewFeesPage(
                                                        onPressed: (String
                                                        name,
                                                            Map temp) async {
                                                         data.putIfAbsent(
                                                                name,
                                                                    () =>
                                                                temp);
                                                          await kindergarten
                                                              .doc(
                                                              documentSnapshot.data.data()['name'])
                                                              .update({
                                                            'fees type':
                                                            data
                                                          });
                                                        },
                                                      )));
                                        },
                                        color: ThemeColor.lightBlueColor,
                                        child: Text(
                                          'Add',
                                          style: smallerTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor),
                                        )),
                                    SizeConfig.extraLargeVerticalBox,
                                    SizeConfig.extraLargeVerticalBox
                                  ])))
                          : Container(),
                      SizeConfig.extraSmallVerticalBox,
                      data.length == 0
                          ? Container()
                          : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, x) {
                            return Card(
                              color: ThemeColor.whiteColor,
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.extraSmall,
                                    horizontal: SizeConfig.small),
                                onLongPress: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddNewFeesPage(
                                                profile: documentSnapshot.data.data(),
                                                data: data.values.toList()[x],
                                                feeName: data.keys.toList()[x],
                                                onPressed: (String name,
                                                    Map temp) async {
                                                    data.remove(data.keys.toList()[x]);
                                                    data.putIfAbsent(name, () => temp);
                                                    await kindergarten
                                                      .doc(documentSnapshot.data.data()['name'])
                                                      .update({'fees type': data});
                                                },
                                              )));
                                },
                                trailing: KiButton.smallButton(
                                    child: Icon(
                                      Icons.close,
                                      color: ThemeColor.redColor,
                                      size: SizeConfig.medium,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      String chosen = data.keys.toList()[x];


                                      for (String uid
                                      in data.values
                                          .toList()[x]
                                      ['selected students']) {
                                        await student
                                            .doc(uid)
                                            .collection('fees')
                                            .doc(chosen)
                                            .delete();
                                      }
                                      data.remove(
                                          chosen);

                                      await kindergarten
                                          .doc(documentSnapshot.data.data()['name'])
                                          .update({
                                        'fees type':
                                        data
                                      });

                                      setState(() {
                                        isLoading = false;
                                      });
                                    }),
                                onTap: () {
                                  setState(() {
                                    if (open == x) {
                                      open = null;
                                    } else
                                      open = x;
                                  });
                                },
                                title: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Wrap(
                                          crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              data.keys
                                                  .toList()[x]
                                                  .toUpperCase(),
                                              style: smallerTextStyle(
                                                  color: ThemeColor
                                                      .blueColor),
                                            ),
                                            SizeConfig
                                                .mediumHorizontalBox,
                                            Text(
                                              'RM ${data.values.toList()[x]['amount']
                                                  .toStringAsFixed(2)}',
                                              style: smallerTextStyle(
                                                  color: ThemeColor
                                                      .themeBlueColor),
                                            ),
                                          ]),
                                      SizeConfig.ultraSmallVerticalBox,
                                      Text(
                                        '${typeToString[data.values
                                            .toList()[x]['type']]}',
                                        style: smallererTextStyle(
                                            color: ThemeColor
                                                .themeBlueColor),
                                      ),
                                    ]),
                                subtitle: open == x
                                    ? Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizeConfig
                                        .ultraSmallVerticalBox,
                                    Text(
                                      studentNames(
                                          data.values.toList()[x]),
                                      style: extraSmallTextStyle(
                                          color: ThemeColor
                                              .blueGreyColor),
                                    )
                                  ],
                                )
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              isLoading
                  ? Center(
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
          );
        });
  }

  String studentNames(Map data) {
    String temp = '';
    for (int x=0;x<data['selected students fname'].length;x++) {
      temp = '${data['selected students fname'][x]} ${data['selected students lname'][x]},  ' +
              temp;
    }
    temp = 'Selected students: ' + temp;
    return temp;
  }
}
