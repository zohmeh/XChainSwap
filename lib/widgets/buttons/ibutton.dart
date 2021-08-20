import 'dart:html';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

ibutton(String image, Color _buttoncolor, Color _textcolor, String _text,
    [Function _toDo, List _arguments]) {
  return MaterialButton(
    color: _buttoncolor,
    elevation: 0,
    onPressed: () {
      _arguments != null ? _toDo(_arguments) : _toDo();
    },
    child: Column(
      children: [
        Image.asset('/images/${image}', width: 40),
        /*Icon(
          icons,
          size: 35,
          color: _textcolor,
        ),*/
        SizedBox(height: 7),
        AutoSizeText(
          _text,
          style: TextStyle(color: _textcolor),
        ),
      ],
    ),
  );
}
