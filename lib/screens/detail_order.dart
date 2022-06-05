import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kerjamin_fr/screens/arrange_page.dart';
import 'package:kerjamin_fr/screens/map_page.dart';
import 'package:kerjamin_fr/screens/ongoing_page.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:kerjamin_fr/static/offering_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DetailOffering extends StatefulWidget {
  DetailOffering({Key? key}) : super(key: key);

  @override
  State<DetailOffering> createState() => _DetailOfferingState();
}

class _DetailOfferingState extends State<DetailOffering> {
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
    var message = "Halo";
    var whatsappURl_android = "https://wa.me/$noWa/?text=${Uri.parse(message)}";
    if (await canLaunch(whatsappURl_android)) {
      await launch(whatsappURl_android);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("Whatsapp tidak terinstall")));
    }
  }

  Future _isAccOrder(bool isAcc, String idOrder, OfferingItem? ofItem) async {
    var url = isAcc
        ? Uri.parse(ApiConfig.acceptOffering(idOrder))
        : Uri.parse(ApiConfig.rejectOffering(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";
    final resp = await http.patch(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });
    var respDecode = jsonDecode(resp.body);

    if (resp.statusCode == 200) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ArrangePage(),
              settings: RouteSettings(arguments: ofItem)));
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail order'),
        // actions: [
        //   FlatButton(
        //       onPressed: () {
        //         Navigator.pushReplacement(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => MapPage(),
        //                 settings: RouteSettings(arguments: offering)));
        //       },
        //       child: Row(
        //         children: [
        //           Icon(
        //             FontAwesomeIcons.locationDot,
        //             color: Colors.white,
        //           ),
        //           SizedBox(
        //             width: 5,
        //           ),
        //           Text(
        //             'Lihat lokasi',
        //             style: GoogleFonts.montserrat(
        //               fontSize: 18,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.white,
        //             ),
        //           )
        //         ],
        //       )),
        // ],
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
                  spData['jarak'],
                );

                return Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data.idOrder!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                Card(
                                  elevation: 0.0,
                                  color: Colors.blueAccent,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${data.jarak}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Icon(
                                            FontAwesomeIcons.locationDot,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                              onPressed: () => {
                                this._isAccOrder(true, data.idOrder!, offering)
                              },
                              child: Text(
                                'TERIMA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => {
                                this._isAccOrder(false, data.idOrder!, offering)
                              },
                              child: Text(
                                'TOLAK',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                            ),
                          )
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
