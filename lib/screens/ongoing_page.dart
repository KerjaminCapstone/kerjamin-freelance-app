import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:kerjamin_fr/screens/detail_order.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OngoingPage extends StatefulWidget {
  OngoingPage({Key? key}) : super(key: key);

  @override
  State<OngoingPage> createState() => _OngoingPageState();
}

class _OngoingPageState extends State<OngoingPage> {
  Future _FetchOngoing() async {
    var url = Uri.parse(ApiConfig.getOfferingListUrl());
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    var resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });
    var responseDecode = jsonDecode(resp.body);
    var isErr = responseDecode['error'];
    var datas = responseDecode['data'];

    List<OfferingItem> items = [];

    for (var data in datas) {
      OfferingItem item = new OfferingItem(
          data['id_order'], data['job_title'], data['client_name'], data['at']);

      items.add(item);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order saat ini'),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: FutureBuilder(
            future: this._FetchOngoing(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text('Loading...'),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      return Card(
                        elevation: 0.0,
                        color: Color.fromARGB(255, 255, 226, 211),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  snapshot.data[i].id_order,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  snapshot.data[i].at,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                snapshot.data[i].client_name,
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailOffering(),
                                      settings: RouteSettings(
                                          arguments: snapshot.data[i])));
                            },
                          ),
                        ),
                      );
                    });
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                label: 'Offering', icon: Icon(FontAwesomeIcons.bell)),
            BottomNavigationBarItem(
                label: 'History', icon: Icon(FontAwesomeIcons.history)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(FontAwesomeIcons.user))
          ],
        ),
      ),
    );
  }
}
