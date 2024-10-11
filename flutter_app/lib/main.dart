import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🚴‍♂️ Bike Lane Guardian 🚴‍♀️',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '🚴‍♂️ Bike Lane Guardian 🚴‍♀️ Home Page'),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _getCurrentLocation();
      _listenToSensors();
    } else {
      // Handle the case when the permission is not granted
      print('Location permission not granted');
    }
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
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
          ],
        ),
      ),
    );
  }
}