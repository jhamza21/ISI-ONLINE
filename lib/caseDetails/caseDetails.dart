import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:isi_project/formScreen/formScreen.dart';
import 'package:isi_project/models/case.dart';
import 'package:isi_project/models/caseDetails.dart';
import 'package:isi_project/models/inputsType.dart';
import 'package:isi_project/services/pMakerService.dart';
import 'package:isi_project/shared/functions.dart';
import 'package:isi_project/shared/sideBar.dart';

class CaseDetailsScreen extends StatefulWidget {
  final Case caseD;
  final String token;
  CaseDetailsScreen({this.caseD, this.token});
  @override
  _CaseDetailsScreenState createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  CaseDetails _caseDetails;
  bool _isLoading;
  String title;

  @override
  void initState() {
    _isLoading = false;
    super.initState();
    _loadCaseDetails();
    title = widget.caseD.title
        .substring(
            0,
            widget.caseD.title.indexOf('(') != -1
                ? widget.caseD.title.indexOf('(')
                : widget.caseD.title.length)
        .toUpperCase();
  }

  void _loadCaseDetails() async {
    try {
      Response res = await PMakerService()
          .getCaseDetails(widget.token, widget.caseD.idProj);
      if (res.statusCode == 200) {
        setState(() {
          _caseDetails = CaseDetails.fromMap(json.decode(res.body));
        });
      }
    } catch (e) {
      print(e);
      _showFail('Essayer plus tard');
    }
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
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                title,
                style: TextStyle(fontSize: title.length > 20 ? 15.0 : 20.0),
              ),
            ),
            body: _caseDetails != null
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 90.0,
                            child: Image.asset('assets/images/isi.png'),
                          ),
                        ),
                        Text(
                          '1) Processus : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                              fontSize: 18.0,
                              letterSpacing: 1.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Text(
                            _caseDetails.name,
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          '2) Description : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                              fontSize: 18.0,
                              letterSpacing: 1.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Text(
                            _caseDetails.description,
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    50.0, 25.0, 50.0, 0.0),
                                child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0)),
                                    elevation: 5.0,
                                    color: Colors.green[600],
                                    onPressed: () async {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        Response res = await PMakerService()
                                            .startCase(widget.token,
                                                widget.caseD.idProj);

                                        if (res.statusCode == 200) {
                                          Iterable list;
                                          List<InputsType> _listInputs;
                                          list = json.decode(res.body);

                                          _listInputs = list
                                              .map((e) => InputsType.fromMap(e))
                                              .toList();
                                          Navigator.pop(context);
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return FormScreen(
                                                token: widget.token,
                                                listInputs: _listInputs,
                                                tasUid: widget.caseD.id,
                                                proUid: widget.caseD.idProj,
                                                title: title,
                                                formDone: false,);
                                          }));
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        } else {
                                          _showFail('Essayer plus tard...');
                                        }
                                      } catch (e) {
                                        print(e);
                                        _showFail('Essayer plus tard...');
                                      }
                                    },
                                    child: Text(
                                      'COMMENCER',
                                      style: TextStyle(
                                          letterSpacing: 2.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox(),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            drawer: SideBar(
              token: widget.token,
            ),
          ),
        ));
  }

  void _showFail(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 5),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
