import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:isi_project/formScreen/formScreen.dart';
import 'package:isi_project/models/draft.dart';
import 'package:isi_project/models/inputsType.dart';
import 'package:isi_project/services/pMakerService.dart';
import 'package:isi_project/shared/functions.dart';
import 'package:isi_project/shared/sideBar.dart';

class DraftsPage extends StatefulWidget {
  final String token;
  DraftsPage({this.token});

  @override
  DraftsPageState createState() => new DraftsPageState();
}

class DraftsPageState extends State<DraftsPage> {
  bool _isLoading = true;
  List<Draft> _listDrafts;
  ScrollController _scrollController = ScrollController();
  int _nbDrafts = 10;

  @override
  void initState() {
    super.initState();
    _listDrafts = new List<Draft>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchDrafts(_nbDrafts, 10);
        _nbDrafts += 10;
      }
    });
    _fetchDrafts(0, 10);
  }

  Card buildTask(Draft draftModel) {
    return Card(
      color: Colors.blueGrey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            Response res = await PMakerService()
                .getVariables(widget.token, draftModel.uid);
            dynamic _variables = json.decode(res.body);

            res = await PMakerService()
                .startCase(widget.token, draftModel.proUid);

            if (res.statusCode == 200) {
              Iterable list;
              List<InputsType> _listInputs;
              list = json.decode(res.body);

              _listInputs = list.map((e) => InputsType.fromMap(e)).toList();
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return FormScreen(
                  token: widget.token,
                  listInputs: _listInputs,
                  tasUid: draftModel.uid,
                  proUid: draftModel.proUid,
                  title: 'Demande N° ${draftModel.num}',
                  values: _variables,
                  formDone: false,
                );
              }));
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: ListTile(
            leading: Text(
              draftModel.num,
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            title: (Text(
              draftModel.title,
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
            trailing: Text(draftModel.date),
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
                title: Text('BROUILLON'),
              ),
              drawer: SideBar(
                token: widget.token,
              ),
              body: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _listDrafts.length == 0
                      ? Center(child: Text('Aucun brouillon'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(3),
                          itemCount: _listDrafts.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _listDrafts.length)
                              return CupertinoActivityIndicator(
                                radius: 15.0,
                              );

                            return Dismissible(
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  child: Icon(
                                    Icons.restore_from_trash,
                                    color: Colors.white,
                                  ),
                                ),
                                key: Key(_listDrafts[index].num),
                                child: buildTask(_listDrafts[index]));
                          },
                        )),
        ));
  }

  Future<Null> _fetchDrafts(int start, int limit) async {
    try {
      _isLoading = true;
      Iterable list;
      Response res =
          await PMakerService().getDrafts(widget.token, start, limit);
      if (res.statusCode == 200) {
        list = json.decode(res.body);
        setState(() {
          _listDrafts.addAll(list.map((e) => Draft.fromMap(e)).toList());
        });
      }
      _isLoading = false;
    } catch (e) {
      print(e);
    }
  }
}
