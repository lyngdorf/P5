import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _currentPosition;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  final MapController _mapController = MapController();
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await [
      Permission.locationWhenInUse,
      Permission.location
    ].request();

    if (status[Permission.locationWhenInUse]!.isGranted && status[Permission.location]!.isGranted) {
      _listenToLocationChanges();
      _listenToSensors();
    } else {
      // Handle the case when the permission is not granted
      print('Location permission not granted');
    }
  }

  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _mapController.move(LatLng(position.latitude, position.longitude), _currentZoom);
      });
    });

    // Get the initial position
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
        _mapController.move(LatLng(position.latitude, position.longitude), _currentZoom);
      });
    });
  }

  void _listenToSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeEvent = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('GPS Data:'),
            if (_currentPosition != null)
              Text('Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}'),
            const SizedBox(height: 20),
            Text('Accelerometer Data:'),
            if (_accelerometerEvent != null)
              Text('X: ${_accelerometerEvent!.x}, Y: ${_accelerometerEvent!.y}, Z: ${_accelerometerEvent!.z}'),
            const SizedBox(height: 20),
            Text('Gyroscope Data:'),
            if (_gyroscopeEvent != null)
              Text('X: ${_gyroscopeEvent!.x}, Y: ${_gyroscopeEvent!.y}, Z: ${_gyroscopeEvent!.z}'),
            const SizedBox(height: 20),
            if (_currentPosition != null)
              SizedBox(
                height: 200,
                width: 200,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0),
                    initialZoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            child: SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}