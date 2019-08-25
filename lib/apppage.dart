import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'util.dart';

class AppPage extends StatefulWidget {

  @override
  State createState() => AppPageState();
}

class AppPageState extends State<AppPage> {
  Timer _heartbeat;
  bool _isGetting = false;
  Map<String, Map<String, dynamic>> _appList = {};
  List<Widget> _list = [];
  ScrollController _scrollController;

  Future _getList() async {
    if (_isGetting) return;
    _isGetting = true;
    var url = Uri.parse(GetUrl('AppList'));
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(url);
    request.headers.add('100edu-token', '100338');
    var response = await request.close();

    var str = StringBuffer();
    await for (var contents in response.transform(Utf8Decoder())) {
      str.write(contents);
    }

    try {
      Map<String, dynamic> js = JsonDecoder().convert(str.toString());
      _appList = {};

      js.forEach((String key, dynamic value) {
        var prefix = value['appId'].toString();

        Map<String, dynamic> list = {};
        if (_appList.containsKey(prefix)) {
          list = _appList[prefix];
        } else {
          _appList[prefix] = list;
        }

        list[key] = value;
      });

      setState(() {
        List<Widget> list = [];
        for (var prefix in _appList.keys) {
          var group = _appList[prefix];
          for (var id in group.keys) {
            var m = group[id];
            list.add(AppItem(prefix: prefix, item: m));
          }
        }
        _list = list;
      });
    } catch(e) {
      _list = [];
    } finally {
      httpClient.close();
      _isGetting = false;
    }
  }


  @override
  void initState() {
    super.initState();
    _heartbeat = Timer.periodic(Duration(seconds: 10), (t) => _getList());
    _scrollController = ScrollController();
    _getList();
  }


  @override
  void deactivate() {
    super.deactivate();
    _heartbeat.cancel();
    _heartbeat = null;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _list.length < 1 ? Text('业务进程') : Text('业务进程 (${_list.length})'),
        ),
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          children: _list,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: _scrollToTop,
            child: Icon(Icons.vertical_align_top)
        )
    );
  }
}

class AppItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String prefix;

  AppItem({Key key, this.prefix, this.item}): super(key:key);

  @override
  Widget build(BuildContext context) {
    const padding = SizedBox(width: 40);
    var ips = item['ips'] as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          color: Colors.lightGreen,
          borderRadius:BorderRadius.all(Radius.elliptical(5, 5))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.apps),
              Expanded(
                  child: Text('')
              ),
              Text(prefix)
            ],
          ),
          Text('ID: ${item['metaId']}'),
          Row(
            children: <Widget>[
              padding,
              Text('IP:  '),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ips.keys.map((key) {
                  var value = ips[key];
                  var prefix = IpsIdToName(int.parse(key));
                  return Text('<$prefix> ${IntToIp(value as int)}');
                }).toList(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              padding,
              Text('端口: '),
              Text((item['ports'] as List<dynamic>).join(', ')),
            ],
          ),
          Row(
            children: <Widget>[
              padding,
              Text('组ID: ${item['groupId']}')
            ],
          ),
        ],
      ),
    );
  }
}