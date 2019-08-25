import 'package:flutter/material.dart';
import 'serverpage.dart';
import 'apppage.dart';
import 'userpage.dart';
import 'grouppage.dart';

void main() => runApp(DashboardApp());

class DashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '信令仪表',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {

  @override
  State createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<Widget> _pages = List<Widget>();

  @override
  void initState() {
    _pages
      ..add(ServerPage())
      ..add(AppPage())
      ..add(UserPage())
      ..add(GroupPage());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryColor;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
//        unselectedItemColor: Colors.grey,
        selectedItemColor: color,
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        selectedIconTheme: IconThemeData(color: color),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.computer),
              title: Text('服务进程')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              title: Text('业务进程')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              title: Text('用户信息')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text('组信息')
          ),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}