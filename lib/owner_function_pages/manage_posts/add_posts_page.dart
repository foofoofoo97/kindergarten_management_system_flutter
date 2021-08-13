import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/contents/validators.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/design_ui.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kiki/ui_widgets/search_students_dialog.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  KindergartenProfile kindergartenProfile = new KindergartenProfile();
  CollectionReference kindergarten =
      FirebaseFirestore.instance.collection('kindergarten');

  bool isLoading;
  File _image;
  bool noDescriptionError;
  TextEditingController descriptionController = new TextEditingController();
  List<Widget> tags = List.from([]);
  List<String> taggedStudentUID = List.from([]);
  List<String> taggedStudentFName = List.from([]);
  List<String> taggedStudentLName = List.from([]);
  String url;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noDescriptionError = true;
    isLoading = false;
    tags.add(blankContainer());
  }

  Future<void> getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery,imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
          content: Text(
            'Cannot access to gallery. Please try again',
            style: extraSmallTextStyle(color: ThemeColor.whiteColor),
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KiCenterPage(
            scaffoldKey: _scaffoldKey,
            color: ThemeColor.whiteColor,
            appBarType: AppBarType.backButton,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.small),
              child: Column(
                children: <Widget>[
                   _image==null?Text(
                          'Add Post',
                          style:
                              mediumSmallTextStyle(color: ThemeColor.themeBlueColor),
                        ):Container(),
                  SizeConfig.smallVerticalBox,
                  Container(
                    padding: EdgeInsets.all(SizeConfig.small),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _image == null
                            ? Container(
                                color:
                                    ThemeColor.blueGreyColor.withOpacity(0.12),
                                height: SizeConfig.safeBlockVertical * 25,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.image,
                                        color: ThemeColor.blueGreyColor,
                                        size: SizeConfig.extraLarge,
                                      ),
                                      SizeConfig.extraSmallVerticalBox,
                                      Text(
                                        'No Image Selected.',
                                        style: smallerTextStyle(
                                            color: ThemeColor.blueGreyColor),
                                      ),
                                      SizeConfig.mediumVerticalBox,
                                      KiButton.smallButton(
                                          child: Icon(
                                            Icons.add_circle_outline,
                                            color: ThemeColor.blueGreyColor,
                                            size: SizeConfig.extraLarge,
                                          ),
                                          onPressed: () async {
                                            await getImage();
                                          }),
                                    ],
                                  ),
                                ),
                              )
                            : Image.file(_image),
                        SizeConfig.smallVerticalBox,
                        _image == null
                            ? Container()
                            : KiButton.smallButton(
                                child: Text(
                                  'Change Image',
                                  style: smallerTextStyle(
                                      color: ThemeColor.themeBlueColor),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  await getImage();
                                }),
                        SizeConfig.smallVerticalBox,
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.extraSmall,
                              horizontal: SizeConfig.smaller),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                  color: ThemeColor.blackColor, width: 1.0)),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Tag Students',
                                    style: smallerTextStyle(
                                        color: ThemeColor.themeBlueColor),
                                  ),
                                  KiButton.smallButton(
                                      child: Card(
                                        elevation: 6.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        color: ThemeColor.whiteColor,
                                        child: Padding(
                                            padding: EdgeInsets.all(
                                                SizeConfig.safeBlockVertical),
                                            child: Text('Add',
                                                style: smallerTextStyle(
                                                    color: ThemeColor
                                                        .themeBlueColor))),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                SearchStudentsDialog(
                                                  uid: taggedStudentUID,
                                                  onPressed: (value) {
                                                    taggedStudentLName.clear();
                                                    taggedStudentFName.clear();
                                                    taggedStudentUID.clear();
                                                    setState(() {
                                                      tags.clear();
                                                      tags.add(
                                                          blankContainer());
                                                    });

                                                    for (int x = 0;
                                                        x < value.length;
                                                        x++) {
                                                      if (value[x]) {
                                                        taggedStudentUID.add(
                                                            kindergartenProfile
                                                                .studentUID[x]);
                                                        taggedStudentFName.add(
                                                            kindergartenProfile
                                                                .studentFirstName[x]);
                                                        taggedStudentLName.add(
                                                            kindergartenProfile
                                                                .studentLastName[x]);
                                                      }
                                                    }
                                                    for (int x = 0;
                                                        x <
                                                            taggedStudentUID
                                                                .length;
                                                        x++) {
                                                      setState(() {
                                                        tags.add(Card(
                                                            elevation: 8.0,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            color: ThemeColor
                                                                .whiteColor,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .all(SizeConfig
                                                                      .ultraSmall),
                                                              child: Text(
                                                                '${taggedStudentFName[x]} ${taggedStudentLName[x]}',
                                                                style: smallerTextStyle(
                                                                    color: ThemeColor
                                                                        .themeBlueColor),
                                                              ),
                                                            )));
                                                      });
                                                    }
                                                  },
                                                ));
                                      })
                                ],
                              ),
                              SizeConfig.extraSmallVerticalBox,
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: tags,
                              )
                            ],
                          ),
                        ),
                        SizeConfig.smallVerticalBox,
                        Form(
                          key: _formKey,
                            child:KiTextField.borderedTextFormField(
                            controller: descriptionController,
                            titleText: 'Description',
                            hintText: 'Enter description',
                            maxLines: 3,
                            activeBorderColor: ThemeColor.themeBlueColor,
                            borderColor: ThemeColor.blackColor,
                            onSaved: (value) {
                              setState(() {
                                noDescriptionError =
                                    Validators.compulsoryValidator(value);
                              });
                            },
                            noError: noDescriptionError,
                            errorText: 'Description should not be empty',
                            errorStyle: extraSmallTextStyle(
                                color: ThemeColor.blueGreyColor),
                            textStyle: smallerTextStyle(
                                color: ThemeColor.themeBlueColor),
                            labelStyle: smallerTextStyle(
                                color: ThemeColor.themeBlueColor))),
                        SizeConfig.smallVerticalBox,
                        KiButton.rectButton(
                            onPressed: () async {
                              _formKey.currentState.save();
                              if (_image != null &&noDescriptionError&&tags.length>0) {
                                setState(() {
                                  isLoading = true;
                                });
                                url = await uploadImageToFirebase(context);
                                if (url != null) {
                                  writeDatabase();
                                  Navigator.pop(context);
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    backgroundColor: ThemeColor.themeBlueColor
                                        .withOpacity(0.8),
                                    content: Text(
                                        'Please do not leave any field empty',
                                        style: extraSmallTextStyle(
                                            color: ThemeColor.whiteColor))));
                              }
                            },
                            color: ThemeColor.themeBlueColor,
                            child: Text(
                              'Add Post',
                              style:
                                  smallTextStyle(color: ThemeColor.whiteColor),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            )),
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
  }

  Future<void> writeDatabase() async {
    DateTime now = DateTime.now();
    try {
      await kindergarten
          .doc(kindergartenProfile.name)
          .collection('posts')
          .doc()
          .set({
        'datetime':now,
        'description': descriptionController.text.toString(),
        'tagged uid': taggedStudentUID,
        'tagged first name': taggedStudentFName,
        'tagged last name': taggedStudentLName,
        'image url': url
      });
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
          content: Text(
            'Database update failed. Please try again later',
            style: extraSmallTextStyle(color: ThemeColor.whiteColor),
          )));
    }
  }

  Future<dynamic> uploadImageToFirebase(BuildContext context) async {
    try {
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child("posts/${basename(_image.path)}");
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      StorageTaskSnapshot _snapshot = await uploadTask.onComplete;
        return await _snapshot.ref.getDownloadURL();

    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ThemeColor.themeBlueColor.withOpacity(0.8),
        content: Text(
          'Image upload failed. Please try again later',
          style: extraSmallTextStyle(color: ThemeColor.whiteColor),
        ),
      ));
    }
    return null;
  }
}
