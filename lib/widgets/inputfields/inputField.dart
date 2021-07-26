import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

inputField(
    {BuildContext ctx,
    TextEditingController controller,
    String labelText,
    double leftMargin,
    double topMargin,
    double rightMargin,
    double bottomMargin,
    FocusNode node1,
    FocusNode node2,
    Function onSubmitted,
    Function onChanged}) {
  return Container(
    margin:
        EdgeInsets.fromLTRB(leftMargin, topMargin, rightMargin, bottomMargin),
    padding: EdgeInsets.all(3),
    decoration: BoxDecoration(
        color: Color(0xFF212332),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black)),
    child: TextFormField(
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.white),
      maxLines: null,
      controller: controller,
      focusNode: node2,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 12, color: Colors.white)),
      //onChanged: (value) {
      //  onSubmitted(value);
      //},
      onFieldSubmitted: (value) {
        onSubmitted(value);
      },
    ),
  );
}
