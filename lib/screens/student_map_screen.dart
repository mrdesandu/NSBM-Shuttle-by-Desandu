import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class StudentMapScreen extends StatefulWidget {
  final String? fromLocation;
  final String? toLocation;

  // Home Screen à¶‘à¶šà·™à¶±à·Š à¶‘à·€à¶± à¶¯à¶­à·Šà¶­ à¶œà¶±à·Šà¶± à¶¸à·šà¶š à·„à·à¶¯à·”à·€à·
  const StudentMapScreen({super.key, this.fromLocation, this.toLocation});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // à·ƒà·’à¶­à·’à¶ºà¶¸à·š à¶´à·™à¶±à·Šà·€à¶± à¶¶à·ƒà·Š (Markers) à¶§à·’à¶š à¶¯à·à¶±à·Šà¶± Set à¶‘à¶šà¶šà·Š
  final Set<Marker> _busMarkers = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.8213, 80.0416), // NSBM à¶‘à¶šà·š Location à¶‘à¶š
    zoom: 14.4746,
  );

  // --- PickMe/Uber Style Map Theme (Clean Map) ---
  final String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#e0e0e0"}, {"weight": 1}]
    },
    {
      "featureType": "road",
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#c9e2f5"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    _determinePosition()
        .then((_) {
          if (mounted) {
            _loadBusesForRoute();
          }
        })
        .catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location Error: $e'),
                duration: const Duration(seconds: 2),
              ),
            );
            // Still load buses with default location
            _loadBusesForRoute();
          }
        });
  }

  // --- à¶…à¶¯à·à·… Route à¶‘à¶šà¶§ à¶¶à·ƒà·Š à¶´à·™à¶±à·Šà·€à·“à¶¸à·š Logic à¶‘à¶š ---
  void _loadBusesForRoute() {
    // à¶‘à·€à¶½ à¶­à·’à¶ºà·™à¶± Location à¶¸à·œà¶±à·€à¶¯ à¶¶à¶½à¶¸à·”
    debugPrint(
      "Searching buses from: ${widget.fromLocation} to: ${widget.toLocation}",
    );

    // à¶¸à·™à¶­à¶±à¶¯à·“ à¶…à¶´à·’ à¶¯à·à¶±à¶§ Dummy Data à¶§à·’à¶šà¶šà·Š à¶¯à·à¶¸à·” à¶¶à·ƒà·Š à¶´à·™à¶±à·Šà·€à¶±à·Šà¶±.
    // (à¶´à·ƒà·Šà·ƒà·š à¶¸à·šà¶š Firebase à¶‘à¶šà·™à¶±à·Š à¶¶à·ƒà·Š à·€à¶½ à¶‡à¶­à·Šà¶­ Live Location à¶…à¶»à¶±à·Š à¶¯à·à¶±à·Šà¶± à¶´à·”à·…à·”à·€à¶±à·Š)

    if (widget.toLocation == 'Makumbura (MMC)' ||
        widget.fromLocation == 'Makumbura (MMC)') {
      setState(() {
        _busMarkers.add(
          Marker(
            markerId: const MarkerId('bus_1'),
            position: const LatLng(
              6.8250,
              80.0400,
            ), // NSBM à¶šà·’à¶§à·Šà¶§à·”à·€
            infoWindow: const InfoWindow(
              title: 'Bus 1',
              snippet: 'To Makumbura',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ), // à¶šà·œà·… à¶´à·à¶§ à¶šà¶§à·”à·€à¶šà·Š
          ),
        );
        _busMarkers.add(
          Marker(
            markerId: const MarkerId('bus_2'),
            position: const LatLng(6.8350, 80.0250), // à¶´à·à¶» à¶¸à·à¶¯
            infoWindow: const InfoWindow(
              title: 'Bus 2',
              snippet: 'To Makumbura',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });
    } else if (widget.toLocation == 'Colombo Fort' ||
        widget.fromLocation == 'Colombo Fort') {
      setState(() {
        _busMarkers.add(
          Marker(
            markerId: const MarkerId('bus_3'),
            position: const LatLng(
              6.8500,
              80.0100,
            ), // à¶šà·œà·…à¶¹ à¶´à·à¶»à·š
            infoWindow: const InfoWindow(
              title: 'Bus 3',
              snippet: 'To Colombo Fort',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ), // à¶±à·’à¶½à·Š à¶´à·à¶§ à¶šà¶§à·”à·€à¶šà·Š
          ),
        );
      });
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. '
          'Please enable them in app settings.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final GoogleMapController controller = await _controller.future;
      if (mounted) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error determining position: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.toLocation != null
              ? "Buses to ${widget.toLocation}"
              : "Live Tracking",
        ),
        backgroundColor: const Color(0xFF00C7BE),
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        style: _mapStyle,
        markers:
            _busMarkers, // à·„à¶¯à¶´à·" à¶¶à·ƒà·Š à¶§à·'à¶š à¶¸à·à¶´à·Š à¶'à¶šà¶§ à¶¯à·à¶±à·€à·
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
