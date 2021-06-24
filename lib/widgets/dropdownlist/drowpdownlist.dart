import 'package:flutter/material.dart';

class Dropdownlist extends StatefulWidget {
  final List<Map> tokenList;
  final String label;
  final Function onChanged;
  //etherchain chain = 0
  //bscchain chain = 1
  //polygonchain chain = 2
  final int chain;
  final bool isFromToken;

  Dropdownlist(
      {this.tokenList,
      this.label,
      this.onChanged,
      this.chain,
      this.isFromToken});

  @override
  _DropdownlistState createState() => _DropdownlistState();
}

class _DropdownlistState extends State<Dropdownlist> {
  String token;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton<String>(
          isDense: true,
          hint: new Text(
            widget.label,
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          value: token,
          onChanged: (value) {
            widget.onChanged(value, widget.chain, widget.isFromToken);
            setState(() {
              token = value;
            });
          },
          items: widget.tokenList.map((Map map) {
            return new DropdownMenuItem<String>(
              value: map["address"],
              child: Container(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.network(
                      map["logoURI"],
                      width: 25,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          map["symbol"],
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                    //Container(
                    //    margin: EdgeInsets.only(left: 20),
                    //    child: Flexible(
                    //      child: Text(
                    //        map["name"],
                    //        style: TextStyle(
                    //            color: Theme.of(context)
                    //                .accentColor),
                    //      ),
                    //    )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
