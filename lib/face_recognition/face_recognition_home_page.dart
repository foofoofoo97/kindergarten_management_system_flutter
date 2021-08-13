import 'package:flutter/cupertino.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/face_recognition/db/database.dart';
import 'package:kiki/face_recognition/student_face_recognition_page.dart';
import 'package:kiki/face_recognition/sign-up.dart';
import 'package:kiki/face_recognition/services/facenet.service.dart';
import 'package:kiki/face_recognition/services/ml_vision_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:kiki/ui_components/layout_ui.dart';

class FaceRecognitionHomePage extends StatefulWidget {
  FaceRecognitionHomePage({Key key}) : super(key: key);
  @override
  _FaceRecognitionHomePageState createState() => _FaceRecognitionHomePageState();
}

class _FaceRecognitionHomePageState extends State<FaceRecognitionHomePage> {
  // Services injection
  FaceNetService _faceNetService = FaceNetService();
  MLVisionService _mlVisionService = MLVisionService();
  DataBaseService _dataBaseService = DataBaseService();

  CameraDescription cameraDescription;
  CameraDescription backCameraDescription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  /// 1 Obtain a list of the available cameras on the device.
  /// 2 loads the face net model
  _startUp() async {
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == CameraLensDirection.front,
    );

    await _startUp2();

    // start the services
    await _faceNetService.loadModel();
    await _dataBaseService.loadDB();
    _mlVisionService.initialize();

    _setLoading(false);
  }

  _startUp2()async{

    List<CameraDescription> cameras = await availableCameras();

    backCameraDescription = cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == CameraLensDirection.back,
    );
  }

  // shows or hides the circular progress indicator
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      appBar: kiAppBar(AppBarType.backButton, context),
      body: !loading
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(SizeConfig.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.face,color: ThemeColor.themeBlueColor,size: SizeConfig.extraLarge*2.7,),
                  SizeConfig.smallVerticalBox,
                  Text('Record Student Attendance \nThrough Face Recognition',
                    textAlign: TextAlign.center,
                    style: mediumSTextStyle(color: ThemeColor.themeBlueColor),),
                  SizeConfig.extraLargeVerticalBox,
                  KiButton.rectButton(
                    color: ThemeColor.blueColor,
                    child: Text('Front Camera',style: smallerTextStyle(color: ThemeColor.whiteColor),),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => StudentFaceRecognitionPage(
                            cameraDescription: cameraDescription,
                          ),
                        ),
                      );
                    },
                  ),
                  SizeConfig.extraSmallVerticalBox,
                  KiButton.rectButton(
                    color: ThemeColor.blueColor,
                    child: Text('Back Camera',style: smallerTextStyle(color: ThemeColor.whiteColor),),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => StudentFaceRecognitionPage(
                            cameraDescription: backCameraDescription,
                          ),
                        ),
                      );
                    },
                  ),
                  SizeConfig.extraSmallVerticalBox,
                  KiButton.rectButton(
                    color: ThemeColor.lightBlueGreyColor,
                    child: Text('Clean DB',style: smallerTextStyle(color: ThemeColor.themeBlueColor),),
                    onPressed: () {
                      _dataBaseService.cleanDB();
                    },
                  ),
                  SizeConfig.extraLargeVerticalBox,
                  SizeConfig.extraLargeVerticalBox
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
