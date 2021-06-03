import 'package:flutter/material.dart';

class Tokensymbols extends StatelessWidget {
  final image;
  final width;
  final height;
  Tokensymbols({this.image, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return image != null
        ? Container(
            width: width,
            height: height,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill, image: NetworkImage(image))))
        : Container(width: width, height: height);
  }
}
