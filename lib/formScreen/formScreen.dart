import 'dart:convert';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart';
import 'package:isi_project/models/inputsType.dart';
import 'package:isi_project/services/pMakerService.dart';
import 'package:isi_project/shared/functions.dart';
import 'package:isi_project/shared/sideBar.dart';
import 'package:intl/intl.dart';

class FormScreen extends StatefulWidget {
  final String token;
  final String title;
  final String tasUid;
  final String proUid;
  final List<InputsType> listInputs;
  final dynamic values;
  final bool formDone;

  FormScreen(
      {this.token,
      this.title,
      this.listInputs,
      this.proUid,
      this.tasUid,
      this.values,
      this.formDone});
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormBuilderState> formKey = new GlobalKey<FormBuilderState>();
  Map<String, dynamic> form;

  @override
  void initState() {
    super.initState();
    form = new Map<String, dynamic>();
  }

// Check if form is valid
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
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
              Colors.green[200],
            ],
          ),
        ),
        child: WillPopScope(
          onWillPop: ()=>Functions().exitApp(context),
                  child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
                title: Text(widget.title,
                    style: TextStyle(
                        fontSize: widget.title.length > 20 ? 15.0 : 20.0))),
            drawer: SideBar(
              token: widget.token,
            ),
            body: FormBuilder(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 15.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.listInputs.length,
                    itemBuilder: (context, i) {
                      InputsType input = widget.listInputs[i];
                      switch (input.type) {
                        case 'image':
                          return _showLogo();
                          break;
                        case 'title':
                          return Center(
                              child: Text(
                            input.label.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.green[800],
                            ),
                          ));
                          break;
                        case 'text':
                          return _textInput(input.placeHolder, input.label, false,
                              input.id, input.require);
                          break;
                        case 'textarea':
                          return _textInput(input.placeHolder, input.label, true,
                              input.id, input.require);
                          break;
                        case 'dropdown':
                          form.addAll({input.id: null});
                          return _dropDown(
                              input.label,
                              input.placeHolder,
                              input.options,
                              input.id,
                              form.length - 1,
                              input.require);
                          break;
                        case 'submit':
                          return !widget.formDone?_showSubmitButton(input.label, input.id):SizedBox();
                          break;
                        case 'button':
                          return !widget.formDone?_showSubmitButton(input.label, input.id):SizedBox();
                          break;
                        case 'datetime':
                          return input.placeHolder.isEmpty
                              ? _showTimeInput(input.label, input.id,
                                  input.placeHolder, input.require)
                              : _showDateInput(input.label, input.id,
                                  input.placeHolder, input.require);
                          break;
                        case 'radio':
                          return _showRadioInput(input.label, input.options,
                              form.length - 1, input.id, input.require);
                          break;
                        case 'grid':
                          return _showGridInput(input.label, input.columns);
                          break;
                        default:
                          return SizedBox(
                            height: 10.0,
                          );
                      }
                    }),
              ),
            ),
          ),
        ));
  }

  Widget _showGridInput(String label, List<dynamic> columns) {
    return SizedBox(
      height: 80.0,
      child: Center(
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: columns.length,
            itemBuilder: (context, i) {
              dynamic col = columns[i];
              return Column(
                children: <Widget>[
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(border: Border.all()),
                    child: Center(
                      child: Text(
                        col['label'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            fontSize: 15.0),
                      ),
                    ),
                  ),
                  Container(
                    height: 30.0,
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(border: Border.all()),
                    child: Text(
                      col['label'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.transparent,
                          fontSize: 15.0),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void updateDropDown(String id) {
    if (widget.values == null) return;
    if (widget.values[id] != null && widget.values[id] != '')
      form[id] = widget.values[id];
  }

  Widget _dropDown(String label, String placeHolder, List<dynamic> options,
      String id, int index, bool require) {
    updateDropDown(id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.blue[900]),
            ),
            require
                ? Text(
                    '*',
                    style: TextStyle(color: Colors.red[900]),
                  )
                : SizedBox(),
          ],
        ),
        DropdownButtonFormField<String>(  
          disabledHint: widget.formDone?Text(form[id]):Text(''),
          autovalidate: false,
          validator: require ? FormBuilderValidators.required() : null,
          isExpanded: true,
          value: form[id],
          hint: Text(placeHolder),
          onChanged: (value) => form[id] = value,
          items: widget.formDone?null:options.map((dynamic option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label'].toString().toUpperCase()),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _textInput(String placeHolder, String label, bool textArea, String id,
      bool require) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.blue[900]),
            ),
            require
                ? Text(
                    '*',
                    style: TextStyle(color: Colors.red[900]),
                  )
                : SizedBox()
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          child: new TextFormField(
            enabled: widget.formDone?false:true,
            initialValue: widget.values != null ? widget.values[id] : null,
            maxLines: textArea ? 5 : 1,
            autofocus: false,
            decoration: new InputDecoration(
              hintText: placeHolder,
            ),
            validator: require ? FormBuilderValidators.required() : null,
            onSaved: (value) {
              form.addAll({id: value});
            },
          ),
        ),
      ],
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'ISI UNIVERSITY',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 35.0,
          child: Image.asset('assets/images/isi.png'),
        ),
      ),
    );
  }

  Widget _showSubmitButton(String label, String id) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(45.0, 25.0, 45.0, 25.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: id == 'cancelcase' ? Colors.red[400] : Colors.green[600],
            child: new Text(label.toUpperCase(),
                style: new TextStyle(
                    letterSpacing: label.length < 20 ? 3.0 : 0.0,
                    fontWeight: FontWeight.bold,
                    fontSize: label.length > 20 ? 11.5 : 18.0,
                    color: Colors.white)),
            onPressed: () async {
              if (id == 'cancelcase') {
                Navigator.pop(context);
              } else if (validateAndSave()) {
                try {
                  if (widget.values != null)
                    await PMakerService()
                        .updateVariables(widget.token, widget.tasUid, form);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.blue[300],
                        title: Text("Confirmer la demande"),
                        content: Text(
                            'Envoyer la demande ou quitter (Demande sera enregistrée dans votre brouillon)'),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () async {
                                Response res, res2;
                                if (widget.values == null) {
                                  res = await PMakerService().formToDraft(
                                      form,
                                      widget.proUid,
                                      widget.tasUid,
                                      widget.token);
                                }
                                res2 = await PMakerService().submitForm(
                                    widget.values != null
                                        ? widget.tasUid
                                        : json.decode(res.body)['app_uid'],
                                    widget.token);
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.blue[300],
                                      title: res2.statusCode == 200
                                          ? Text("Demande envoyée")
                                          : Text("Echec de la demande"),
                                      content: res2.statusCode == 200
                                          ? Text(widget.values == null
                                              ? 'Numéro de la demande : ${json.decode(res.body)['app_number'].toString()}'
                                              : 'Votre demande est confirmée')
                                          : Text('Essayer plus tard..'),
                                      actions: <Widget>[
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Ok',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.green[800]),
                                            ))
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Envoyer',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.green[800]),
                              )),
                          FlatButton(
                              onPressed: () async {
                                if (widget.values == null) {
                                  Response res = await PMakerService()
                                      .formToDraft(form, widget.proUid,
                                          widget.tasUid, widget.token);
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.blue[300],
                                        title: res.statusCode == 200
                                            ? Text("Demande enregistrée")
                                            : Text("Echec de l'enregistrement"),
                                        content: res.statusCode == 200
                                            ? Text('Numéro de la demande :' +
                                                json
                                                    .decode(
                                                        res.body)['app_number']
                                                    .toString())
                                            : Text('Essayer plus tard..'),
                                        actions: <Widget>[
                                          FlatButton(
                                              onPressed: () {
                                                if (res.statusCode == 200) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text(
                                                'Ok',
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.green[800]),
                                              ))
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Quitter',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.red[800]),
                              ))
                        ],
                      );
                    },
                  );
                } catch (e) {
                  print(e);
                }
              }
            },
          ),
        ));
  }

  Widget _showRadioInput(
      String label, List<dynamic> options, int index, String id, bool require) {
    return FormBuilderRadio(
      readOnly: !widget.formDone?false:true,
      initialValue: widget.values != null ? widget.values[id] : null,
      attribute: label,
      decoration: InputDecoration(
          labelText: require ? label + '*' : label,
          labelStyle: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
              fontSize: 18.0)),
      onSaved: (value) => form.addAll({id: value}),
      validators: [require ? FormBuilderValidators.required() : null],
      options: options
          .map((dynamic e) => FormBuilderFieldOption(
                value: e['value'],
                child: Text(e['label']),
              ))
          .toList(growable: false),
    );
  }

  Widget _showTimeInput(
      String label, String id, String placeHolder, bool require) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.blue[900]),
            ),
            require
                ? Text(
                    '*',
                    style: TextStyle(color: Colors.red[900]),
                  )
                : SizedBox(),
          ],
        ),
        DateTimeField(
          enabled: widget.formDone?false:true,
          initialValue: getInitial(id),
          format: DateFormat("hh:mma"),
          decoration: InputDecoration(hintText: placeHolder),
          validator: require ? FormBuilderValidators.required() : null,
          onSaved: (value) => form.addAll({id: value.toString()}),
          onShowPicker: (context, currentValue) async {
            final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                    hour: DateTime.now().hour, minute: DateTime.now().minute));
            return time != null
                ? DateTimeField.combine(DateTime.now(), time)
                : currentValue;
          },
        ),
        SizedBox(
          height: 15.0,
        )
      ],
    );
  }

  DateTime getInitial(String id) {
    if (widget.values == null) return null;
    if (widget.values[id] != 'null') return DateTime.parse(widget.values[id]);
    return null;
  }

  Widget _showDateInput(
      String label, String id, String placeHolder, bool require) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.blue[900]),
            ),
            require
                ? Text(
                    '*',
                    style: TextStyle(color: Colors.red[900]),
                  )
                : SizedBox(),
          ],
        ),
        DateTimeField(
          enabled: widget.formDone?false:true,
          initialValue: getInitial(id),
          decoration: InputDecoration(hintText: placeHolder),
          format: DateFormat("yyyy-MM-dd"),
          validator: require ? FormBuilderValidators.required() : null,
          onSaved: (value) => form.addAll({id: value.toString()}),
          onShowPicker: (context, currentValue) {
            return showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2100));
          },
        ),
      ],
    );
  }
}
