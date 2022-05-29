import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kerjamin_fr/screens/detail_order.dart';
import 'package:kerjamin_fr/screens/progress_page.dart';
import 'package:kerjamin_fr/static/arrange_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:kerjamin_fr/static/all_static.dart';

class ArrangePage extends StatefulWidget {
  ArrangePage({Key? key}) : super(key: key);

  @override
  State<ArrangePage> createState() => _ArrangePageState();
}

class _ArrangePageState extends State<ArrangePage> {
  TextEditingController harga = new TextEditingController();
  TextEditingController newTask = new TextEditingController();
  List<List<String>> tasks = [];
  bool isArgmSb = false;

  _getArrangementData(String idOrder) async {
    var url = Uri.parse(ApiConfig.getArrangement(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    var resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });
    var responseDecode = jsonDecode(resp.body);
    var data = responseDecode['data'];

    if (data['tasks'].length > 0) {
      if (this.mounted) {
        setState(() {
          this.tasks = [];
          for (var i = 0; i < data['tasks'].length; i++) {
            this.tasks.add(
                [data['tasks'][i]['IdTask'], data['tasks'][i]['TaskDesc']]);
          }
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          this.tasks = [];
        });
      }
    }

    return data;
  }

  _postArrangement(String idOrder, dynamic offering) async {
    var url = Uri.parse(ApiConfig.getArrangement(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";
    var resp = await http.post(url,
        body: jsonEncode({
          'biaya': int.parse(harga.text),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenSp}',
        });

    var respDecode = jsonDecode(resp.body);
    if (resp.statusCode == 201) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProgressPage(),
              settings: RouteSettings(arguments: offering)));
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

  @override
  Widget build(BuildContext context) {
    final offering = ModalRoute.of(context)!.settings.arguments as OfferingItem;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Atur biaya dan pekerjaan'),
          actions: [
            FlatButton(
              onPressed: () {
                if (harga.text.isNotEmpty) {
                  this._postArrangement(offering.id_order, offering);
                } else {
                  Alert(
                      context: context,
                      style: AlertStyle(
                        titleStyle: TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                      title: 'Mohon isi harga!',
                      buttons: [
                        DialogButton(
                            child: Text("close"),
                            onPressed: () => Navigator.pop(context))
                      ]).show();
                }
              },
              child: Text(
                'SIMPAN',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 105, 236, 238),
                ),
              ),
            )
          ],
        ),
        body: Container(
          child: FutureBuilder(
              future: _getArrangementData(offering.id_order),
              builder: (context, AsyncSnapshot snapshot) {
                var hintHarga;
                if (snapshot.data == null || snapshot.data['harga'] == null) {
                  hintHarga = 0.toString();
                } else {
                  hintHarga = snapshot.data['harga'].toString();
                }
                if (snapshot.data == null) {
                  return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          width: double.infinity,
                          child: Text(
                            'Masukkan harga',
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: harga,
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.deepOrange[700]),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Harga sebelumnya Rp. ${hintHarga}',
                                fillColor: Color.fromARGB(255, 254, 189, 170),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          width: double.infinity,
                          child: Text(
                            'Masukkan harga',
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: harga,
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.deepOrange[700]),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Harga sebelumnya Rp. ${hintHarga}',
                                fillColor: Color.fromARGB(255, 254, 189, 170),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
                          width: double.infinity,
                          child: Text(
                            'Daftar pekerjaan',
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: this.tasks.length,
                          itemBuilder: (context, i) {
                            return Card(
                                elevation: 0.0,
                                color: Color.fromARGB(255, 255, 226, 211),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 3, 2, 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(this.tasks[i][1]),
                                      IconButton(
                                        icon: Icon(FontAwesomeIcons.trash),
                                        color: Colors.deepOrange,
                                        onPressed: () {
                                          this._deleteTask(offering.id_order,
                                              this.tasks[i][0]);
                                        },
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                      ],
                    ),
                  ));
                }
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Alert(
                context: context,
                title: "Masukkan pekerjaan",
                content: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: newTask,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(
                    onPressed: () {
                      this._submitTask(offering.id_order);
                      if (!newTask.text.isEmpty) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ArrangePage(),
                                settings: RouteSettings(arguments: offering)));
                      }
                    },
                    child: Text(
                      "SIMPAN",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]).show();
          },
          backgroundColor: Colors.deepOrange,
          child: const Icon(FontAwesomeIcons.plus),
        ),
      ),
    );
  }

  Future _submitTask(idOrder) async {
    var url = Uri.parse(ApiConfig.PostTask(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    final resp = await http.post(url,
        body: jsonEncode({
          'task': newTask.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenSp}',
        });

    newTask.clear();
  }

  Future _deleteTask(idOrder, idTask) async {
    var url = Uri.parse(ApiConfig.DeleteTask(idOrder, idTask));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    final resp = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });
  }
}
