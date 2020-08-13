import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:project_ia/place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  static final CameraPosition _inicio = CameraPosition(
    target: LatLng(-19.750092, -47.932394),
    zoom: 14.4746,
  );
  TextEditingController _textController = TextEditingController();
  Place inicio;
  Place fim;
  final geocoding = new GoogleMapsGeocoding(
      apiKey: "AIzaSyDSA-dGgU_aws8e5pP2kbhbvrNkSKyjvc0");
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Text(
              'Menu',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 36),
            ),
            RaisedButton(
              child: Text("Atualizar"),
              onPressed: (){
                setState(() {
                  
                });
              }),
            RaisedButton(
                child: Text("Limpar pontos"),
                onPressed: () {
                  markers.clear();
                  inicio=null;
                  fim=null;
                  setState(() {});
                }),
                ListTile(
                  title:  Text("Iniicio : ${inicio!=null ? inicio.name : ''}"),
                  leading: Icon(Icons.place),
                ),
                ListTile(
                  title:  Text("Fim : ${fim!=null ? fim.name : ''}"),
                  leading: Icon(Icons.place),
                )
               
                
               
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Route Optimizer"),
      ),
      body: GoogleMap(
        markers: Set<Marker>.of(markers.values),
        onTap: (point) async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Nome do Ponto"),
                  content: TextField(
                    controller: _textController,
                  ),
                  actions: [
                    RaisedButton(
                      child: Text("Cancelar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    RaisedButton(
                      child: Text("OK"),
                      onPressed: () {
                        String nome = _textController.text;
                        _add(point.latitude, point.longitude, nome);
                        _textController.clear();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        },
        initialCameraPosition: _inicio,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gerarRota,
        label: Text('Gerar rota'),
        icon: Icon(Icons.map),
      ),
    ));
  }

  Future<void> _gerarRota() async {
    if (inicio != null && fim != null) {
      Map<String, dynamic> data = Map();
      data['destinos'] = [];
      markers.forEach((key, value) {
        if(inicio.name != key.value && fim.name !=key.value){
          data['destinos'].add({
          "name": key.value,
          "lat": value.position.latitude,
          "long": value.position.longitude,
        });
        }
        
      });
      data["inicio"] = inicio.toMap();
      data["fim"] = fim.toMap();
      var dio = Dio();
      Response response = await dio.post(
          "https://route-optmizer.herokuapp.com/get-best-route",
          data: json.encode(data));
      _launchURL(response);
    }
    else{
      showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Não há inicio e/ou Fim"),
          actions: [
            RaisedButton(
              child: Text("Ok"),
              onPressed: (){
              Navigator.of(context).pop();
            })
          ]
        );
      });
    }
  }

  _launchURL(response) async {
    String url = response.data['url'];
    if (url != null) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Erro"),
              content: Text("Selecione pelo menos 3 lugares"),
              actions: [
                RaisedButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  void _add(lat, long, nome) {
    if (markers.length <= 10) {
      var markerIdVal = nome;
      final MarkerId markerId = MarkerId(markerIdVal);

      // creating a new MARKER
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text(markerIdVal),
                    content: Text("Selecione alguma opção"),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            child: Text('Remover'),
                            onPressed: () {
                              markers.remove(markerId);
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                          RaisedButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            child: Text('Inicio'),
                            onPressed: () {
                              inicio = Place(nome, lat, long);
                              Navigator.of(context).pop();
                            },
                          ),
                          RaisedButton(
                            child: Text('Fim'),
                            onPressed: () {
                              fim = Place(nome, lat, long);
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )
                    ]);
              });
        },
      );

      setState(() {
        // adding a new marker to map
        markers[markerId] = marker;
      });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Atenção"),
              content: Text("Máximo de 10 pontos"),
              actions: [
                RaisedButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }
  }
}
