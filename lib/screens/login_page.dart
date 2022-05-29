// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unnecessary_new

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          body: Container(
        padding: EdgeInsets.only(left: 40.0, right: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 100.0, bottom: 30.0),
              child: Text(
                'Login',
                style: TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: TextFormField(
                        controller: email,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.deepOrange[700]),
                        decoration: InputDecoration(
                          fillColor: Color.fromARGB(255, 254, 189, 170),
                          filled: true,
                          hintText: 'email',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: TextFormField(
                        controller: password,
                        obscureText: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.deepOrange[700]),
                        decoration: InputDecoration(
                          fillColor: Color.fromARGB(255, 254, 189, 170),
                          filled: true,
                          hintText: 'password',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text('MASUK'),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange,
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10))),
                          onPressed: () => {this._doLogin()},
                        ),
                      ),
                    )
                  ]),
            ),
          ],
        ),
      )),
    );
  }

  Future _doLogin() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      Alert(
          context: context,
          style: AlertStyle(titleStyle: TextStyle(color: Colors.red)),
          title: "Email atau password kosong!",
          buttons: [
            DialogButton(
                child: Text("Close"), onPressed: () => Navigator.pop(context))
          ]).show();

      return;
    }

    var url = Uri.parse(ApiConfig.getLoginUrl());
    final resp = await http.post(url,
        body: jsonEncode({
          'email': email.text,
          'password': password.text,
          'role': 'freelancer',
        }),
        headers: {
          'Content-Type': 'application/json',
        });
    var respDecode = jsonDecode(resp.body);

    if (resp.statusCode == 200) {
      var token = respDecode['token'];
      var pr = await SharedPreferences.getInstance();
      var tokenSp = pr.setString("token", token);

      Navigator.pushReplacementNamed(context, 'ongoing-page');
    } else {
      Alert(
          context: context,
          style: AlertStyle(
            titleStyle: TextStyle(
              color: Colors.redAccent,
            ),
          ),
          title: respDecode['message'],
          buttons: [
            DialogButton(
                child: Text("close"), onPressed: () => Navigator.pop(context))
          ]).show();
    }
  }
}
