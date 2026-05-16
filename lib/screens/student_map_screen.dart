import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class StudentMapScreen extends StatefulWidget {
  final String? fromLocation;
  final String? toLocation;

  // Home Screen එකෙන් එවන දත්ත ගන්න මේක හැදුවා
  const StudentMapScreen({super.key, this.fromLocation, this.toLocation});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // සිතියමේ පෙන්වන බස් (Markers) ටික දාන්න Set එකක්
  final Set<Marker> _busMarkers = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.8213, 80.0416), // NSBM එකේ Location එක
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
    _determinePosition();
    _loadBusesForRoute(); // ස්ක්‍රීන් එක ලෝඩ් වෙද්දීම බස් ටික හොයනවා
  }

  // --- අදාළ Route එකට බස් පෙන්වීමේ Logic එක ---
  void _loadBusesForRoute() {
    // එවල තියෙන Location මොනවද බලමු
    print(
      "Searching buses from: ${widget.fromLocation} to: ${widget.toLocation}",
    );

    // මෙතනදී අපි දැනට Dummy Data ටිකක් දාමු බස් පෙන්වන්න.
    // (පස්සේ මේක Firebase එකෙන් බස් වල ඇත්ත Live Location අරන් දාන්න පුළුවන්)

    if (widget.toLocation == 'Makumbura (MMC)' ||
        widget.fromLocation == 'Makumbura (MMC)') {
      setState(() {
        _busMarkers.add(
          Marker(
            markerId: const MarkerId('bus_1'),
            position: const LatLng(6.8250, 80.0400), // NSBM කිට්ටුව
            infoWindow: const InfoWindow(
              title: 'Bus 1',
              snippet: 'To Makumbura',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ), // කොළ පාට කටුවක්
          ),
        );
        _busMarkers.add(
          Marker(
            markerId: const MarkerId('bus_2'),
            position: const LatLng(6.8350, 80.0250), // පාර මැද
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
            position: const LatLng(6.8500, 80.0100), // කොළඹ පාරේ
            infoWindow: const InfoWindow(
              title: 'Bus 3',
              snippet: 'To Colombo Fort',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ), // නිල් පාට කටුවක්
          ),
        );
      });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ),
    );
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
        markers: _busMarkers, // හදපු බස් ටික මැප් එකට දානවා
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);

          // --- මෙතනින් තමයි අලුත් Theme එක මැප් එකට දාන්නේ ---
          controller.setMapStyle(_mapStyle);
        },
      ),
    );
  }
}
