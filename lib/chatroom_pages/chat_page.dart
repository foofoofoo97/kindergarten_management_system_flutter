import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kiki/chatroom_pages/full_video_page.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_widgets/full_photo_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerName;
  final String peerType;
  final String type;
  final String uid;
  Chat(
      {Key key,
      @required this.peerType,
      @required this.type,
      @required this.uid,
      @required this.peerId,
      @required this.peerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ThemeColor.themeBlueColor,
          title: Text(
            peerName,
            style: mediumTextStyle(color: ThemeColor.whiteColor)
                .copyWith(letterSpacing: 1.2),
          ),
          centerTitle: true,
          leading: KiButton.smallButton(
              child: Icon(
                Icons.arrow_back_ios,
                color: ThemeColor.whiteColor,
                size: SizeConfig.medium,
              ),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: ChatScreen(
        peerId: peerId,
        uid: uid,
        peerType: peerType,
        type: type,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String uid;
  final String peerType;
  final String type;

  ChatScreen(
      {Key key,
      @required this.peerType,
      @required this.type,
      @required this.peerId,
      @required this.uid})
      : super(key: key);

  @override
  State createState() =>
      ChatScreenState(peerId: peerId, uid: uid, peerType: peerType, type: type);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.uid,
      @required this.peerType,
      @required this.type});

  String peerType;
  String type;
  String peerId;
  String uid;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  File videoFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  String videoUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    setGroupChatID();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  setGroupChatID() async {
    prefs = await SharedPreferences.getInstance();
    if (uid.hashCode < peerId.hashCode) {
      groupChatId = '$uid-$peerId $type-$peerType';
    } else if (uid.hashCode > peerId.hashCode) {
      groupChatId = '$peerId-$uid $peerType-$type';
    } else {
      String code = '';
      if (peerType == 'owner' || type == 'owner') {
        code = 'owner-';
        if (peerType == 'owner')
          code = code + type;
        else
          code = code + peerType;
      } else if (type == 'employee' || peerType == 'employee') {
        code = 'employee-';
        if (peerType == 'employee')
          code = code + type;
        else
          code = code + peerType;
      }
      groupChatId = '$peerId-$uid $code';
      setState(() {});
    }

    FirebaseFirestore.instance
        .collection(type)
        .doc(uid)
        .update({'chat with': peerId});
  }

  Future getVideo() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getVideo(source: ImageSource.gallery);
    videoFile = File(pickedFile.path);

    if (videoFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadVideoFile();
    }
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery,imageQuality: 50);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadImageFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadVideoFile() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference =
          FirebaseStorage.instance.ref().child('chat/$fileName');
      StorageUploadTask uploadTask = reference.putFile(videoFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      videoUrl = await storageTaskSnapshot.ref.getDownloadURL();

      Fluttertoast.showToast(
          msg: 'Video uploaded',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.extraSmall);

      setState(() {
        isLoading = false;
        onSendMessage(videoUrl, 3);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: 'Failed in uploading video',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.extraSmall);
    }
  }

  Future uploadImageFile() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference =
          FirebaseStorage.instance.ref().child('chat/$fileName');
      StorageUploadTask uploadTask = reference.putFile(imageFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      imageUrl = await storageTaskSnapshot.ref.getDownloadURL();

      Fluttertoast.showToast(
          msg: 'Image uploaded',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.extraSmall);

      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: 'Failed in uploading image',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.extraSmall);
    }
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('message')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': uid,
            'idFromType': this.type,
            'idToType': peerType,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: ThemeColor.themeBlueColor,
          textColor: ThemeColor.whiteColor,
          fontSize: SizeConfig.extraSmall);
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == uid &&
        document.data()['idFromType'] == type) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document.data()['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document.data()['content'],
                    style: TextStyle(color: ThemeColor.themeBlueColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: ThemeColor.lightBlueColor,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document.data()['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            progressIndicatorBuilder: (context, url,downloadProgress) => Container(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeColor.blueColor),
                                  value: downloadProgress.progress),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: ThemeColor.lightBlueColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document.data()['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullPhoto(
                                      url: document.data()['content'])));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : document.data()['type'] == 2
                      ? Container(
                          child: Image.asset(
                            'images/${document.data()['content']}.gif',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),
                        )
                      : Container(
                          child: FlatButton(
                            child: Material(
                              child: Container(
                                  width: 150.0,
                                  height: 150.0,
                                  child: Image.asset('images/video_icon.png'),
                                  decoration: BoxDecoration(
                                    color: ThemeColor.lightBlueGreyColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullVideoPage(
                                          url: document.data()['content'])));
                            },
                            padding: EdgeInsets.all(0),
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),
                        )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: Icon(
                          Icons.person,
                          size: SizeConfig.medium,
                          color: ThemeColor.lightBlueColor2,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: SizeConfig.medium),
                document.data()['type'] == 0
                    ? Container(
                        child: Text(
                          document.data()['content'],
                          style: TextStyle(color: ThemeColor.themeBlueColor),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: ThemeColor.lightBlueColor2,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document.data()['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  progressIndicatorBuilder: (context, url,downloadProgress) => Container(
                                    child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                            ThemeColor.blueColor),
                                        value: downloadProgress.progress),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: ThemeColor.lightBlueColor2,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.data()['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document.data()['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        :document.data()['type'] == 2? Container(
                            child: Image.asset(
                              'images/${document.data()['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                               // bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                left: 10.0),
                          ):Container(
                  child: FlatButton(
                    child: Material(
                      child: Container(
                        width: 150.0,
                        height: 150.0,
                        child: Image.asset('images/video_icon.png'),
                        decoration: BoxDecoration(
                          color: ThemeColor.lightBlueGreyColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullVideoPage(
                                  url: document.data()['content'])));
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  margin: EdgeInsets.only(
                     // bottom: 10.0,
                      left: 10.0),
                ),
              ],
            ),
            SizeConfig.ultraSmallVerticalBox,
            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM yyyy kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document.data()['timestamp']))),
                      style: TextStyle(
                          color: ThemeColor.blueGreyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
                listMessage != null &&
                listMessage[index - 1].data()['idFrom'] == uid) &&
            listMessage[index - 1].data()['idFromType'] == type ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
                listMessage != null &&
                listMessage[index - 1].data()['idFrom'] != uid) &&
            listMessage[index - 1].data()['idFromType'] != type ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: ThemeColor.blueGreyColor, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.extraSmall),
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: KiButton.smallButton(
                child: Icon(
                  Icons.image,
                  size: SizeConfig.medium,
                  color: ThemeColor.blueColor,
                ),
                onPressed: getImage,
              ),
            ),
            color: ThemeColor.whiteColor,
          ),
          Material(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.extraSmall),
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: KiButton.smallButton(
                child: Icon(
                  Icons.video_library,
                  size: SizeConfig.medium,
                  color: ThemeColor.blueColor,
                ),
                onPressed: getVideo,
              ),
            ),
            color: ThemeColor.whiteColor,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.tag_faces, size: SizeConfig.medium),
                onPressed: getSticker,
                color: ThemeColor.blueColor,
              ),
            ),
            color: ThemeColor.whiteColor,
          ),
          // Edit text
          SizeConfig.extraSmallHorizontalBox,
          Expanded(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: smallerTextStyle(color: ThemeColor.themeBlueColor),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: ThemeColor.blueColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: ThemeColor.blueGreyColor, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ThemeColor.blueColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('message')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColor.blueColor)));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.blueColor),
        ),
      ),
      color: Colors.white.withOpacity(0.7),
    );
  }
}
