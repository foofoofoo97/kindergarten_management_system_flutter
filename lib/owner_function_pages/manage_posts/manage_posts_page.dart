import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/models/Post.dart';
import 'package:intl/intl.dart';
import 'file:///C:/Users/foofoofoo/AndroidStudioProjects/kiki/lib/owner_function_pages/manage_posts/add_posts_page.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/full_photo_page.dart';

class ManagePostsPage extends StatefulWidget {
  @override
  _ManagePostsPageState createState() => _ManagePostsPageState();
}

class _ManagePostsPageState extends State<ManagePostsPage> {
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CollectionReference kindergarten = FirebaseFirestore.instance.collection('kindergarten');

  List<Post> posts = new List.from([]);


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: kindergarten.doc(kindergartenProfile.name).collection('posts').orderBy('datetime',descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> querySnapshot) {
          if (!querySnapshot.hasData) {
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
          else if (querySnapshot.hasError) {
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

          return Scaffold(
            key: _scaffoldKey,
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left:SizeConfig.small,right: SizeConfig.small,top: SizeConfig.smaller),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'View Posts',
                      style: smallTextStyle(
                          color: ThemeColor.themeBlueColor),
                      textAlign: TextAlign.start,
                    ),
                    SizeConfig.smallVerticalBox,
                    querySnapshot.data.docs.length==0?Container(
                      height: SizeConfig.safeBlockVertical*50,
                      child: Center(
                        child: Text(
                        'No Post Yet',style: smallTextStyle(color: ThemeColor.blueGreyColor))),
                    ):ListView.builder(
                      //reverse: true,
                      physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
                        itemCount: querySnapshot.data.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, x) {
                          return Column(
                            children: <Widget>[
                              Card(
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                color: ThemeColor.whiteColor,
                                child: Padding(
                                  padding: EdgeInsets.all(SizeConfig.smaller),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end,
                                        children: <Widget>[
                                          KiButton.smallButton(
                                              child: Icon(Icons.close,
                                                color: ThemeColor.redColor,
                                                size: SizeConfig.medium,),
                                              onPressed: () async {
                                                try {
                                                  await kindergarten.doc(
                                                      '${kindergartenProfile
                                                          .name}').collection(
                                                      'posts')
                                                      .doc(querySnapshot.data.docs[x].id)
                                                      .delete();

                                                  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                    backgroundColor: ThemeColor
                                                        .themeBlueColor
                                                        .withOpacity(0.8),
                                                    content: Text(
                                                      'Post deleted successfully',
                                                      style: extraSmallTextStyle(
                                                          color: ThemeColor
                                                              .whiteColor),
                                                    ),
                                                  ));
                                                } catch (e) {
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                    backgroundColor: ThemeColor
                                                        .themeBlueColor
                                                        .withOpacity(0.8),
                                                    content: Text(
                                                      'Internet connection failed. Please try again',
                                                      style: extraSmallTextStyle(
                                                          color: ThemeColor
                                                              .whiteColor),
                                                    ),
                                                  ));
                                                }
                                              }
                                          )
                                        ],
                                      ),
                                      SizeConfig.extraSmallVerticalBox,
                                      KiButton.smallButton(
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: SizeConfig
                                                .blockSizeHorizontal * 100,
                                            height: SizeConfig
                                                .safeBlockVertical * 30,
                                            child: CachedNetworkImage(
                                                imageUrl: querySnapshot.data.docs[x].data()['image url'],
                                                progressIndicatorBuilder: (
                                                    context, url,
                                                    downloadProgress) =>
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress),
                                                errorWidget: (context, url,
                                                    error) =>
                                                    Icon(Icons.error),
                                                fit: BoxFit.fitWidth
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullPhoto(
                                                            url: querySnapshot.data.docs[x].data()['image url'])));
                                          }
                                      ),
                                      SizeConfig.smallVerticalBox,
                                      Text(
                                        DateFormat("dd-MM-yyyy H:m").format(
                                            querySnapshot.data.docs[x].data()['datetime'].toDate()),
                                        style: smallerTextStyle(
                                            color: ThemeColor.blueColor),
                                        textAlign: TextAlign.end,),
                                      SizeConfig.extraSmallVerticalBox,
                                      Text(querySnapshot.data.docs[x].data()['description'],
                                          style: smallerTextStyle(
                                              color: ThemeColor
                                                  .themeBlueColor)),
                                      SizeConfig.extraSmallVerticalBox,
                                      Text(getTextName(querySnapshot.data.docs[x].data()),
                                        style: extraSmallTextStyle(
                                            color: ThemeColor.blueGreyColor),)
                                    ],
                                  ),
                                ),
                              ),
                              SizeConfig.smallVerticalBox,
                              x == querySnapshot.data.docs.length - 1 ? SizeConfig
                                  .extraLargeVerticalBox : Container()
                            ],
                          );
                        }),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: "post float",
              child: Icon(
                Icons.add,
                color: ThemeColor.whiteColor,
              ),
              backgroundColor: ThemeColor.themeBlueColor,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddPostPage()));
              },
              elevation: 15.0,
            ),
          );
        } );
  }

  String getTextName(Map data){
    String name ='';
    for(int x=0;x<List.from(data['tagged first name']).length;x++){
      name= name+'${List.from(data['tagged first name'])[x]} ${List.from(data['tagged last name'])[x]} ';
    }
    return name;
  }

}
