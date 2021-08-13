// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/face_recognition/db/database.dart';
import 'package:kiki/face_recognition/widgets/FacePainter.dart';
import 'package:kiki/face_recognition/widgets/auth-action-button.dart';
import 'package:kiki/face_recognition/services/camera.service.dart';
import 'package:kiki/face_recognition/services/facenet.service.dart';
import 'package:kiki/face_recognition/services/ml_vision_service.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:kiki/ui_components/layout_ui.dart';
import 'package:path/path.dart' show join;
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';

class StudentFaceRecognitionPage extends StatefulWidget {
  final CameraDescription cameraDescription;

  const StudentFaceRecognitionPage({
    Key key,
    @required this.cameraDescription,
  }) : super(key: key);

  @override
  StudentFaceRecognitionPageState createState() => StudentFaceRecognitionPageState();
}

class StudentFaceRecognitionPageState extends State<StudentFaceRecognitionPage> {
  /// Service injection
  CameraService _cameraService = CameraService();
  MLVisionService _mlVisionService = MLVisionService();
  FaceNetService _faceNetService = FaceNetService();

  DataBaseService _dataBaseService = DataBaseService();
  CameraDescription cameraDescription;

  Future _initializeControllerFuture;

  bool cameraInitializated = false;
  bool _detectingFaces = false;
  bool pictureTaked = false;
  bool isFront;

  // switchs when the user press the camera
  bool _saving = false;
  bool _bottomSheetVisible = false;

  bool isLoading;
  String imagePath;
  Size imageSize;
  Face faceDetected;

  @override
  void initState() {
    super.initState();
    isLoading=false;
    /// starts the camera & start framing faces
    _start();
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    super.dispose();
  }

  /// starts the camera & start framing faces
  _start() async {
    _initializeControllerFuture = _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlVisionService.getFacesFromImage(image);

          if (faces != null) {
            if (faces.length > 0) {
              // preprocessing the image
              setState(() {
                faceDetected = faces[0];
              });

              if (_saving) {
                _saving = false;
                _faceNetService.setCurrentPrediction(image, faceDetected);
              }

            } else {
              setState(() {
                faceDetected = null;
              });
            }
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  /// handles the button pressed event
  Future<void> onShot() async {

    if (faceDetected == null) {
      showDialog(
          context: context,
          builder: (context)=> AlertDialog(
            backgroundColor: ThemeColor.whiteColor,
            content: Text('No face is detected!',style: smallTextStyle(color: ThemeColor.themeBlueColor),),
          ));

      return false;
    } else {
      imagePath = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      _saving = true;

      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      await _cameraService.takePicture(imagePath);

      setState(() {
        _bottomSheetVisible = true;
        pictureTaked = true;
      });

      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
      return Stack(
        children: <Widget>[
          Scaffold(
            body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (pictureTaked) {
                  return Container(
                    width: width,
                    child: Transform(
                        alignment: Alignment.center,
                        child: Image.file(File(imagePath)),
                        transform: Matrix4.rotationY(mirror)),
                  );
                } else {
                  return Transform.scale(
                    scale: 1.0,
                    child: AspectRatio(
                      aspectRatio: MediaQuery.of(context).size.aspectRatio,
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Container(
                            width: width,
                            height: width / _cameraService.cameraController.value.aspectRatio,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                CameraPreview(_cameraService.cameraController),
                                CustomPaint(
                                  painter: FacePainter(face: faceDetected, imageSize: imageSize),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: !_bottomSheetVisible
              ? AuthActionButton(
                  _initializeControllerFuture,
                  onPressed: onShot,
                  onChecking: (bool value){
                    setState(() {
                      isLoading = value;
                    });
                  },
                  isLogin: true,
                )
              : Container(),
    ),
          isLoading
              ? Scaffold(
              backgroundColor:Colors.transparent,
              body:Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: SizeConfig.safeBlockVertical * 5,
                      width: SizeConfig.safeBlockVertical * 5,
                      child: CircularProgressIndicator(
                        backgroundColor: ThemeColor.whiteColor,
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.blueColor),
                      )),
                  SizeConfig.mediumVerticalBox,
                  Text('Is Checking In..', style: smallTextStyle(color: ThemeColor.blueColor),)
                ]
            ),
          )):Container()
        ],
      );
  }
}
