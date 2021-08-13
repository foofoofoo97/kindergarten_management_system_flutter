import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/Guardian.dart';
import 'package:kiki/models/Post.dart';
import 'package:intl/intl.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/full_photo_page.dart';

class ViewPostsPage extends StatefulWidget {
  @override
  _ViewPostsPageState createState() => _ViewPostsPageState();
}

class _ViewPostsPageState extends State<ViewPostsPage> {
  GuardianProfile guardianProfile = new GuardianProfile();
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  Map<String, dynamic> postsByStudent = new Map();
  List<Post> posts = new List.from([]);
  bool isLoading;
  int kindergartenLength;
  List<String> kindergartenSet = new List.from([]);
  List<DateTime> checker = new List.from([]);

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    kindergartenSet = guardianProfile.childrenKindergarten.toSet().toList();
    kindergartenLength = kindergartenSet.length;

    for (int x = 0; x < kindergartenLength; x++) {
      init(x);
    }
    super.initState();
  }

  Future<void> init(int index) async {
    QuerySnapshot querySnapshot = await kindergarten
        .doc(kindergartenSet[index])
        .collection('posts')
        .orderBy('datetime', descending: true)
        .get();
    if (querySnapshot != null &&
        querySnapshot.docs != null &&
        querySnapshot.docs.length > 0) {
      querySnapshot.docs.forEach((doc) {
        for (String uid in guardianProfile.childrenUID) {
          if (doc.data()['tagged uid'].contains(uid)) {
            Post post = new Post();
            List<Post> temp = new List.from([]);
            post.dateTime = doc.data()['datetime'].toDate();
            post.description = doc.data()['description'];
            post.uid = List.from(doc.data()['tagged uid']);
            post.firstName = List.from(doc.data()['tagged first name']);
            post.lastName = List.from(doc.data()['tagged last name']);
            post.url = doc.data()['image url'];
            post.kindergarten = kindergartenSet[index];
            if (postsByStudent.containsKey(uid)) {
              temp = postsByStudent[uid];
              temp.add(post);
              postsByStudent[uid] = temp;
            } else {
              temp.add(post);
              postsByStudent.putIfAbsent(uid, () => temp);
            }
            if (!checker.contains(post.dateTime)) {
              print(true);
              checker.add(post.dateTime);
              posts.add(post);
            }
          }
        }
      });
    }
    setState(() {
      isLoading = false;
    });
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
          )
        : DefaultTabController(
          length:
              isLoading ? 0 : guardianProfile.childrenFirstName.length + 1,
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
                          tabs: isLoading ? new List.from([]) : generateTabBar()),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: isLoading ? new List.from([]) : generateTabViews(),
            ),
          ),
        );
  }

  List<Tab> generateTabBar() {
    List<Tab> list = new List.from([]);
    for (int x = 0; x < (guardianProfile.childrenFirstName.length + 1); x++) {
      list.add(
        Tab(
          child: Text(
            x == 0
                ? 'All Children'
                : '${guardianProfile.childrenFirstName[x - 1]} ${guardianProfile.childrenLastName[x - 1]}',
            style: TextStyle(letterSpacing: 1.2),
          ),
        ),
      );
    }
    return list;
  }

  List<Widget> generateTabViews() {
    List<Widget> list = new List.from([]);
    for (int x = 0; x < (guardianProfile.childrenFirstName.length + 1); x++) {
      list.add(tabContentViews(x));
    }
    return list;
  }

  Widget tabContentViews(int index) {
    return Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      body: RefreshIndicator(
        onRefresh: ()async{

          posts.clear();
          kindergartenSet.clear();
          checker.clear();
          postsByStudent.clear();

          kindergartenSet =
              guardianProfile.childrenKindergarten.toSet().toList();
          kindergartenLength = kindergartenSet.length;

          for (int x = 0; x < kindergartenLength; x++) {
            await init(x);
          }
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.small,
                right: SizeConfig.small,
                top: SizeConfig.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    index == 0
                        ? 'All Posts'
                        : 'Posts Tagged ${guardianProfile.childrenFirstName[index - 1]} ${guardianProfile.childrenLastName[index - 1]}',
                    style: smallTextStyle(color: ThemeColor.themeBlueColor)),
                SizeConfig.ultraSmallVerticalBox,
                index == 0
                    ? Text(
                  'Swipe down to refresh posts',style: smallererTextStyle(color: ThemeColor.blueGreyColor),
                )
                    : Text(
                        guardianProfile.childrenKindergarten[index - 1],
                        style: smallererTextStyle(color: ThemeColor.blueColor),
                      ),
                SizeConfig.ultraSmallVerticalBox,
                index == 0
                    ? posts.length == 0
                        ? Container(
                            height: SizeConfig.safeBlockVertical * 70,
                            child: Center(
                                child: Text('No Posts Yet',
                                    style: smallTextStyle(
                                        color: ThemeColor.blueGreyColor))))
                        : getContentWidget(index)
                    : !postsByStudent.containsKey(
                                guardianProfile.childrenUID[index - 1]) ||
                            (postsByStudent[
                                        guardianProfile.childrenUID[index - 1]])
                                    .length ==
                                0
                        ? Container(
                            height: SizeConfig.safeBlockVertical * 70,
                            child: Center(
                                child: Text('No Posts Yet',
                                    style: smallTextStyle(
                                        color: ThemeColor.blueGreyColor))))
                        : getContentWidget(index)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getContentWidget(int index) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
          // reverse: true,
          physics:const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
          itemCount: index == 0
              ? posts.length
              : postsByStudent[guardianProfile.childrenUID[index - 1]].length,
          shrinkWrap: true,
          itemBuilder: (context, x) {
            List<Post> postCopy = index == 0
                ? posts
                : postsByStudent[guardianProfile.childrenUID[index - 1]];
            return Column(
              children: <Widget>[
                Card(
                  elevation: 12.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: ThemeColor.whiteColor,
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.smaller),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        KiButton.smallButton(
                            child: Container(
                              alignment: Alignment.center,
                              width: SizeConfig.blockSizeHorizontal * 100,
                              height: SizeConfig.safeBlockVertical * 30,
                              child: CachedNetworkImage(
                                  imageUrl: postCopy[x].url,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  fit: BoxFit.fitWidth),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FullPhoto(url: posts[x].url)));
                            }),
                        SizeConfig.smallVerticalBox,
                        Text(
                          '${postCopy[x].kindergarten}  ${DateFormat("dd-MM-yyyy H:m").format(postCopy[x].dateTime)}',
                          style: smallerTextStyle(color: ThemeColor.blueColor),
                          textAlign: TextAlign.end,
                        ),
                        SizeConfig.extraSmallVerticalBox,
                        Text(postCopy[x].description,
                            style: smallerTextStyle(
                                color: ThemeColor.themeBlueColor)),
                        SizeConfig.extraSmallVerticalBox,
                        Text(
                          getTextName(x, postCopy),
                          style: extraSmallTextStyle(
                              color: ThemeColor.blueGreyColor),
                        )
                      ],
                    ),
                  ),
                ),
                SizeConfig.smallVerticalBox,
              ],
            );
          }),
    );
  }

  String getTextName(int index, List<Post> postCopy) {
    String name = '';
    for (int x = 0; x < postCopy[index].firstName.length; x++) {
      name = name +
          '${postCopy[index].firstName[x]} ${postCopy[index].lastName[x]} ';
    }
    return name;
  }
}
