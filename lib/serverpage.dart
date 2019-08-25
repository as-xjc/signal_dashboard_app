import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'util.dart';

class ServerPage extends StatefulWidget {

  @override
  State createState() => ServerPageState();
}

class ServerPageState extends State<ServerPage> {
  Timer _heartbeat;
  bool _isGetting = false;
  Map<String, Map<String, dynamic>> _serverList = {};
  List<Widget> _list = [];
  ScrollController _scrollController;

  Future _getList() async {
    if (_isGetting) return;
    _isGetting = true;
    var url = Uri.parse(GetUrl('ServerList'));
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
      _serverList = {};

      js.forEach((String key, dynamic value) {
        var k = key.startsWith('/') ? key.substring(1) : key;
        var ks = k.split('/');
        ks.removeLast();
        var prefix = ks.join('/');

        Map<String, dynamic> list = {};
        if (_serverList.containsKey(prefix)) {
          list = _serverList[prefix];
        } else {
          _serverList[prefix] = list;
        }

        list[k] = value;
      });

      setState(() {
        List<Widget> list = [];
        for (var prefix in _serverList.keys) {
          var group = _serverList[prefix];
          for (var id in group.keys) {
            var m = group[id];
            list.add(ServerItem(prefix: prefix, item: m));
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
        title: _list.length < 1 ? Text('服务进程') : Text('服务进程 (${_list.length})'),
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

class ServerItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String prefix;

  ServerItem({Key key, this.prefix, this.item}): super(key:key);

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
              Icon(Icons.computer),
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