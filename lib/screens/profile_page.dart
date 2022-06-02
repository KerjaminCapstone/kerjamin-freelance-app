import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:kerjamin_fr/screens/all_screens.dart';
import 'package:kerjamin_fr/screens/arrange_page.dart';
import 'package:kerjamin_fr/screens/detail_order.dart';
import 'package:kerjamin_fr/screens/histories_page.dart';
import 'package:kerjamin_fr/screens/history_page.dart';
import 'package:kerjamin_fr/screens/ongoing_page.dart';
import 'package:kerjamin_fr/screens/progress_page.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:kerjamin_fr/static/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2;
  String address = "";

  @override
  void initState() {
    address = "-";
    super.initState();
  }

  _getMainPage(index) {
    var mP;

    switch (index) {
      case 0:
        mP = OngoingPage();
        break;
      case 1:
        mP = HistoriesPage();
        break;
      case 2:
        mP = ProfilePage();
        break;

      default:
        mP = OngoingPage();
    }

    return mP;
  }

  _getProfileData() async {
    var url = Uri.parse(ApiConfig.getProfileUrl());
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

  Future<dynamic> _geoLocPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      Alert(
          context: context,
          style: AlertStyle(
            titleStyle: TextStyle(
              color: Colors.redAccent,
            ),
          ),
          title: 'Akses lokasi dimatikan.',
          buttons: [
            DialogButton(
                child: Text("close"), onPressed: () => Navigator.pop(context))
          ]).show();

      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    Placemark place1 = placemarks[1];

    return '${place1.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}';
  }

  Future _updateAddress(lat, long, add) async {
    var url = Uri.parse(ApiConfig.getUpdateAddressUrl());
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";
    var resp = await http.patch(url,
        body: jsonEncode({
          'address': add,
          'address_long': long,
          'address_lat': lat,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenSp}',
        });
    var respDecode = jsonDecode(resp.body);

    if (resp.statusCode == 200) {
      setState(() {
        address = add;
      });
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

  Future _doLogout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profil Saya'),
            automaticallyImplyLeading: false,
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));

                    _doLogout();
                  },
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.signOutAlt,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Keluar',
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
          body: FutureBuilder(
              future: _getProfileData(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var spData = snapshot.data['data'];
                  var data = Profile(
                      spData['nama'],
                      spData['email'],
                      spData['id_user_nik'],
                      spData['nlp_tags']['npl_tag1'],
                      spData['nlp_tags']['npl_tag2'],
                      spData['nlp_tags']['npl_tag3'],
                      spData['nlp_tags']['npl_tag4'],
                      spData['nlp_tags']['npl_tag5'],
                      spData['keahlian'],
                      spData['points'],
                      spData['alamat']);

                  address = data.alamat!;

                  return SingleChildScrollView(
                      child: Center(
                          child: Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 15),
                                width: 100,
                                height: 48,
                                child: Card(
                                  elevation: 0.0,
                                  color: Colors.amber,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${data.points}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Icon(
                                          FontAwesomeIcons.solidStar,
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
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Icon(
                                    FontAwesomeIcons.circleUser,
                                    size: 80.0,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              'Nama',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            child: Card(
                              elevation: 0.0,
                              color: Color.fromARGB(255, 255, 226, 211),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text('${data.nama}'),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Email',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            child: Card(
                              elevation: 0.0,
                              color: Color.fromARGB(255, 255, 226, 211),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text('${data.email}'),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Id User/NIK',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            child: Card(
                              elevation: 0.0,
                              color: Color.fromARGB(255, 255, 226, 211),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text('${data.idUserNik}'),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Bidang keahlian',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            child: Card(
                              elevation: 0.0,
                              color: Color.fromARGB(255, 255, 226, 211),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text('${data.keahlian}'),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Alamat',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 210,
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Card(
                              elevation: 0.0,
                              color: Color.fromARGB(255, 255, 226, 211),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text('${address}'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Position pos = await _geoLocPosition();
                                if (pos != null) {
                                  String addr =
                                      await _getAddressFromLatLong(pos);
                                  await _updateAddress(
                                      pos.latitude, pos.longitude, addr);
                                } else {
                                  Alert(
                                      context: context,
                                      style: AlertStyle(
                                        titleStyle: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      title: 'Akses lokasi ditolak.',
                                      buttons: [
                                        DialogButton(
                                            child: Text("close"),
                                            onPressed: () =>
                                                Navigator.pop(context))
                                      ]).show();
                                }
                              },
                              child: Text(
                                'Perbarui alamat',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue),
                            ),
                          ),
                        ]),
                  )));
                } else {
                  return Center(
                    child: Text('Loading...'),
                  );
                }
              }),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.deepOrange, // <-- This works for fixed
            selectedItemColor: Color.fromARGB(255, 147, 202, 248),
            unselectedItemColor: Color.fromARGB(255, 219, 219, 219),
            currentIndex: _currentIndex,
            items: const [
              BottomNavigationBarItem(
                label: 'Offering',
                icon: Icon(Icons.notifications),
              ),
              BottomNavigationBarItem(
                label: 'History',
                icon: Icon(Icons.history),
              ),
              BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(Icons.person),
              )
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => _getMainPage(index)));
            },
          ),
        ));
  }
}
