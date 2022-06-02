import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kerjamin_fr/screens/arrange_page.dart';
import 'package:kerjamin_fr/screens/ongoing_page.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:kerjamin_fr/static/offering_detail.dart';
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Color _statusCl = Colors.deepOrange;

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

  @override
  Widget build(BuildContext context) {
    final offering = ModalRoute.of(context)!.settings.arguments as OfferingItem;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => OngoingPage()));
            }),
        title: Text('Detail pesanan'),
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

                if (data.idStatus != null) {
                  switch (data.idStatus) {
                    case 5:
                      _statusCl = Colors.red;
                      break;
                    case 7:
                      _statusCl = Colors.green;
                      break;
                  }
                }

                List<Widget> rating = [];
                var rt =
                    (spData['rating'] == "") ? 0 : int.parse(spData['rating']);

                if (rt == 0) {
                  rating.add(Icon(
                    FontAwesomeIcons.star,
                    color: Colors.grey,
                  ));
                } else {
                  for (var i = 0; i < rt; i++) {
                    rating.add(Icon(
                      FontAwesomeIcons.star,
                      color: Colors.amber,
                    ));
                  }
                }

                return SingleChildScrollView(
                  child: Container(
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
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: Color.fromARGB(
                                              255, 255, 226, 211),
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: Text(data.keluhan!),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'REVIEW CLIENT',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 120,
                                        child: Card(
                                          elevation: 0.0,
                                          color: Color.fromARGB(
                                              255, 255, 226, 211),
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: Text(data.komentar!),
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
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: _statusCl),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${data.status}',
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
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text('Perolehan rating',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: rating,
                                ),
                              ],
                            )
                          ]),
                        ),
                      ],
                    ),
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
