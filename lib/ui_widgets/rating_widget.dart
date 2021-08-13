import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/texts.dart';

class RatingWidget extends StatefulWidget {
  Function onPressed;
  int value;
  RatingWidget({this.onPressed,this.value});
  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Radio(
                activeColor: ThemeColor.blueColor,
                value: 1,
                groupValue: widget.value,
                onChanged: widget.onPressed
            ),
            Text('1', style: smallerTextStyle(color: widget.value==1? ThemeColor.blueColor:ThemeColor.blueGreyColor),)
          ],
        ),
        Column(
          children: <Widget>[
            Radio(
                activeColor: ThemeColor.blueColor,
                value: 2,
                groupValue: widget.value,
                onChanged: widget.onPressed
            ),
            Text('2', style: smallerTextStyle(color: widget.value==2? ThemeColor.blueColor:ThemeColor.blueGreyColor),)
          ],
        ),
        Column(
          children: <Widget>[
            Radio(
                activeColor: ThemeColor.blueColor,
                value: 3,
                groupValue: widget.value,
                onChanged: widget.onPressed
            ),
            Text('3', style: smallerTextStyle(color: widget.value==3? ThemeColor.blueColor:ThemeColor.blueGreyColor),)
          ],
        ),
        Column(
          children: <Widget>[
            Radio(
                activeColor: ThemeColor.blueColor,
                value: 4,
                groupValue: widget.value,
                onChanged: widget.onPressed
            ),
            Text('4', style: smallerTextStyle(color: widget.value==4? ThemeColor.blueColor:ThemeColor.blueGreyColor),)
          ],
        ),
        Column(
          children: <Widget>[
            Radio(
                activeColor: ThemeColor.blueColor,
                value: 5,
                groupValue: widget.value,
                onChanged: widget.onPressed
            ),
            Text('5', style: smallerTextStyle(color:widget.value==5? ThemeColor.blueColor: ThemeColor.blueGreyColor),)
          ],
        ),
      ],
    );
  }
}
