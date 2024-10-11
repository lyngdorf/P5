import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

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
  late Future<void> _initialPositionFuture;

  // List to store historic data
  final List<HistoricData> _historicData = [];
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    _initialPositionFuture = _requestPermissionsAndGetInitialPosition();
  }

  Future<void> _requestPermissionsAndGetInitialPosition() async {
    final status = await [
      Permission.locationWhenInUse,
      Permission.location
    ].request();

    if (status[Permission.locationWhenInUse]!.isGranted &&
        status[Permission.location]!.isGranted) {
      await _getInitialPosition();
      _listenToLocationChanges();
      _listenToSensors();
    } else {
      // Handle the case when the permission is not granted
      print('Location permission not granted');
    }
  }

  Future<void> _getInitialPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Initial position: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting initial position: $e');
    }
  }

  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      print('New position: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentPosition = position;
        if (_mapController.mapEventStream.isBroadcast) {
          _mapController.move(
              LatLng(position.latitude, position.longitude), _currentZoom);
        }
        _throttleSaveHistoricData();
      });
    });
  }

  void _listenToSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerEvent = event;
        _throttleSaveHistoricData();
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeEvent = event;
        _throttleSaveHistoricData();
      });
    });
  }

  void _throttleSaveHistoricData() {
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer = Timer(const Duration(seconds: 1), () {
      _saveHistoricData();
    });
  }

  void _saveHistoricData() {
    if (_currentPosition != null && _accelerometerEvent != null && _gyroscopeEvent != null) {
      final data = HistoricData(
        timestamp: DateTime.now(),
        position: _currentPosition!,
        accelerometerEvent: _accelerometerEvent!,
        gyroscopeEvent: _gyroscopeEvent!,
      );
      _historicData.add(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _initialPositionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('GPS Data:'),
                  if (_currentPosition != null)
                    Text(
                        'Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}'),
                  const SizedBox(height: 20),
                  const Text('Accelerometer Data:'),
                  StreamBuilder<AccelerometerEvent>(
                    stream: accelerometerEvents,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final event = snapshot.data!;
                        return Text(
                            'X: ${event.x}, Y: ${event.y}, Z: ${event.z}');
                      } else {
                        return const Text('Waiting for accelerometer data...');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Gyroscope Data:'),
                  StreamBuilder<GyroscopeEvent>(
                    stream: gyroscopeEvents,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final event = snapshot.data!;
                        return Text(
                            'X: ${event.x}, Y: ${event.y}, Z: ${event.z}');
                      } else {
                        return const Text('Waiting for gyroscope data...');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_currentPosition != null)
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                          initialZoom: _currentZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                child: const SizedBox(
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
                  const SizedBox(height: 20),
                  const Text('Historic Data:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _historicData.length,
                      itemBuilder: (context, index) {
                        final data = _historicData[index];
                        return ListTile(
                          title: Text(
                              'Time: ${data.timestamp}, Lat: ${data.position.latitude}, Lon: ${data.position.longitude}'),
                          subtitle: Text(
                              'Acc: X=${data.accelerometerEvent.x}, Y=${data.accelerometerEvent.y}, Z=${data.accelerometerEvent.z}\n'
                              'Gyro: X=${data.gyroscopeEvent.x}, Y=${data.gyroscopeEvent.y}, Z=${data.gyroscopeEvent.z}'),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class HistoricData {
  final DateTime timestamp;
  final Position position;
  final AccelerometerEvent accelerometerEvent;
  final GyroscopeEvent gyroscopeEvent;

  HistoricData({
    required this.timestamp,
    required this.position,
    required this.accelerometerEvent,
    required this.gyroscopeEvent,
  });
}