// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_map_app/constants.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class GoogleMapPage extends StatefulWidget {
//   const GoogleMapPage({super.key});

//   @override
//   State<GoogleMapPage> createState() => _GoogleMapPageState();
// }

// class TargetLocation {
//   final LatLng position;
//   final double radius;
//   final String title;
//   final String snippet;

//   TargetLocation({
//     required this.position,
//     required this.radius,
//     required this.title,
//     required this.snippet,
//   });
// }

// class _GoogleMapPageState extends State<GoogleMapPage> {
//   final locationController = Location();

//   static const eydean = LatLng(27.7308915853421, 85.33034335579451);
//   static const whitelilies = LatLng(27.731130441536173, 85.3306263956302);
//   static const bigmart = LatLng(27.731134253049344, 85.32979393038947);
//   static const russianembassy = LatLng(27.728208637674467, 85.33094195144982);
//   static const holidaycafe = LatLng(27.73076800296457, 85.32998660428167);

//   LatLng? currentPosition;
//   Map<PolylineId, Polyline> polylines = {};

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) async => await initializeMap());
//   }

//   Future<void> initializeMap() async {
//     await fetchLocationUpdates();
//     final coordinates = await fetchPolylinePoints();
//     generatePolyLineFromPoints(coordinates);
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: currentPosition == null
//             ? const Center(child: CircularProgressIndicator())
//             : GoogleMap(
//                 initialCameraPosition: const CameraPosition(
//                   target: eydean,
//                   zoom: 2000,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId('currentLocation'),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueGreen,
//                     ),
//                     position: currentPosition!,
//                   ),
//                   const Marker(
//                     markerId: MarkerId('sourceLocation'),
//                     icon: BitmapDescriptor.defaultMarker,
//                     position: whitelilies,
//                     infoWindow: InfoWindow(
//                       title: 'White Lilies Int’l Preschool',
//                       snippet: 'White Lilies Int’l Preschool',
//                     ),
//                   ),
//                   const Marker(
//                     markerId: MarkerId('sourceLocation'),
//                     icon: BitmapDescriptor.defaultMarker,
//                     position: eydean,
//                     infoWindow: InfoWindow(
//                       title: 'Eydean Inc.',
//                       snippet: 'Eydean Inc.',
//                     ),
//                   ),
//                   const Marker(
//                     markerId: MarkerId('destinationLocation'),
//                     icon: BitmapDescriptor.defaultMarker,
//                     position: russianembassy,
//                     infoWindow: InfoWindow(
//                       title: 'Russsian Embassy',
//                       snippet: 'Russsian Embassy',
//                     ),
//                   ),
//                   const Marker(
//                     markerId: MarkerId('destinationLocation'),
//                     icon: BitmapDescriptor.defaultMarker,
//                     position: bigmart,
//                     infoWindow: InfoWindow(
//                       title: 'Big Mart',
//                       snippet: 'Big Mart',
//                     ),
//                   ),
//                   const Marker(
//                     markerId: MarkerId('destinationLocation'),
//                     icon: BitmapDescriptor.defaultMarker,
//                     position: holidaycafe,
//                     infoWindow: InfoWindow(
//                       title: 'Holiday Cafe',
//                       snippet: 'Holiday Cafe',
//                     ),
//                   ),
//                 },
//                 polylines: Set<Polyline>.of(polylines.values),
//               ),
//       );

//   Future<void> fetchLocationUpdates() async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     serviceEnabled = await locationController.serviceEnabled();
//     if (serviceEnabled) {
//       serviceEnabled = await locationController.requestService();
//     } else {
//       return;
//     }

//     permissionGranted = await locationController.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await locationController.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     locationController.onLocationChanged.listen((currentLocation) {
//       if (currentLocation.latitude != null &&
//           currentLocation.longitude != null) {
//         setState(() {
//           currentPosition = LatLng(
//             currentLocation.latitude!,
//             currentLocation.longitude!,
//           );
//         });
//       }
//     });
//   }

//   Future<List<LatLng>> fetchPolylinePoints() async {
//     final polylinePoints = PolylinePoints();

//     final result = await polylinePoints.getRouteBetweenCoordinates(
//       googleMapsApiKey,
//       PointLatLng(eydean.latitude, eydean.longitude),
//       PointLatLng(russianembassy.latitude, russianembassy.longitude),
//     );

//     if (result.points.isNotEmpty) {
//       return result.points
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList();
//     } else {
//       debugPrint(result.errorMessage);
//       return [];
//     }
//   }

//   Future<void> generatePolyLineFromPoints(
//       List<LatLng> polylineCoordinates) async {
//     const id = PolylineId('polyline');

//     final polyline = Polyline(
//       polylineId: id,
//       color: Colors.blueAccent,
//       points: polylineCoordinates,
//       width: 5,
//     );

//     setState(() => polylines[id] = polyline);
//   }
// }
