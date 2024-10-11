import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  UserAccelerometerEvent? _userAccelerometerEvent;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerEvent = event;
      });
    });

    // Update sensor data every second
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateSensorData());
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  void _updateSensorData() {
    setState(() {
      // This will trigger a rebuild to update the sensor data
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'GPS: ${_currentPosition != null ? '${_currentPosition!.latitude}, ${_currentPosition!.longitude}' : 'N/A'}',
            ),
            Text(
              'Accelerometer: x=${_accelerometerEvent != null ? _accelerometerEvent!.x : 'N/A'}, y=${_accelerometerEvent != null ? _accelerometerEvent!.y : 'N/A'}, z=${_accelerometerEvent != null ? _accelerometerEvent!.z : 'N/A'}',
            ),
            Text(
              'Gyroscope: x=${_gyroscopeEvent != null ? _gyroscopeEvent!.x : 'N/A'}, y=${_gyroscopeEvent != null ? _gyroscopeEvent!.y : 'N/A'}, z=${_gyroscopeEvent != null ? _gyroscopeEvent!.z : 'N/A'}',
            ),
            Text(
              'User Accelerometer: x=${_userAccelerometerEvent != null ? _userAccelerometerEvent!.x : 'N/A'}, y=${_userAccelerometerEvent != null ? _userAccelerometerEvent!.y : 'N/A'}, z=${_userAccelerometerEvent != null ? _userAccelerometerEvent!.z : 'N/A'}',
            ),
          ],
        ),
      ),
    );
  }
}
