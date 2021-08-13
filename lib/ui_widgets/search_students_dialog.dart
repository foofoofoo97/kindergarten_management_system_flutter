import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/models/KindergartenProfile.dart';
import 'package:kiki/ui_components/functional_ui.dart';

class SearchStudentsDialog extends StatefulWidget {

  Function onPressed;
  List uid;
  SearchStudentsDialog({this.uid,this.onPressed});

  @override
  _SearchStudentsDialogState createState() => _SearchStudentsDialogState();
}

class _SearchStudentsDialogState extends State<SearchStudentsDialog> {

  KindergartenProfile kindergartenProfile = new KindergartenProfile();

  Map<int,List<int>> ageMap = new Map();
  List<bool> selectedList = new List.from([]);
  Map<int,dynamic> duplicateName = new Map();
  Map<int,bool> selectedAll = new Map();
  List<Widget> ageWidgets = new List.from([]);
  TextEditingController searchController = new TextEditingController();
  var items =new Map<int,dynamic>();


  @override
  void initState() {
    // TODO: implement initState
    init();
    if(widget.uid.length>0)
      init2();
    items.addAll(duplicateName);
    super.initState();
  }

  void init2(){
    Map<int,int> recorder = new Map();
    for(String uid in widget.uid) {
      int x = kindergartenProfile.studentUID.indexOf(uid);
      selectedList[x] = true;
      int age = kindergartenProfile.studentAge[x];
      if (recorder.containsKey(age)){
        int temp =recorder[age];
        temp=temp+1;
        recorder[age]=temp;
      }
      else{
       recorder.putIfAbsent(age, () => 1);
      }
    }
    for(int age in recorder.keys){
      if(recorder[age]==ageMap[age].length){
        selectedAll[age]=true;
      }
    }
  }

  void init(){
    for(int x=0;x<kindergartenProfile.studentAge.length;x++){
      int age = kindergartenProfile.studentAge[x];
      Map tempMap = new Map();
      tempMap.putIfAbsent('name', () => '${kindergartenProfile.studentFirstName[x]} ${kindergartenProfile.studentLastName[x]}');
      tempMap.putIfAbsent('age', () => kindergartenProfile.studentAge[x]);
      duplicateName.putIfAbsent(x, () => tempMap);
      selectedList.add(false);
      if(ageMap.containsKey(age)) {
         List<int> temp =ageMap[age];
         temp.add(x);
        }
      List<int> temp = [];
      temp.add(x);
      ageMap.putIfAbsent(age, () => temp);
    }
  }

  void buildAllAgesWidgets(){
    ageWidgets.clear();
    List<int> keys = ageMap.keys.toList()..sort();
    for(int age in keys){
      selectedAll.putIfAbsent(age, () => false);
      List<int> students = ageMap[age];
      ageWidgets.add(Card(
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: selectedAll[age]?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockVertical),
          child: KiButton.smallButton(
            child: Text('$age Years Old (${students.length})',
              style: smallerTextStyle(color: selectedAll[age]?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
            onPressed: (){
              setState(() {
                selectedAll[age]=!selectedAll[age];
              });
              for(int student in students){
                setState(() {
                  selectedList[student]=selectedAll[age];
                });
              }
            },
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    buildAllAgesWidgets();
    return  Dialog(
      backgroundColor: ThemeColor.whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      elevation: 16,
      child: Container(
          padding: EdgeInsets.all(SizeConfig.small),
          height: SizeConfig.safeBlockVertical *65,
          width: SizeConfig.blockSizeHorizontal *100,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                KiButton.smallButton(
                  child: Icon(Icons.close,color: ThemeColor.redColor,size: SizeConfig.medium,),
                  onPressed: (){
                    Navigator.pop(context);
                  }
                )
              ],),
              Text('Tag Students',style: smallTextStyle(color: ThemeColor.themeBlueColor),),
              SizeConfig.smallVerticalBox,
              Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                runSpacing: SizeConfig.ultraSmall,
                spacing: SizeConfig.extraSmall,
                children:ageWidgets,
              ),
              SizeConfig.mediumVerticalBox,
              KiTextField.borderedTextFormField(
                  controller: searchController,
                  titleText: 'Search',
                  hintText: 'Search student, age',
                  maxLines: 1,
                  onChanged: (value){
                    filterSearchResults(value);
                  },
                  hintStyle: smallerTextStyle(color: ThemeColor.blueGreyColor),
                  activeBorderColor: ThemeColor.themeBlueColor,
                  borderColor: ThemeColor.blueGreyColor,
                  radius: 25.0,
                  textStyle: smallerTextStyle(color: ThemeColor.themeBlueColor),
                  labelStyle: smallerTextStyle(color: ThemeColor.themeBlueColor)),
              SizeConfig.smallVerticalBox,
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, x) {
                    int index = items.keys.toList()[x];
                    return KiButton.smallButton(
                      onPressed: (){
                          setState(() {
                            selectedList[index]=!selectedList[index];
                          });
                          if(selectedAll[kindergartenProfile.studentAge[index]]){
                             setState(() {
                               selectedAll[kindergartenProfile.studentAge[index]]=false;
                             });
                          }
                          else{
                            List<int> other=ageMap[kindergartenProfile.studentAge[index]];
                            bool allSelected=true;
                            for(int no in other){
                              if(!selectedList[no]) {
                                allSelected=false;
                                break;
                              }
                            }
                            if(allSelected){
                              setState(() {
                                selectedAll[kindergartenProfile.studentAge[index]]=true;
                              });}
                          }
                      },
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: selectedList[index]?ThemeColor.lightBlueColor:ThemeColor.whiteColor,
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.extraSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                             Text('${items.values.toList()[x]['name']}',style:
                              smallerTextStyle(color: selectedList[index]?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                             SizeConfig.ultraSmallVerticalBox,
                             Text('${items.values.toList()[x]['age']} years old',style: extraSmallTextStyle(color: selectedList[index]?ThemeColor.themeBlueColor:ThemeColor.blueGreyColor),),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizeConfig.smallVerticalBox,
              KiButton.rectButton(
                color: ThemeColor.themeBlueColor,
                padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical, horizontal: SizeConfig.small),
                child: Text('Done', style: smallerTextStyle(color: ThemeColor.whiteColor),),
                onPressed: (){
                  widget.onPressed(selectedList);
                  Navigator.pop(context);
                }
              )
            ],
          )),
    );
  }

  void filterSearchResults(String query) {
    Map<int,dynamic> dummySearchList = new Map();
    dummySearchList.addAll(duplicateName);
    if(query.isNotEmpty) {
      Map<int,dynamic> dummyListData = new Map();
      dummySearchList.forEach((key,item) {
        if((item['name']).toLowerCase().contains(query.toLowerCase())) {
          dummyListData.putIfAbsent(key, () => item);
        }
        else if(item['age'].toString().contains(query)){
         dummyListData.putIfAbsent(key, () => item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateName);
      });
    }
  }


}
