import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'util.dart';

class GroupPage extends StatefulWidget {

  @override
  State createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  Widget _result;
  String _groupId;
  String _groupType;
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('after $_groupId $_groupType');

      _searchGroupInfo();
    }
  }

  Future _searchGroupInfo() async {
    var url = Uri.parse(GetUrl('QueryUgOnline?UserGroupType=$_groupType&UserGroupId=$_groupId'));
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(url);
    request.headers.add('100edu-token', '100338');
    var response = await request.close();

    var str = StringBuffer();
    await for (var contents in response.transform(Utf8Decoder())) {
      str.write(contents);
    }

    Map<String, dynamic> js = {};
    try {
      js = JsonDecoder().convert(str.toString());
    } catch(e) {

    }

    if (js.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Center(child: Text("查询结果")),
              children: <Widget>[
                Center(child: Text("该组没用户在线"))
              ],
            );
          });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('组内在线用户查询'),
      ),
      body: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.group),
                        hintText:'组ID'
                    ),
                    validator: (input) => input.length > 0 ? null : '输入组ID',
                    onSaved: (input) => _groupId = input,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.group),
                        hintText:'组类型'
                    ),
                    validator: (input) => input.length > 0 ? null : '输入组类型',
                    onSaved: (input) => _groupType = input,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  child: Text('查询'),
                  onPressed: _submit,
                )
              ],
            ),
            _result != null ? _result : const SizedBox()
          ],
        )
      ),
    );
  }
}