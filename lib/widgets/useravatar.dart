import 'dart:typed_data';

import 'package:flutter/material.dart';

class Useravatar extends StatelessWidget {
  final image;
  final width;
  final height;
  List<int> avatar = [];
  Useravatar({this.image, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      for (var i = 0; i < image.length; i++) {
        avatar.add(image[i]);
      }
    }
    return image != null
        ? Container(
            width: width,
            height: height,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: MemoryImage(Uint8List.fromList(avatar)))))
        : Container(width: width, height: height);
  }
}
