import 'package:flutter/material.dart';
import 'package:kiki/contents/colors.dart';
import 'package:kiki/contents/size_config.dart';
import 'package:kiki/contents/texts.dart';
import 'package:kiki/ui_components/functional_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.whiteColor,
      appBar: AppBar(
        backgroundColor: ThemeColor.themeBlueColor,
        title: Text(
          'Full Photo',
          style: mediumSmallTextStyle(color: ThemeColor.whiteColor),
        ),
        centerTitle: true,
          leading: KiButton.smallButton(
              child: Icon(Icons.arrow_back_ios,color: ThemeColor.whiteColor,size: SizeConfig.medium,),
              onPressed: (){
                Navigator.pop(context);
              }
          )
      ),
      body: FullPhotoScreen(url: url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(backgroundDecoration:BoxDecoration(color: ThemeColor.whiteColor),
            imageProvider: CachedNetworkImageProvider(url),
            loadingBuilder: (BuildContext context, ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return Center(child:CircularProgressIndicator());
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ?
                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
        ));
  }
}
