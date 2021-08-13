import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';

class KiButton {
  static GestureDetector smallButton({Widget child, Function onLongPressed,Function onDoublePressed,Function onPressed}) {
    return GestureDetector(
      child: child,
      onTap: onPressed,
      onLongPress: onLongPressed,
      onDoubleTap: onDoublePressed,
    );
  }

  static FlatButton rectButton(
      {Widget child, Function onPressed, Color color, EdgeInsets padding }) {
    return FlatButton(
      padding: padding,
      color: color,
      child: child,
      onPressed: onPressed,
    );
  }

  static FlatButton circleButton(
      {Widget child, Function onPressed, Color color, EdgeInsets padding}) {
    return FlatButton(
      onPressed: onPressed,
      child: child,
      shape: new CircleBorder(),
      color: color,
    );
  }

  static Row radioButton({List<bool> onClicked,List<String> text, List<String> values, Function onPressed, TextStyle style,Color color, Color activeColor, Color textColor, Color activeTextColor, EdgeInsets padding}) {
    List<Widget> radioButtons = new List(text.length);
    for(int x=0;x<text.length;x++){
      radioButtons[x]=rectButton(
        padding: padding,
        child: Text(text[x],style: style.copyWith(
          color: onClicked[x]?activeTextColor:textColor
        ),),
        color: onClicked[x]? activeColor:color,
        onPressed: (){
          onPressed(x);
        }
      );
    }
    return Row(
      children: radioButtons,
    );
  }
}

class KiTextField{
  static Column borderedTextFormField({
    TextInputType textInputType,
    TextStyle textStyle,
    Function onSaved,
    TextEditingController controller,
    String hintText,
    String titleText,
    Function onChanged,
    String errorText,
    Widget suffixWidget,
    bool obscureText =false,
    TextStyle errorStyle,
    TextStyle labelStyle,
    bool noError=true,
    bool filled =false,
    int maxLines =1,
    Color borderColor,
    Color activeBorderColor,
    double radius=5,
    TextStyle hintStyle,
    bool enabled =true,
    TextAlign textAlign = TextAlign.start
  }){
    return Column(
      children: <Widget>[
        TextFormField(
          enabled: enabled,
          textAlign: textAlign,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: textInputType,
          onSaved: onSaved,
          style: textStyle,
          onChanged: onChanged,
          controller: controller,
          decoration: InputDecoration(
            labelText: titleText,
            labelStyle: labelStyle,
            prefix: Wrap(
              children: <Widget>[
                SizeConfig.largeHorizontalBox
              ],
            ),
            hintText: hintText,
            hintStyle: hintStyle,
            filled: filled,
            fillColor: ThemeColor.blueGreyColor.withOpacity(0.16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: activeBorderColor, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(radius))
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(radius))
            ),

          ),
        ),
        noError? SizedBox():Text(errorText,style: errorStyle),
      ],
    );}
    static Column borderlessTextFormField({
      TextInputType textInputType,
      TextStyle textStyle,
      Function onSaved,
      TextEditingController controller,
      String hintText,
      String titleText,
      String errorText,
      Widget suffixWidget,
      bool obscureText =false,
      TextStyle errorStyle,
      TextStyle labelStyle,
      bool noError,
      bool filled =true,
      int maxLines =1,
      String initialValue,
      bool enabled =true,
      FloatingLabelBehavior floatingLabelBehavior=FloatingLabelBehavior.auto
    }){
      return Column(
        children: <Widget>[
          TextFormField(
            maxLines: maxLines,
            enabled: enabled,
            initialValue: initialValue,
            obscureText: obscureText,
            style: textStyle,
            keyboardType: textInputType,
            onSaved: onSaved,
            controller: controller,
            decoration: InputDecoration(
              labelText: titleText,
              labelStyle: labelStyle,
              prefix: Wrap(
                children: <Widget>[
                  SizeConfig.largeHorizontalBox
                ],
              ),
              hintText: hintText,
              hintStyle: textStyle.copyWith(color:ThemeColor.blueGreyColor),
              filled: filled,
              fillColor: ThemeColor.blueGreyColor.withOpacity(0.16),
              border:InputBorder.none,
              floatingLabelBehavior: floatingLabelBehavior
            ),
          ),
          noError? SizedBox():Text(errorText,style: errorStyle),
        ],
      );
}
}

