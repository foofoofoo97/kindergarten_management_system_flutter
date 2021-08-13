import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  static double largest;
  static double ultraLarge;
  static double extraLarge;
  static double large;
  static double medium;
  static double mediumS;
  static double mediumSmall;
  static double small;
  static double smaller;
  static double extraSmall;
  static double ultraSmall;

  static SizedBox smallHorizontalBox;
  static SizedBox extraSmallHorizontalBox;
  static SizedBox mediumHorizontalBox;
  static SizedBox largeHorizontalBox;
  static SizedBox extraLargeHorizontalBox;

  static SizedBox smallVerticalBox;
  static SizedBox extraSmallVerticalBox;
  static SizedBox mediumVerticalBox;
  static SizedBox largeVerticalBox;
  static SizedBox extraLargeVerticalBox;
  static SizedBox ultraSmallVerticalBox;


  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth -
        _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight -
        _safeAreaVertical) / 100;

    ultraSmall = blockSizeHorizontal;
    extraSmall = blockSizeVertical*1.5;
    smaller = blockSizeVertical*1.75;
    small = blockSizeVertical*2;
    medium = blockSizeVertical*2.5;
    mediumS = blockSizeVertical*2.15;
    mediumSmall = blockSizeVertical*2.25;
    large = blockSizeVertical*3.0;
    extraLarge = blockSizeVertical*4;
    ultraLarge = blockSizeVertical*5;
    largest = blockSizeVertical*8;

    extraSmallHorizontalBox = SizedBox(
      width: blockSizeHorizontal,
    );
    smallHorizontalBox = SizedBox(
      width: blockSizeHorizontal*1.5,
    );
    mediumHorizontalBox = SizedBox(
      width: blockSizeHorizontal*2.5,
    );
    largeHorizontalBox = SizedBox(
      width:  blockSizeHorizontal*3.5,
    );
    extraLargeHorizontalBox = SizedBox(
      width: blockSizeHorizontal*5,
    );
    ultraSmallVerticalBox=SizedBox(
      height: blockSizeVertical*0.5,
    );
    extraSmallVerticalBox = SizedBox(
      height: blockSizeVertical,
    );
    smallVerticalBox = SizedBox(
      height: blockSizeVertical*1.5,
    );
    mediumVerticalBox = SizedBox(
      height: blockSizeVertical*2.5,
    );
    largeVerticalBox = SizedBox(
      height:  blockSizeVertical*3.5,
    );
    extraLargeVerticalBox = SizedBox(
      height: blockSizeVertical*5,
    );
  }
}
