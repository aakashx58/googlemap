import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class TargetLocation {
  final LatLng position;
  final double radius;
  final String title;
  final String snippet;

  TargetLocation({
    required this.position,
    required this.radius,
    required this.title,
    required this.snippet,
  });
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final locationController = Location();
  bool _popupShown = false;

  static const eydean = LatLng(27.7308915853421, 85.33034335579451);
  static const whitelilies = LatLng(27.731130441536173, 85.3306263956302);
  static const bigmart = LatLng(27.731134253049344, 85.32979393038947);
  static const russianembassy = LatLng(27.728208637674467, 85.33094195144982);
  static const holidaycafe = LatLng(27.73076800296457, 85.32998660428167);

  LatLng? currentPosition;
  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  TargetLocation? _nearestLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: eydean,
                  zoom: 2000,
                ),
                markers: markers,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onCameraMove: (CameraPosition position) {
                  if (_nearestLocation != null && !_popupShown) {
                    final targetLocation = _nearestLocation!.position;
                    final distance = _calculateDistance(
                      position.target.latitude,
                      position.target.longitude,
                      targetLocation.latitude,
                      targetLocation.longitude,
                    );

                    if (distance < 10) {
                      _showPopup(context, _nearestLocation!);
                      _popupShown = true;
                    }
                  }
                },
              ),
      );

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        final userLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        setState(() {
          currentPosition = userLocation;
          markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
              position: userLocation,
            ),
            ...targetLocations.map(
              (targetLocation) => Marker(
                markerId: MarkerId(targetLocation.title),
                icon: BitmapDescriptor.defaultMarker,
                position: targetLocation.position,
                infoWindow: InfoWindow(
                  title: targetLocation.title,
                  snippet: targetLocation.snippet,
                ),
              ),
            ),
          };

          _nearestLocation = _findNearestLocation(userLocation);
          _popupShown = false;
        });
      }
    });
  }

  TargetLocation? _findNearestLocation(LatLng userLocation) {
    TargetLocation? nearestLocation;
    double minDistance = double.infinity;

    for (final location in targetLocations) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        location.position.latitude,
        location.position.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestLocation = location;
      }
    }

    return nearestLocation;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371e3; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  void _showPopup(BuildContext context, TargetLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.title),
        content: Text(location.snippet),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static List<TargetLocation> targetLocations = [
    TargetLocation(
      position: eydean,
      title: 'Eydean Inc.',
      snippet: 'Software Company',
      radius: 100,
    ),
    TargetLocation(
      position: whitelilies,
      title: 'White Lilies Int’l Preschool',
      snippet: 'Preschool',
      radius: 100,
    ),
    TargetLocation(
      position: bigmart,
      title: 'Big Mart',
      snippet: 'Supermarket',
      radius: 100,
    ),
    TargetLocation(
      position: russianembassy,
      title: 'Russian Embassy',
      snippet: 'Embassy',
      radius: 100,
    ),
    TargetLocation(
      position: holidaycafe,
      title: 'Holiday Cafe',
      snippet: 'Coffee shop',
      radius: 100,
    ),
  ];
}
