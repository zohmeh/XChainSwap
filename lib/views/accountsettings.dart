import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/widgets/sidebar/sidebardesktop.dart';
import '/provider/contractinteraction.dart';
import '/provider/loginprovider.dart';
import '../widgets/buttons/button.dart';
import 'package:path/path.dart' as Path;
import '../widgets/inputfields/inputField.dart';

class AccountSettingsView extends StatefulWidget {
  //const CreateNFTView({Key key}) : super(key: key);
  final TextEditingController userNameController = TextEditingController();

  @override
  _AccountSettingsViewState createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  var name;
  var _loadedFile;
  var data;
  var _image;

  Future _loadPicture() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    mime(Path.basename(mediaData.fileName));
    setState(
      () {
        if (mediaData.data != null) {
          _image = Image.memory(mediaData.data);
          data = mediaData.data;
          _loadedFile = mediaData.fileName;
        } else {
          print('No image selected.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    return Row(
      children: [
        SidebarDesktop(3),
        Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width - 150,
          height: MediaQuery.of(context).size.height,
          child: user != null
              ? Center(
                  child: Card(
                    elevation: 10,
                    child: Container(
                      padding: EdgeInsets.all(30),
                      height: 500,
                      width: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              button(
                                  Theme.of(context).buttonColor,
                                  Theme.of(context).highlightColor,
                                  "Load Avatar",
                                  _loadPicture),
                              Container(
                                padding: EdgeInsets.all(2),
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    bottom: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    left: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    right: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                        style: BorderStyle.solid),
                                  ),
                                ),
                                child: Center(
                                  child: _loadedFile != null
                                      ? _image
                                      : Text("No Picture"),
                                ),
                              )
                            ],
                          ),
                          Container(
                              //height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  bottom: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  left: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  right: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid),
                                ),
                              ),
                              child: Center(
                                child: inputField(
                                    ctx: context,
                                    controller: widget.userNameController,
                                    labelText: "Input your Username",
                                    leftMargin: 0,
                                    topMargin: 0,
                                    rightMargin: 0,
                                    bottomMargin: 0,
                                    onChanged: (value) {
                                      setState(() {
                                        name = value;
                                      });
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        name = value;
                                      });
                                    }),
                              )),
                          button(
                            Theme.of(context).buttonColor,
                            Theme.of(context).highlightColor,
                            "Set Userdata",
                            Provider.of<LoginModel>(context).setMyData,
                            [data, name],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(child: Text("Please log in with Metamask")),
        ),
      ],
    );
  }
}
