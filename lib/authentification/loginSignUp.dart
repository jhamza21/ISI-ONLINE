import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isi_project/home/homePage.dart';
import 'package:isi_project/services/pMakerService.dart';
import 'package:isi_project/shared/functions.dart';

class LoginSignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  final formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String email;
  String password;
  String errorMessage;
  bool isLoading;
  bool showPassword;
  bool _showLogin;
  @override
  void initState() {
    errorMessage = "";
    isLoading = false;
    showPassword = false;
    _showLogin=false;
    super.initState();
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

  // login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        errorMessage = "";
        isLoading = true;
      });
      try {
        final res = await PMakerService().signIn(email, password);
        if (res.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          String accessToken = json.decode(res.body)['access_token'];
          formKey.currentState.reset();
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return HomePage(accessToken: accessToken);
          }));
        } else {
          setState(() {
            errorMessage = json.decode(res.body)['error_description'];
          });
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
          _showFail("Vérifier votre connexion ou essayer plus tard");
          formKey.currentState.reset();
        });
      }
    }
  }

  void resetForm() {
    formKey.currentState.reset();
    errorMessage = "";
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
            ]),
      ),
      child: WillPopScope(
          onWillPop: ()=>Functions().exitApp(context),
              child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              _showForm(),
              _showCircularProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showCircularProgress() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return SizedBox();
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(40.0),
        child: new Form(
          key: formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              !_showLogin?playAnimation():SizedBox(),
              _showLogin?showUserNameInput():SizedBox(),
              _showLogin?showPasswordInput():SizedBox(),
              _showLogin?Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                child: Text('Mot de passe oublié ?'),
              ):SizedBox(),
              _showLogin?showPrimaryButton():SizedBox(),
              showErrorMessage(),
            ],
          ),
        ));
  }

  Widget showErrorMessage() {
    if (errorMessage.length > 0 && errorMessage != null) {
      return new Text(
        errorMessage,
        style: TextStyle(
            fontSize: 15.0, color: Colors.red, fontWeight: FontWeight.w400),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 60.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/images/isi.png'),
        ));
  }

  Widget showUserNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: new BorderSide(color: Colors.blue[800])),
            labelText: "Nom d'utilisateur",
            labelStyle: TextStyle(color: Colors.black, fontSize: 16.0),
            prefixIcon: new Icon(
              Icons.person,
              color: Colors.green[800],
            )),
        validator: (value) =>
            value.length < 5 ? "Nom d'utilisateur incorrect" : null,
        onSaved: (value) => email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: !showPassword,
        autofocus: false,
        decoration: new InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: new BorderSide(color: Colors.blue[800])),
            labelText: "Mot de passe",
            labelStyle: TextStyle(color: Colors.black, fontSize: 16.0),
            suffixIcon: GestureDetector(
                child: Icon(
                    !showPassword ? Icons.visibility : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                }),
            prefixIcon: new Icon(
              Icons.lock,
              color: Colors.green[800],
            )),
        validator: (value) => value.isEmpty ? 'Mot de passe incorrect' : null,
        onChanged: (val) => password = val.trim(),
        onSaved: (value) => password = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(45.0, 45.0, 45.0, 20.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue[800],
            child: new Text('CONNEXION',
                style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.blue[100],
                    letterSpacing: 2.0)),
            onPressed: validateAndSubmit,
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
    Widget playAnimation() {
    Timer(
        Duration(seconds: 7),
        () => setState(() {
              _showLogin = true;
            }));
    return Column(
      children: <Widget>[
        CupertinoActivityIndicator(radius: 15.0,),
        SizedBox(height: 10.0,),
        Text('Chargement...')
      ],
    );
  }

}
