import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Functions {
  Future<bool> exitApp( BuildContext context) {
   return showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22.0))),
          backgroundColor: Colors.blue[300],
                title: Text('🛑  Avertissement',),
                content: Text("Vous êtes sur de quitter l'application ?"),
                actions: [
                  Container(
                    height: 23.0,
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(80.0),
                      color: Colors.red[400]),
                    child: FlatButton(child: Text('OUI',style: TextStyle(fontSize: 15.0,color: Colors.black),), onPressed: () => SystemNavigator.pop())),
                  Container(
                    height: 23.0,
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(80.0),
                      color: Colors.green),
                    child: FlatButton(child: Text('NON',style: TextStyle(fontSize: 15.0,color: Colors.black,)), onPressed: () => Navigator.pop(c,false))),
                ]));
  }
}
