import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:Scaffold(
      drawer: Drawer(
        child: RaisedButton(child: Text('Teste'),onPressed:()async{
          await  _launchURL();
        },),
      ),
      body: GoogleMap(
          markers: Set<Marker>.of(markers.values),
        onTap: (point){
          print(point);
          _add(point.latitude, point.longitude);
        },
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    ) ) ;
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    
  
  }
  _launchURL() async {
    var dio = Dio();
   Response response = await dio.get('https://route-optmizer.herokuapp.com/get-best-route/test'); 
   print(response.data['url']);
  String url = response.data['url'];
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void _add(lat,long) {
    var markerIdVal = markers.length.toString();
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        long
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        showDialog(context: context,
        builder: (context){
          return Dialog(
            child: Column(
              children: [
                Text("Deseja Remover?"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(child: Text('Sim'),
                    onPressed: (){
                         markers.remove(markerId);
        setState(() {
        });
                    },),
                    RaisedButton(child: Text('Não'),
                    onPressed: (){},)
                  ],
                )
              ],
            ),
          );
        });
     
      },
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
}
}
