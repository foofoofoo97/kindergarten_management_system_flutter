import 'package:auto_size_text/auto_size_text.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:flutter/cupertino.dart';

TextStyle ultraLargeTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.ultraLarge,fontFamily: 'Lato');

TextStyle extraLargeTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.extraLarge,fontFamily: 'PottaOne');

TextStyle largeTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.large,fontFamily: 'PottaOne');

TextStyle mediumLargeTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.medium,fontFamily: 'PottaOne');

TextStyle mediumTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.medium,fontFamily: 'PatrickHand');

TextStyle mediumSTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.mediumS,fontFamily: 'PatrickHand');

TextStyle mediumSmallTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.mediumSmall,fontFamily: 'PatrickHand');

TextStyle smallTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.small,fontFamily: 'PatrickHand');

TextStyle smalllTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.small*0.95,fontFamily: 'PatrickHand');


TextStyle smallerTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.smaller,fontFamily: 'Lato');

TextStyle smallererTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.smaller*0.9,fontFamily: 'Lato');

TextStyle extraSmallTextStyle({Color color}) =>
    TextStyle(color: color, fontSize: SizeConfig.extraSmall,fontFamily: 'OpenSans');


AutoSizeText extraSmallTitleText({String text,Color color})=>
    AutoSizeText(
      text,
      style: extraSmallTextStyle(color: color),
      maxLines: 1,
      overflow: TextOverflow.fade,
      wrapWords: false,
    );

AutoSizeText smallerTitleText({String text,Color color})=>
    AutoSizeText(
      text,
      style: smallerTextStyle(color: color),
      maxLines: 1,
      overflow: TextOverflow.fade,
      wrapWords: false,
    );


AutoSizeText smallText({String text,Color color})=>
    AutoSizeText(
      text,
      style: smallTextStyle(color: color),
      maxLines: 1,
    );

AutoSizeText largeTitleText({String text,Color color})=>
    AutoSizeText(
      text,
      style: largeTextStyle(color: color),
      maxLines: 1,
    );
AutoSizeText extraLargeTitleText({String text,Color color})=>
    AutoSizeText(
      text,
      style: extraLargeTextStyle(color: color),
      maxLines: 1,
    );

AutoSizeText ultraLargeTitleText({String text,Color color})=>
    AutoSizeText(
      text,
      style:  TextStyle(color: color, fontSize: SizeConfig.ultraLarge,letterSpacing: 1.5),
      maxLines: 1,
    );

AutoSizeText largestTitleText({String text,Color color})=>
    AutoSizeText(
      text,
      style:  TextStyle(color: color, fontSize: SizeConfig.ultraLarge,letterSpacing: 1.7,fontFamily: 'PottaOne'),
      maxLines: 1,
    );

