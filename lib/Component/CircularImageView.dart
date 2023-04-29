import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constant/ColorConstant.dart';

class ImageViewCircle extends StatelessWidget {
  ImageViewCircle({this.url, this.radiusSize = 40});

  String? url;
  double radiusSize;

  @override
  Widget build(BuildContext context) {
    return new CircleAvatar(
      radius: radiusSize,
      backgroundColor: CustomColor.themeColor,
      child: CachedNetworkImage(
        imageUrl: url!,
        imageBuilder: (context, imageProvider) => Container(
          width: radiusSize * 2,
          height: radiusSize * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
