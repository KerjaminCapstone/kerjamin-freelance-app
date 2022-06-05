import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kerjamin_fr/config/all_config.dart';
import 'package:kerjamin_fr/static/all_static.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  _getCoordinateBoth(idOrder) async {
    var url = Uri.parse(ApiConfig.getCoordinateBothUrl(idOrder));
    var pr = await SharedPreferences.getInstance();
    var tokenSp = pr.getString("token") ?? "";

    var resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokenSp}',
    });
    if (resp.statusCode == 200) {
      var decode = jsonDecode(resp.body);
      var data = decode['data'];

      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final offering = ModalRoute.of(context)!.settings.arguments as OfferingItem;

    return FutureBuilder(
        future: _getCoordinateBoth(offering.id_order),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<Marker> _markers = <Marker>[];
            // var frPos =
            //     LatLng(snapshot.data["fr_lat"], .data["fr_long"]);
            // _markers.add(snapshot
            //   Marker(
            //       markerId: MarkerId('Freelancer'),
            //       position: frPos,
            //       infoWindow: InfoWindow(title: 'Freelancer'),
            //       icon: BitmapDescriptor.defaultMarkerWithHue(
            //           BitmapDescriptor.hueOrange)),
            // );
            var clPos =
                LatLng(snapshot.data["cl_lat"], snapshot.data["cl_long"]);
            _markers.add(
              Marker(
                  markerId: MarkerId('Client'),
                  position: clPos,
                  infoWindow: InfoWindow(title: 'Client'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue)),
            );

            var _initialCameraPosition =
                CameraPosition(target: clPos, zoom: 11.5);
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                actions: [
                  TextButton(
                    onPressed: () => _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: clPos,
                          zoom: 14.5,
                          tilt: 50.0,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.blue,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('LIHAT POSISI CLIENT'),
                  )
                ],
              ),
              body: GoogleMap(
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition: _initialCameraPosition,
                  markers: Set<Marker>.of(_markers),
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapController = controller;
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: clPos, zoom: 14.5, tilt: 50.0),
                    );
                  }),
            );

            // return Scaffold(
            //   body: Center(child: Text(snapshot.data["fr_long"].toString())),
            // );
          } else {
            return Scaffold(
              body: Center(
                child: Text("Loading..."),
              ),
            );
          }
        });
  }
}
