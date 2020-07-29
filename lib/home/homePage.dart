import 'package:flutter/material.dart';
import 'package:isi_project/shared/functions.dart';
import 'package:isi_project/shared/sideBar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.accessToken}) : super(key: key);
  final String accessToken;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[100],
              Colors.blue[300],
              Colors.blue[400],
              Colors.green[300],
            ],
          ),
        ),
        child: WillPopScope(
          onWillPop: ()=>Functions().exitApp(context),
                  child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('Accueil'),
              ),
              drawer: SideBar(
                token: widget.accessToken,
              ),
              body: Center(child: showLogo())),
        ));
  }

  Widget showLogo() {
    return SizedBox(
        height: 150.0,
        width: 200.0,
        child: Image.asset('assets/images/isi.png'));
  }
}
