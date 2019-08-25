import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'util.dart';

class UserPage extends StatefulWidget {

  @override
  State createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  Widget _result;
  String _uid;

  void _clearUid(String uid) {
    _uid = uid;
    if (uid.isEmpty) {
      _result = null;
      setState(() {});
    }
  }

  void _submit() {
    _searchUidInfo(_uid);
  }

  Future _searchUidInfo(String uid) async {
    if (uid.isEmpty) {
      _clearUid(uid);
      return;
    }

    var url = Uri.parse(GetUrl('QueryUserOnline?uid=$uid'));
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
                Center(child: Text("用户不在线"))
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
        title: Text('用户在线查询'),
      ),
      body: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  hintText:'用户ID'
              ),
              onSubmitted: _searchUidInfo,
              onChanged: _clearUid,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  child: Text('查询'),
                  onPressed: _submit,
                ),
              ],
            ),
            _result != null ? _result : const SizedBox()
          ],
        ),
      ),
    );
  }
}