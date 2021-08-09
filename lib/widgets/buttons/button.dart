import 'dart:html';
import 'package:flutter/material.dart';

button(Color _buttoncolor, Color _textcolor, String _text,
    [Function _toDo, List _arguments]) {
  return Container(
    margin: EdgeInsets.all(10),
    child: MaterialButton(
      color: _buttoncolor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      onPressed: () {
        _arguments != null ? _toDo(_arguments) : _toDo();
      },
      child: Text(
        _text,
        style: TextStyle(color: _textcolor),
      ),
    ),
  );
}
