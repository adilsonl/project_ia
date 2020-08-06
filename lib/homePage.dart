import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Maps Launcher Demo',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                final availableMaps = await MapLauncher.installedMaps;
                print(
                    availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

                await availableMaps.first.showDirections(
                  destination: Coords(-20.326451, -47.791273),
                );
               
              },
              child: Text('LAUNCH QUERY'),
            ),
            SizedBox(height: 32),
            RaisedButton(
              onPressed: () {},
              child: Text('LAUNCH COORDINATES'),
            ),
          ],
        ),
      ),
    );
  }
}
