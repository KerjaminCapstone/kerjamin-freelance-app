import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kerjamin_fr/screens/arrange_page.dart';
import 'package:kerjamin_fr/screens/history_page.dart';
import 'package:kerjamin_fr/screens/ongoing_page.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:kerjamin_fr/static/offering_detail.dart';
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProgressPage extends StatefulWidget {
  ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  var statusHolder;
  var _idStatusHolder;
  Color _statusCl = Color.fromARGB(255, 246, 205, 0);

  _getOfferingData(idOrder) async {
    var url = Uri.parse(ApiConfig.getOfferingDetailUrl(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    var resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });
    if (resp.statusCode == 200) {
      var decode = jsonDecode(resp.body);

      return decode;
    }
  }

  _openwhatsapp(String noWhatsapp) async {
    var noWa = noWhatsapp;
    var message = "Halo, ada yang bisa saya bantu?";
    var whatsappURl_android = "https://wa.me/$noWa/?text=${Uri.parse(message)}";
    if (await canLaunch(whatsappURl_android)) {
      await launch(whatsappURl_android);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("Whatsapp tidak terinstall")));
    }
  }

  _refreshStatus(
      String idOrder, String deft, dynamic offering, dynamic context) async {
    var url = Uri.parse(ApiConfig.getStatusOffering(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    var resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });

    if (resp.statusCode == 200) {
      var respDecode = jsonDecode(resp.body);
      var data = respDecode['data'];
      setState(() {
        this.statusHolder = ((data != null) || (data['status'] != null))
            ? data['status']
            : deft;
        if (data['id_status'] != null) {
          switch (data['id_status']) {
            case 5:
              _statusCl = Colors.red;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HistoryPage(),
                  settings: RouteSettings(arguments: offering)));
              break;
            case 6:
              _statusCl = Colors.blue;
              break;
            case 7:
              _statusCl = Colors.green;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HistoryPage(),
                  settings: RouteSettings(arguments: offering)));
              break;
            default:
              _statusCl = Color.fromARGB(255, 255, 221, 0);
          }

          _idStatusHolder = data['id_status'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offering = ModalRoute.of(context)!.settings.arguments as OfferingItem;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail pesanan'),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OngoingPage(),
                        settings: RouteSettings(arguments: offering)));
              },
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.locationDot,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Lihat lokasi',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              )),
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
        child: FutureBuilder(
            future: _getOfferingData(offering.id_order),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var spData = snapshot.data['data'];
                var data = OfferingDetail(
                  spData['id_order'],
                  spData['job_title'],
                  spData['client_name'],
                  spData['keluhan'],
                  spData['no_wa_client'],
                  spData['id_status'],
                  spData['status'],
                  spData['biaya'],
                  spData['komentar'],
                  spData['rating'],
                  spData['longitude'],
                  spData['latitude'],
                );

                this.statusHolder = data.status;
                return Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            child: Text(
                              data.idOrder!,
                              style: GoogleFonts.montserrat(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                'oleh ${data.clientName!}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KELUHAN',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 280,
                                      child: Card(
                                        elevation: 0.0,
                                        color:
                                            Color.fromARGB(255, 255, 226, 211),
                                        child: Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: Text(data.keluhan!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Status',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _refreshStatus(offering.id_order,
                                          data.status!, offering, context);
                                    },
                                    child: Icon(FontAwesomeIcons.refresh),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey[50], // background
                                      onPrimary: Colors.grey,
                                      elevation: 0.0,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: _statusCl),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${statusHolder}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text('Harga',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Text('Rp. ${data.biaya.toString()}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      color: Colors.black,
                                    )),
                              )
                            ],
                          )
                        ]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  {this._openwhatsapp(data.noWaClient!)},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.whatsapp,
                                      color: Colors.white),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Hubungi client',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ArrangePage(),
                                        settings: RouteSettings(
                                            arguments: offering)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Atur biaya dan pekerjaan',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.deepOrange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text('Loading...'),
                );
              }
            }),
      )),
    );
  }
}
