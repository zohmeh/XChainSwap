import 'dart:html';
import 'package:flutter/material.dart';

ibutton(IconData icons, Color _buttoncolor, Color _textcolor, String _text,
    [Function _toDo, List _arguments]) {
  return MaterialButton(
    color: _buttoncolor,
    elevation: 0,
    //shape: RoundedRectangleBorder(
    //  borderRadius: BorderRadius.all(
    //    Radius.circular(15),
    //  ),
    //),
    onPressed: () {
      _arguments != null ? _toDo(_arguments) : _toDo();
    },
    child: Row(
      children: [
        Icon(
          icons,
          color: _textcolor,
        ),
        SizedBox(width: 10),
        Text(
          _text,
          style: TextStyle(color: _textcolor),
        ),
      ],
    ),
  );
}
