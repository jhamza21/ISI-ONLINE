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

class ToDoPage extends StatefulWidget {
  final String token;
  ToDoPage({this.token});

  @override
  ToDoPageState createState() => new ToDoPageState();
}

class ToDoPageState extends State<ToDoPage> {
  bool _isLoading;
  List<Draft> _listToDo;
  ScrollController _scrollController = ScrollController();
  int _nbDrafts = 10;

  @override
  void initState() {
    super.initState();
    _listToDo = new List<Draft>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchToDo(_nbDrafts, 10);
        _nbDrafts += 10;
      }
    });
    _fetchToDo(0, 10);
    
  }

  Card buildTask(Draft draftModel) {
    return Card(
      color: draftModel.statut == 'TO_DO'
          ? Colors.green[200]
          : Colors.blueGrey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: ()async{
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
                  formDone:draftModel.statut == 'TO_DO'?true:false
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
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(draftModel.date),
                draftModel.statut == 'TO_DO'
                    ? Text('A faire ✔️')
                    : Text('Brouillon')
              ],
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
                title: Text('MES DEMANDES'),
              ),
              drawer: SideBar(
                token: widget.token,
              ),
              body: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _listToDo.length == 0
                      ? Center(child: Text('Aucune demande'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(3),
                          itemCount: _listToDo.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _listToDo.length)
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
                                key: Key(_listToDo[index].num),
                                child: buildTask(_listToDo[index]));
                          },
                        )),
        ));
  }

  void _fetchToDo(int start, int limit) async {
    try {
      _isLoading = true;
      Iterable list;
      Response res = await PMakerService().getToDO(widget.token, start, limit);
      if (res.statusCode == 200) {
        list = json.decode(res.body);
        setState(() {
          _listToDo.addAll(list.map((e) => Draft.fromMap(e)).toList());
        });
      }
      _isLoading = false;
    } catch (e) {
      print(e);
    }
  }
}
