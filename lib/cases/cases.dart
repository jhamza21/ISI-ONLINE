import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:isi_project/caseDetails/caseDetails.dart';
import 'package:isi_project/models/case.dart';
import 'package:isi_project/services/pMakerService.dart';
import 'package:isi_project/shared/functions.dart';
import 'package:isi_project/shared/sideBar.dart';

class CasesPage extends StatefulWidget {
  final String token;
  CasesPage({this.token});

  @override
  CasesPageState createState() => new CasesPageState();
}

class CasesPageState extends State<CasesPage> {
  bool _isLoading = true;
  List<Case> _listCases;

  @override
  void initState() {
    super.initState();
    _listCases = new List<Case>();
    _fetchCases();
  }

  Card buildTask(Case caseModel, int i) {
    return Card(
      color: i.isEven ? Colors.teal[400] : Colors.blue[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return CaseDetailsScreen(
                token: widget.token,
                caseD: caseModel,
              );
            }));
          },
          child: ListTile(
            leading: Text(
              i.toString(),
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            title: (Text(
              caseModel.title,
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
            trailing: Icon(
              Icons.arrow_forward,
            ),
          ),
        ),
      ),
    );
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
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('CASES'),
              ),
              drawer: SideBar(
                token: widget.token,
              ),
              body: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchCases,
                      child: ListView.builder(
                        padding: EdgeInsets.all(3),
                        itemCount: _listCases.length,
                        itemBuilder: (context, index) {
                          return buildTask(_listCases[index], index + 1);
                        },
                      ),
                    )),
        ));
  }

  Future<Null> _fetchCases() async {
    try {
      _isLoading = true;
      Iterable list;
      Response res = await PMakerService().getCases(widget.token);
      if (res.statusCode == 200) {
        list = json.decode(res.body);
        setState(() {
          _listCases = list.map((e) => Case.fromMap(e)).toList();
        });
      }
      _isLoading = false;
    } catch (e) {
      print(e);
    }
  }
}
